import sys
import sympy as sp
import sympy.stats as sps
import numpy as np

def y_index(i, k):
  if i in range(1, k+1):
    return sp.symbols(f'e{i}')
  elif i in range(k+1, 2*k+1):
    return sp.symbols(f'd{i-k}')
  else:
    return 0
  
def get_r2(tf, k):
  ret = 0
  e_vals = {sp.symbols(f'e{i}') : 0 for i in range (1, k + 1)}
  d_vals = {sp.symbols(f'd{i}') : 0 for i in range (1, k + 1)}
  e_vals_p = {sp.symbols(f'e{i}') : sp.symbols(f'p{i}') for i in range (1, k + 1)}
  d_vals_p = {sp.symbols(f'd{i}') : sp.symbols(f'p{k+k}') for i in range (1, k + 1)}
  for i in range(1, k+1):
    h = sp.diff(tf, sp.symbols(f'd{i}'))
    h = sp.simplify(h.subs(e_vals).subs(d_vals))
    ret += h * sp.symbols(f'd{i}')
  for i in range(1, 2*k+1):
    for j in range(1, 2*k+1):
      yi = y_index(i, k)
      yj = y_index(j, k)
      h = sp.diff(tf, yi, yj)
      h = sp.simplify(h.subs(e_vals_p).subs(d_vals_p))
      ret += 0.5 * h * yi * yj
  return ret

in_file = "benchmarks/" + sys.argv[1] + ".txt"
with open(in_file, "r") as f:
  in_vars = f.readline().strip().split("), ")
  
vars = []
var_names = []
var_ranges = {}
local_dict = {}
for in_var in in_vars:
  in_var += ")"
  var_name, var_range = in_var.split(":")
  var_names.append(var_name)
  params = var_range[var_range.find("(")+1:var_range.find(")")].split(",")
  var_ranges[var_name] = (float(params[0]), float(params[1]))
  exec(f"{var_name} = sp.symbols(\'{var_name}\')")
  vars.append(eval(var_name))
  local_dict[var_name] = eval(var_name)
  
with open('tilde.txt', 'r') as file:
  stf = file.readline().strip()
  sk = file.readline().strip()
  
tf = sp.sympify(stf, locals = local_dict)
k = int(sk)

print(tf)
print(get_r2(tf, k))

  
  
