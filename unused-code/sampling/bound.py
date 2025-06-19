import numpy as np
import matplotlib.pyplot as plt

errors = []

with open("errors.txt", 'r') as file:
  for line in file:
    errors.append(abs(float(line.strip())))

# mean = np.mean(errors)
# print(mean)

errors_sorted = np.sort(errors)
print(errors_sorted[int(len(errors_sorted) * 0.99)])