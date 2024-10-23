import sympy as sp
import sympy.stats as sps
import numpy as np
from functools import reduce
import time

def vars_pos_neg(vars):
  pn_vars = {}
  for var in vars:
    var_pos = sp.Max(var, 0)
    var_neg = sp.Max(-var, 0)
    pn_vars[var.name] = (var_pos, var_neg)
  return pn_vars

def get_pq(tf, k):
  ret = 0
  e_vals = {sp.symbols(f'e{i}') : 0 for i in range (1, k + 1)}
  d_vals = {sp.symbols(f'd{i}') : 0 for i in range (1, k + 1)}
  hs, ps = {}, {}
  for i in range(1, k + 1):
    h = sp.diff(tf, sp.symbols(f'e{i}'))
    h = sp.simplify(h.subs(e_vals).subs(d_vals))
    hs[i] = h
    ret += h * sp.symbols(f'e{i}')
  p, q = ret.as_numer_denom()
  for i in range(1, k + 1):
    ps[i] = sp.simplify(hs[i] * q)
  return ps, q
  
def decomp_pos_neg(f, pnvars):
  if isinstance(f, sp.Pow):
    f1, p = f.args
    return decomp_pos_neg(f1, pnvars) * decomp_pos_neg(sp.Pow(f1, p-1), pnvars)
  elif isinstance(f, sp.Add):
    f1, f2 = f.args[0], f.args[1:]
    return decomp_pos_neg(f1, pnvars) + decomp_pos_neg(sum(f2), pnvars)
  elif isinstance(f, sp.Mul):
    f1, f2 = f.args[0], f.args[1:]
    return decomp_pos_neg(f1, pnvars) * decomp_pos_neg(reduce(sp.Mul, f2), pnvars)
  elif isinstance(f, (sp.Symbol, sps.rv.RandomSymbol)):
    x = f.name
    return (pnvars[x][0] - pnvars[x][1])
  else:
    return f
  
def sep_pos_neg(f):
  f = sp.expand(f)
  fp, fn = 0, 0
  for term in f.args:
    if isinstance(term, sp.Mul):
      if term.args[0].is_number and (term.args[0] < 0):
        fn -= term
      else:
        fp += term
    elif isinstance(term, sp.Pow):
      fp += term 
    else:
      if term.is_number and (term < 0):
        fn -= term
      else:
        fp += term
  return fp, fn

def get_Ku(ps, q, pn_vars, k, eps):
  p2u = 0
  for i in range(1, k + 1):
    p = decomp_pos_neg(ps[i], pn_vars)
    pp, pn = sep_pos_neg(p)
    # print(i, pp, pn)
    p2u += pp + pn
  p2u = sp.simplify(sp.expand(p2u ** 2))
  # print(p2u)
  u = sp.symbols('u')
  Ku = eps ** 2 * p2u - q ** 2 * u
  return sp.simplify(sp.expand(Ku))

def elim_pnprod(tf):
  tf = sp.expand(sp.simplify(tf))
  if not isinstance(tf, sp.Add):
    return tf
  ret = 0
  for term in tf.args:
    if isinstance(term, sp.Mul):
      zero_flag = False
      flags = {}
      for var in term.args:
        if isinstance(var, sp.Max):
          varm = var.args[1]
        elif isinstance(var, sp.Pow) and isinstance(var.args[0], sp.Max):
          varm = var.args[0].args[1]
        else:
          continue
        if isinstance(varm, sps.rv.RandomSymbol):
          if (varm.name, -1) in flags:
            zero_flag = True
            break
          flags[(varm.name, 1)] = True 
        elif isinstance(varm, sp.Mul) and varm.args[0] == -1:
          if (varm.args[1].name, 1) in flags:
            zero_flag = True 
            break
          flags[(varm.args[1].name, -1)] = True
      if not zero_flag:
        ret += term
    else:
      ret += term
  return ret

def err_bound(tf, k, vars, c, eps):
  pn_vars = vars_pos_neg(vars)
  ps, q = get_pq(tf, k)
  Ku = get_Ku(ps, q, pn_vars, k, eps)
  Ku = elim_pnprod(Ku)
  M1 = sp.simplify(sps.E(Ku))
  Ku2 = elim_pnprod(Ku ** 2)
  print(Ku2)
  Ku4 = elim_pnprod(Ku2 ** 2)
  print(Ku4)
  M2 = sps.E(Ku2)
  print(2)
  M4 = sps.E(Ku4)
  print(4)
  for vinv in range(0, 10):
    v = 10 ** (vinv)
    pos_prob = 1 - (4 / 9) * (2 * np.sqrt(3) - 3) * (-2 * M1 / v + 3 * M2 / (v ** 2) - M4 / (v ** 4)) 
  # equation = sp.simplify(sigma2 - (1 - c) * (sigma2 + mu2))
    equation = sp.simplify(pos_prob - 1 + c)
    print(sp.solve(equation, sp.symbols('u')))

x = sps.Uniform('x', -2, 2)
y = sps.Uniform('y', 1, 2)
z = sps.Uniform('z', 1, 2)
vars = (x, y, z)
local_dict = {"x" : x, "y" : y, "z" : z}

with open ('tilde.txt', 'r') as file:
  stf = file.readline().strip()
  sk = file.readline().strip()
  
tf = sp.sympify(stf, locals = local_dict)
k = int(sk)

c = 0.99
eps = 2 ** (-24)

start = time.time()
output = err_bound(tf, k, vars, c, eps)
print(f"Time: {time.time() - start}")