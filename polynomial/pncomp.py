import sympy as sp
import sympy.stats as sps
import numpy as np
from functools import reduce
import time


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

def vars_pos_neg(vars):
  pn_vars = {}
  for var in vars:
    var_pos = sp.Max(var, 0)
    var_neg = sp.Max(-var, 0)
    pn_vars[var.name] = (var_pos, var_neg)
  return pn_vars

def F1F2(f, index_counter):
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

def separate_pos_neg(f, pnvars):
  if isinstance(f, sp.Pow):
    f1, p = f.args
    return separate_pos_neg(f1, pnvars) * separate_pos_neg(sp.Pow(f1, p-1), pnvars)
  elif isinstance(f, sp.Add):
    f1, f2 = f.args[0], f.args[1:]
    return separate_pos_neg(f1, pnvars) + separate_pos_neg(sum(f2), pnvars)
  elif isinstance(f, sp.Mul):
    f1, f2 = f.args[0], f.args[1:]
    return separate_pos_neg(f1, pnvars) * separate_pos_neg(reduce(sp.Mul, f2), pnvars)
  elif isinstance(f, (sp.Symbol, sps.rv.RandomSymbol)):
    x = f.name
    return (pnvars[x][0] - pnvars[x][1])
  else:
    return f

def EF1(F1):
  return sps.E(sum(F1.values()))

def EF2(F2, pnvars):
  ret = 0
  for idx, p in F2.items():
    p_pn = sp.expand(separate_pos_neg(p, pnvars), power_exp = True)
    q, r = 0, 0
    for term in p_pn.args:
      if not isinstance(term, sp.Mul):
        if (term > 0):
          q += term
        else:
          r -= term
      else:
        if (term.args[0] > 0):
          q += term
        else:
          r -= term
    ret += sps.E(q) + sps.E(r)
  return ret

def err_bound(f, vars, c, eps):
  index_counter = 0
  tildef, index_counter = tilde(f, index_counter)
  pnvars = vars_pos_neg(vars)
  F1, F2 = F1F2(tildef, index_counter)
  EFsqr = eps ** 2 * (EF1(F1) + EF2(F2, pnvars))
  return (EFsqr / (1-c)) ** 0.5

# x = sps.Uniform('x', -1, 1)
# y = sps.Uniform('y', -1, 1)
# z = sps.Uniform('z', -1, 1)
# vars = [x, y, z]
# f = x ** 2 + y * z
# print(err_bound(f, vars, 0.99, 2 ** (-24)))
  
c = 0.99
eps = 2 ** (-24)

# x = sps.Uniform('x', -1, 1)
# y = sps.Uniform('y', -1, 1)
# z = sps.Uniform('z', -1, 1)
# f = x ** 2 + y * z
# vars = [x, y, z]
# start = time.time()
# print(err_bound(f, vars, c, eps))
# print(f"time : {time.time() - start}")

atts0 = sps.Uniform('atts0', 3.0, 9.0)
atts1 = sps.Uniform('atts1', 1.5, 5.0)
atts2 = sps.Uniform('atts2', -2.0, 10.0)
atts3 = sps.Uniform('atts3', -1.0, 3.5)
classids0 = (((((-0.85073072819636686) * atts0) + ((-0.98664016916368502) * atts1)) + ((1.3809517485817782) * atts2)) + ((1.8653450939330991) * atts3))-(((((0.18424469636214999) * atts0) + ((0.45123431334216657) * atts1)) + ((-0.80794264540764449) * atts2)) + ((-0.45071126534400952) * atts3))
vars = [atts0, atts1, atts2, atts3]
print("ClassIDs0")
print(f"PAF bound = {6.93 * (10 ** (-6))}")
start = time.time()
print(f"our bound = {err_bound(classids0, vars, c, eps)}")
print(f"time = {time.time() - start}")

atts0 = sps.Uniform('atts0', 3.0, 9.0)
atts1 = sps.Uniform('atts1', 1.5, 5.0)
atts2 = sps.Uniform('atts2', -2.0, 10.0)
atts3 = sps.Uniform('atts3', -1.0, 3.5)
classids1 = (((((0.18424469636214999) * atts0) + ((0.45123431334216657) * atts1)) + ((-0.80794264540764449) * atts2)) + ((-0.45071126534400952) * atts3))-(((((0.052100253064028955) * atts0) + ((-0.8942341911807864) * atts1)) + ((0.40478255170032273) * atts2)) + ((-0.93774690197704236) * atts3))
vars = [atts0, atts1, atts2, atts3]
print("ClassIDs1")
print(f"PAF bound = {3.71 * (10 ** (-6))}")
start = time.time()
index_counter = 0
print(f"our bound = {err_bound(classids1, vars, c, eps)}")
print(f"time = {time.time() - start}")

atts0 = sps.Uniform('atts0', 3.0, 9.0)
atts1 = sps.Uniform('atts1', 1.5, 5.0)
atts2 = sps.Uniform('atts2', -2.0, 10.0)
atts3 = sps.Uniform('atts3', -1.0, 3.5)
classids2 = (((((0.052100253064028955) * atts0) + ((-0.8942341911807864) * atts1)) + ((0.40478255170032273) * atts2)) + ((-0.93774690197704236) * atts3))-(((((0.85073072819636686) * atts0) + ((-0.98664016916368502) * atts1)) + ((1.3809517485817782) * atts2)) + ((1.8653450939330991) * atts3))
vars = [atts0, atts1, atts2, atts3]
print("ClassIDs2")
print(f"PAF bound = {5.23 * (10 ** (-6))}")
start = time.time()
index_counter = 0
print(f"our bound = {err_bound(classids2, vars, c, eps)}")
print(f"time = {time.time() - start}")

x0 = sps.Uniform('x0', -2, 2)
filter1 = 0.7 * x0
vars = [x0]
print("Filter1")
print(f"PAF bound = {1.25 * (10 ** (-7))}")
start = time.time()
print(f"our bound = {err_bound(filter1, vars, c, eps)}")
print(f"time = {time.time() - start}")

x0 = sps.Uniform('x0', -2, 2)
x1 = sps.Uniform('x1', -2, 2)
filter2 = ((0.7 * x1) - (1.3 * x0)) + (1.4 * (0.7 * x0))
vars = [x0, x1]
print("Filter2")
print(f"PAF bound = {7.93 * (10 ** (-7))}")
start = time.time()
print(f"our bound = {err_bound(filter2, vars, c, eps)}")
print(f"time = {time.time() - start}")

x0 = sps.Uniform('x0', -2, 2)
x1 = sps.Uniform('x1', -2, 2)
x2 = sps.Uniform('x2', -2, 2)
filter3 = ((((0.7 * x2) - (1.3 * x1)) + (1.1 * x0)) + (1.4 * (((0.7 * x1) - (1.3 * x0)) + (1.4 * (0.7 * x0)))) - (0.7 * (0.7 * x0)))
vars = [x0, x1, x2]
print("Filter3")
print(f"PAF bound = {2.34 * (10 ** (-6))}")
start = time.time()
print(f"our bound = {err_bound(filter3, vars, c, eps)}")
print(f"time = {time.time() - start}")

x0 = sps.Uniform('x0', -2, 2)
x1 = sps.Uniform('x1', -2, 2)
x2 = sps.Uniform('x2', -2, 2)
x3 = sps.Uniform('x3', -2, 2)
filter4 = ((((0.7 * x3) - (1.3 * x2)) + (1.1 * x1)) + (1.4 * ((((0.7 * x2) - (1.3 * x1)) + (1.1 * x0)) + ((1.4 * (((0.7 * x1) - (1.3 * x0)) + (1.4 * (0.7 * x0)))) - (0.7 * (0.7 * x0)))))) - (0.7 * (((0.7 * x1) - (1.3 * x0)) + (1.4 * (0.7 * x0))))
vars = [x0, x1, x2, x3]
print("Filter4")
print(f"PAF bound = {4.15 * (10 ** (-6))}")
start = time.time()
index_counter = 0
print(f"our bound = {err_bound(filter4, vars, c, eps)}")
print(f"time = {time.time() - start}")

x1 = sps.Uniform('x1', -15.0, 15.0)
x2 = sps.Uniform('x2', -15.0, 15.0)
x3 = sps.Uniform('x3', -15.0, 15.0)
rigidbody1 = ((((-(x1 * x2)) - (2 * (x2 * x3))) - x1) - x3)
vars = [x1, x2, x3]
print("RigidBody1")
print(f"PAF bound = {1.74 * (10 ** (-4))}")
start = time.time()
print(f"our bound = {err_bound(rigidbody1, vars, c, eps)}")
print(f"time = {time.time() - start}")

x1 = sps.Uniform('x1', -15.0, 15.0)
x2 = sps.Uniform('x2', -15.0, 15.0)
x3 = sps.Uniform('x3', -15.0, 15.0)
rigidbody2 = (((((((2 * x1) * x2) * x3) + ((3 * x3) * x3)) - (((x2 * x1) * x2) * x3)) + ((3 * x3) * x3)) - x2)
vars = [x1, x2, x3]
print("RigidBody2")
print(f"PAF bound = {1.96 * (10 ** (-2))}")
start = time.time()
print(f"our bound = {err_bound(rigidbody2, vars, c, eps)}")
print(f"time = {time.time() - start}")

x = sps.Uniform('x', 0.0, 10.0)
sqrt = (((1.0 + (0.5 * x)) - ((0.125 * x) * x)) + (((0.0625 * x) * x) * x)) - ((((0.0390625 * x) * x) * x) * x)
vars = [x]
print("Sqrt")
print(f"PAF bound = {2.37 * (10 ** (-7))}")
start = time.time()
print(f"our bound = {err_bound(sqrt, vars, c, eps)}")
print(f"time = {time.time() - start}")

s0 = sps.Uniform('s0', 0.0, 4.6)
s1 = sps.Uniform('s1', 0.0, 10.0)
s2 = sps.Uniform('s2', 0.0, 10.0)
traincars1 = ((((-3.795323e2) * s0) + ((-5.443608e2) * s1)) + (92.729 * s2)) + 4.5165916241610748e3
vars = [s0, s1, s2]
print("TrainCars1")
print(f"PAF bound = {1.76 * (10 ** (-3))}")
start = time.time()
print(f"our bound = {err_bound(traincars1, vars, c, eps)}")
print(f"time = {time.time() - start}")

s0 = sps.Uniform('s0', -2.0, 9.0)
s1 = sps.Uniform('s1', -2.0, 9.0)
s2 = sps.Uniform('s2', 0.0, 10.0)
s3 = sps.Uniform('s3', 0.0, 10.0)
s4 = sps.Uniform('s4', 0.0, 10.0)
traincars2 = ((((((((-2.9829300077345002) * s0) + (2.8399180104656203E+01 * s1)) + ((-1.5201325206209998E+02) * s2)) + (3.5623840930436779E+02 * s3)) + ((-2.0636383424191501E+02) * s4)) + 2.1660394157545902E+01))
vars = [s0, s1, s2, s3, s4]
print("TrainCars2")
print(f"PAF bound = {1.04 * (10 ** (-3))}")
start = time.time()
print(f"our bound = {err_bound(traincars2, vars, c, eps)}")
print(f"time = {time.time() - start}")

s0 = sps.Uniform('s0', -3.0, 5.0)
s1 = sps.Uniform('s1', -3.0, 5.0)
s2 = sps.Uniform('s2', -3.0, 5.0)
s3 = sps.Uniform('s3', -6.0, 11.0)
s4 = sps.Uniform('s4', -6.0, 11.0)
s5 = sps.Uniform('s5', -6.0, 11.0)
s6 = sps.Uniform('s6', -6.0, 11.0)
traincars3 = (((((((((-3.7377847506227999E+02) * s0) + (7.0862205220929002E+02 * s1)) + ((-3.7886044910192999E+02) * s2)) + ((-4.5413076942315001E+02) * s3)) + (((-8.7386976105502004E+02) * 1.0) * s4)) + ((3.5911290954487999E+03 * 1.0) * s5)) + (((-2.2921226288533999E+03) * 1.0) * s6))  + 2.9021426298877441E+02)
vars = [s0, s1, s2, s3, s4, s5, s6]
print("TrainCars3")
print(f"PAF bound = {1.75 * (10 ** (-2))}")
start = time.time()
print(f"our bound = {err_bound(traincars3, vars, c, eps)}")
print(f"time = {time.time() - start}")

s0 = sps.Uniform('s0', -2.5, 6.5)
s1 = sps.Uniform('s1', -2.5, 6.5)
s2 = sps.Uniform('s2', -2.5, 6.5)
s3 = sps.Uniform('s3', -2.5, 6.5)
s4 = sps.Uniform('s4', -2, 12)
s5 = sps.Uniform('s5', -2, 12)
s6 = sps.Uniform('s6', -2, 12)
s7 = sps.Uniform('s7', -2, 12)
s8 = sps.Uniform('s8', -2, 12)
traincars4 = (((((((((((-1201.0) * s0) + ((-4876.0) * s1)) + (1.3415999999999998E+04 * s2)) + ((-10484.0) * s3)) + ((-774.0) * s4)) + ((-1.3620000000000002E+04) * s5)) + (10481.0 * s6)) + (20425.0 * s7)) + ((-17815.0) * s8)) + 5.2121094496644555E+03)
vars = [s0, s1, s2, s3, s4, s5, s6, s7, s8]
print("TrainCars4")
print(f"PAF bound = {1.81 * (10 ** (-1))}")
start = time.time()
print(f"our bound = {err_bound(traincars4, vars, c, eps)}")
print(f"time = {time.time() - start}")

x1 = sps.Uniform('x1', -100, 100)
x2 = sps.Uniform('x2', -100, 100)
trid1 = (((x1 - 1) * (x1 - 1)) + (x2 * x1)) - ((x2 - 1) * (x2 - 1))
vars = [x1, x2]
print("Trid1")
print(f"PAF bound = {6.01 * (10 ** (-3))}")
start = time.time()
print(f"our bound = {err_bound(trid1, vars, c, eps)}")
print(f"time = {time.time() - start}")

x1 = sps.Uniform('x1', -100, 100)
x2 = sps.Uniform('x2', -100, 100)
x3 = sps.Uniform('x3', -100, 100)
trid2 = (((((x1 - 1) * (x1 - 1)) + (x2 * x1)) - ((x2 - 1) * (x2 - 1))) + (x3 * x2)) - ((x3 - 1) * (x3 - 1))
vars = [x1, x2, x3]
print("Trid2")
print(f"PAF bound = {1.03 * (10 ** (-2))}")
start = time.time()
print(f"our bound = {err_bound(trid2, vars, c, eps)}")
print(f"time = {time.time() - start}")

x1 = sps.Uniform('x1', -100, 100)
x2 = sps.Uniform('x2', -100, 100)
x3 = sps.Uniform('x3', -100, 100)
x4 = sps.Uniform('x4', -100, 100)
trid3 = (((((((x1 - 1) * (x1 - 1)) + (x2 * x1)) - ((x2 - 1) * (x2 - 1))) + (x3 * x2)) - ((x3 - 1) * (x3 - 1))) + (x4 * x3)) - ((x4 - 1) * (x4 - 1))
vars = [x1, x2, x3, x4]
print("Trid3")
print(f"PAF bound = {1.75 * (10 ** (-2))}")
start = time.time()
print(f"our bound = {err_bound(trid3, vars, c, eps)}")
print(f"time = {time.time() - start}")

x1 = sps.Uniform('x1', -100, 100)
x2 = sps.Uniform('x2', -100, 100)
x3 = sps.Uniform('x3', -100, 100)
x4 = sps.Uniform('x4', -100, 100)
x5 = sps.Uniform('x5', -100, 100)
trid4 = ((((((((((x1 - 1) * (x1 - 1)) + (x2 * x1)) - ((x2 - 1) * (x2 - 1))) + (x3 * x2)) - ((x3 - 1) * (x3 - 1))) + (x4 * x3)) - ((x4 - 1) * (x4 - 1))) + (x5 * x4)) - ((x5 - 1) * (x5 - 1)))
vars = [x1, x2, x3, x4, x5]
print("Trid4")
print(f"PAF bound = {2.69 * (10 ** (-2))}")
start = time.time()
print(f"our bound = {err_bound(trid4, vars, c, eps)}")
print(f"time = {time.time() - start}")