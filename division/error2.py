import sys
import sympy as sp
import sympy.stats as sps
import numpy as np







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

  
  
