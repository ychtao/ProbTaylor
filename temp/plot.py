#!/usr/bin/env python3
"""Read `N.out` files (N = 25,50,...,500), extract the 1st-order threshold
values into a list `thres`, and plot thres vs N as a line plot.

Run from the repository root:
  python3 temp/plot.py

This will save a plot image at `temp/thres.png` and also print the `N` and
`thres` lists.
"""

import re
from pathlib import Path
import matplotlib.pyplot as plt


def extract_threshold(text: str):
	for line in text.splitlines():
		if '1st-order' in line and 'threshold' in line:
			if '=' not in line:
				return None
			_after = line.split('=', 1)[1].strip()
			if not _after:
				return None
			tok = _after.split()[0]
			try:
				return float(tok)
			except ValueError:
				return None
	return None


def main():
	root = Path(__file__).resolve().parent
	# target Ns: 25,50,...,500
	Ns = list(range(25, 501, 25))
	thres = []
	got_N = []

	for n in Ns:
		p = root / f"{n}.out"
		if not p.exists():
			print(f"Warning: {p} not found, skipping")
			continue
		text = p.read_text(encoding='utf-8')
		val = extract_threshold(text)
		if val is None:
			print(f"Warning: threshold not found in {p}, skipping")
			continue
		got_N.append(n)
		thres.append(val)

	if not thres:
		print("No threshold values found. Exiting.")
		return

	print("Ns:", got_N)
	print("thres:", thres)

	# Plot
	plt.figure(figsize=(8, 5))
	plt.plot(got_N, thres, marker='o')
	plt.xlabel('N')
	plt.ylabel('1st-order error threshold')
	plt.title('1st-order error threshold vs N')
	plt.grid(True)
	out_img = root / 'thres.png'
	plt.savefig(out_img, dpi=150)
	print(f"Saved plot to {out_img}")
	# try:
	# 	plt.show()
	# except Exception:
	# 	# In headless environments this may fail; we already saved the image.
	# 	pass


if __name__ == '__main__':
	main()

