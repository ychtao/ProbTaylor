import sympy as sp
from sympy.printing.str import StrPrinter

# 1. Define a custom printer that prints x^n as x*x*...*x when n is a positive integer
class MultiplyPrinter(StrPrinter):
    def _print_Pow(self, expr):
        base, exp = expr.as_base_exp()
        # If the exponent is a positive integer, print repeated multiplication
        if exp.is_Integer and exp.is_positive:
            return "*".join([self._print(base)] * int(exp))
        # Otherwise, fall back to the default _print_Pow
        return super()._print_Pow(expr)

# 2. Use your existing code to read variables and the expression from the file
with open("e.txt", "r") as file:
    lines = file.readlines()
    
vars = []
line_flag = False
for line in lines:
    line = line.strip()
    if line == "":
        line_flag = True 
        continue
    if line_flag:
        e_str = line
    else:
        vars.append(line)
        
symbols = {var: sp.Symbol(var) for var in vars}
e = sp.sympify(e_str, locals=symbols)
# 3. Get numerator and denominator of the simplified fraction
# num, denom = sp.fraction(e)
num, denom = e.as_numer_denom()
e = sp.simplify(num / denom)
num, denom = sp.fraction(e)

# 4. Convert them to strings using the custom printer
printer = MultiplyPrinter()
num_str = printer.doprint(num)
den_str = printer.doprint(denom)

# 5. Write the "no-exponent" string representations to the file
with open("num_denom.txt", "w") as file:
    file.write(num_str + "\n" + den_str + "\n")
