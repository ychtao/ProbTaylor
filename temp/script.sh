#!/usr/bin/env bash
set -euo pipefail

# Run from repo root: bash temp/script.sh

mkdir -p ./temp

for n in $(seq 25 25 1000); do
  echo "[N=$n] Generating input and running ./bin/pt"
  python3 ./temp/gen.py "$n"
  ./bin/pt ./temp/"$n".in --nm --order 2 --er1 -o ./temp/"$n".out
done

echo "Done. Outputs are in ./temp/"
