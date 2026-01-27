import sys

N = int(sys.argv[1])
lb = 0
ub = 1
filename = "./benchmarks/scalability/" + sys.argv[1] + ".txt"

f = open(filename, "w")

for i in range(1, N+1):
  f.write("x{}:U({},{})\n".format(i, lb, ub))
  f.write("y{}:U({},{})\n".format(i, lb, ub))
  
expr = ""
for i in range(1, N+1):
  if i>1:
    expr += " + x{} * y{}".format(i, i)
  else:
    expr += "x{} * y{}".format(i, i)
f.write(expr)
