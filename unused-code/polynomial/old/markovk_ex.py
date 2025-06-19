import sympy as sp
import sympy.stats as sps
import numpy as np
from functools import reduce

def fresh_ed(index_counter):
  index_counter += 1
  return index_counter, sp.symbols(f'e{index_counter}'), sp.symbols(f'd{index_counter}')

def tilde(f, index_counter):
  if isinstance(f, sp.Pow):
    f1, p = f.args 
    index_counter, ei, di = fresh_ed(index_counter)
    tf1, index_counter = tilde(f1, index_counter) 
    tf2, index_counter = tilde(sp.Pow(f1, p-1), index_counter)
    return ((tf1 * tf2) * (1 + ei)) + di, index_counter
  elif isinstance(f, sp.Add):
    f1, f2 = f.args[0], f.args[1:]
    index_counter, ei, di = fresh_ed(index_counter)
    tf1, index_counter = tilde(f1, index_counter)
    tf2, index_counter = tilde(sum(f2), index_counter)
    return ((tf1 + tf2) * (1 + ei)) + di, index_counter
  elif isinstance(f, sp.Mul):
    f1, f2 = f.args[0], f.args[1:]
    index_counter, ei, di = fresh_ed(index_counter)
    tf1, index_counter = tilde(f1, index_counter)
    tf2, index_counter = tilde(reduce(sp.Mul, f2), index_counter)
    return ((tf1 * tf2) * (1 + ei)) + di, index_counter
  else:
    return f, index_counter

def G2(f, index_counter):
  ret = 0
  e_vals = {sp.symbols(f'e{i}') : 0 for i in range (1, index_counter + 1)}
  d_vals = {sp.symbols(f'd{i}') : 0 for i in range (1, index_counter + 1)}
  for i in range(1, index_counter + 1):
    ret += ((sp.diff(f, sp.symbols(f'e{i}'))) ** 2).subs(e_vals).subs(d_vals)
  return index_counter * ret

def err_bound(f, vars, c, eps):
  index_counter = 0
  k = sp.symbols('k')
  tf, index_counter = tilde(f, index_counter)
  gsq = G2(tf, index_counter)
  ret = eps * (sps.E(gsq ** k) / (1 - c)) ** (1 / 2 * k)
  print(ret.subs({k : 1}))
  print(ret.subs({k : 2}))
  print(ret.subs({k : 3}))
  
  return sps.limit(ret, k, sp.oo)

x = sps.Uniform('x', -1, 1)
y = sps.Uniform('y', -1, 1)
z = sps.Uniform('z', -1, 1)
f = x ** 2 + y * z
vars = [x, y, z]
c = 0.99
eps = 2 ** (-24)

print(err_bound(f, [x, y, z], c, eps))
