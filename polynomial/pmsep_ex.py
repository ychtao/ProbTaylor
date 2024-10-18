import sympy as sp
import sympy.stats as sps
import numpy as np
from functools import reduce
import time

index_counter = 0
eps = 2 ** (-24)
c = 0.99

def fresh_ed():
    global index_counter
    index_counter += 1
    return sp.symbols(f'e{index_counter}'), sp.symbols(f'd{index_counter}')

def tilde(f):
    global index_counter
    if isinstance(f, sp.Pow):
        f1, p = f.args 
        tf1, tf2 = tilde(f1), tilde(sp.Pow(f1, p-1))
        ei, di = fresh_ed()
        return ((tf1 * tf2) * (1 + ei)) + di
    elif isinstance(f, sp.Add):
        f1, f2 = f.args[0], f.args[1:]
        tf1, tf2 = tilde(f1), tilde(sum(f2))
        ei, di = fresh_ed()
        return ((tf1 + tf2) * (1 + ei)) + di
    elif isinstance(f, sp.Mul):
        f1, f2 = f.args[0], f.args[1:]
        tf1, tf2 = tilde(f1), tilde(reduce(sp.Mul, f2))
        ei, di = fresh_ed()
        return ((tf1 * tf2) * (1 + ei)) + di
    else:
        return f
      
def F1F2(f):
  global index_counter
  pd_dict, F1_dict, F2_dict = {}, {}, {}
  e_vals = {sp.symbols(f'e{i}') : 0 for i in range (1, index_counter + 1)}
  d_vals = {sp.symbols(f'd{i}') : 0 for i in range (1, index_counter + 1)}
  for i in range(1, index_counter+1):
    pd = sp.diff(f, sp.symbols(f"e{i}"))
    pd = pd.subs(e_vals).subs(d_vals)
    pd_dict[i] = pd
    F1_dict[i] = pd ** 2
  for i in range(1, index_counter+1):
    for j in range(i + 1, index_counter+1):
      F2_dict[(i,j)] = 2 * pd_dict[i] * pd_dict[j]
  return F1_dict, F2_dict
    
def separate_pos_neg(f):
  global pnvars
  if isinstance(f, sp.Pow):
    f1, p = f.args
    return separate_pos_neg(f1) * separate_pos_neg(sp.Pow(f1, p-1))
  elif isinstance(f, sp.Add):
    f1, f2 = f.args[0], f.args[1:]
    return separate_pos_neg(f1) + separate_pos_neg(sum(f2))
  elif isinstance(f, sp.Mul):
    f1, f2 = f.args[0], f.args[1:]
    return separate_pos_neg(f1) * separate_pos_neg(reduce(sp.Mul, f2))
  elif isinstance(f, (sp.Symbol, sps.rv.RandomSymbol)):
    x = f.name
    return (pnvars[x][0] - pnvars[x][1])
    # return (sp.symbols(f"{x}_pos") - sp.symbols(f"{x}_neg"))
  else:
    return f
    
def EF1(F1_dict):
  return eps**2 * sps.E(sum(F1_dict.values()))

def EF2(F2_dict):
  ret = 0
  for idx, p in F2_dict.items():
    p_pn = sp.expand(separate_pos_neg(p), power_exp = True)
    q, r = 0, 0
    for term in p_pn.args:
      if (term.args[0] > 0):
        q += term
      else:
        r -= term
    # print(sps.E(q))
    # print(sps.E(r))
    print(sps.E(q) + sps.E(r))
    ret += (sps.E(q) + sps.E(r))
  print(ret)
  return ret * eps ** 2

x = sps.Uniform('x', -1, 1)
y = sps.Uniform('y', -1, 1)
z = sps.Uniform('z', -1, 1)
vars = [x, y, z]
pnvars = {}
for var in vars:
  vp = sp.Max(var, 0)
  var_pos = sp.Max(var, 0)
  var_neg = sp.Max(-var, 0)
  pnvars[var.name] = (var_pos, var_neg)
f = x * x + y * z
tf = tilde(f)
print(f"tilde f = {tf}")
F1, F2 = F1F2(tf)
print((EF1(F1) + EF2(F2))/ 0.001**2)
# print(f"E[F^2] = {EF1(F1) + EF2(F2)}")
# for key, value in EF2(F2).items():
#   print(f"EF2[{key}] = {value}")
