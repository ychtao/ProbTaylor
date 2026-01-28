set -euo pipefail

./bin/pt ./benchmarks/div_u/nonlin1.txt -o ./results/div_u_cmb/nonlin1.out --div --order 2 --num 16 --er1
./bin/pt ./benchmarks/div_u/nonlin2.txt -o ./results/div_u_cmb/nonlin2.out --div --order 2 --num 16 --er1
./bin/pt ./benchmarks/div_u/predatorPrey.txt -o ./results/div_u_cmb/predatorPrey.out --div --order 2 --num 16 --er1
./bin/pt ./benchmarks/div_u/verhulst.txt -o ./results/div_u_cmb/verhulst.out --div --order 2 --num 16 --er1

./bin/pt ./benchmarks/div_n/nonlin1.txt -o ./results/div_n_cmb/nonlin1.out --div --order 2 --num 16 --er1
./bin/pt ./benchmarks/div_n/nonlin2.txt -o ./results/div_n_cmb/nonlin2.out --div --order 2 --num 16 --er1
./bin/pt ./benchmarks/div_n/predatorPrey.txt -o ./results/div_n_cmb/predatorPrey.out --div --order 2 --num 16 --er1
./bin/pt ./benchmarks/div_n/verhulst.txt -o ./results/div_n_cmb/verhulst.out --div --order 2 --num 16 --er1

./bin/pt ./benchmarks/div_e/nonlin1.txt -o ./results/div_e_cmb/nonlin1.out --div --order 2 --num 16 --er1 --sigma 1
./bin/pt ./benchmarks/div_e/nonlin2.txt -o ./results/div_e_cmb/nonlin2.out --div --order 2 --num 16 --er1 --sigma 1
./bin/pt ./benchmarks/div_e/predatorPrey.txt -o ./results/div_e_cmb/predatorPrey.out --div --order 2 --num 16 --er1 --sigma 1
./bin/pt ./benchmarks/div_e/verhulst.txt -o ./results/div_e_cmb/verhulst.out --div --order 2 --num 16 --er1 --sigma 1

./bin/pt ./benchmarks/div_u/doppler1.txt -o ./results/div_u_cmb/doppler1.out --div --order 2 --num 16 --er1
./bin/pt ./benchmarks/div_u/doppler1.txt -o ./results/div_u_cmb/doppler2.out --div --order 2 --num 16 --er1
./bin/pt ./benchmarks/div_u/doppler1.txt -o ./results/div_u_cmb/doppler3.out --div --order 2 --num 16 --er1