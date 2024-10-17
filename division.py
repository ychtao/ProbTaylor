import sympy as sp
import sympy.stats as sps
import numpy as np
from functools import reduce
import time



x = sps.Uniform("x", 1, 2)
y = sps.Uniform("y", 1, 2)
f = x / (x + y)