import sys


def main(argv):
	if len(argv) != 2:
		print("Usage: python3 gen.py N", file=sys.stderr)
		return 2

	try:
		n = int(argv[1])
	except ValueError:
		print("Error: N must be an integer", file=sys.stderr)
		return 2

	if n < 1:
		print("Error: N must be >= 1", file=sys.stderr)
		return 2

	out_name = f"./temp/{n}.in"
	with open(out_name, "w", encoding="utf-8") as f:
		for i in range(1, n + 1):
			f.write(f"x{i}: U(0, 1)\n")
		# final sum line
		sum_expr = " + ".join(f"x{i}" for i in range(1, n + 1))
		f.write(sum_expr + "\n")

	print(f"Wrote {out_name}")
	return 0


if __name__ == "__main__":
	raise SystemExit(main(sys.argv))

