set -euo pipefail

for n in $(seq 25 25 300); do
  python3 ./benchmarks/scalability/dpgen.py "$n"
done

for n in $(seq 25 25 300); do
  ./bin/pt ./benchmarks/scalability/${n}.txt -o ./results/scalability/dpgen_${n}.out --nm --order 2 --er1
done

echo "Done. Results are in ./results/scalability/"