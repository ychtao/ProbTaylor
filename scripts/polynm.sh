# Minimal polynm.sh: run a single fixed benchmark and write a fixed result file.
# Run this from the repo root as: ./scripts/polynm.sh

#!/usr/bin/env bash
# set -euo pipefail

# Minimal script that runs a fixed list of experiments.
# Run from the repository root as: ./scripts/polynm.sh


./bin/pt ./benchmarks/poly_u/bsplines0.txt -o ./results/poly_u_nm/bsplines0.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_u/bsplines1.txt -o ./results/poly_u_nm/bsplines1.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_u/bsplines2.txt -o ./results/poly_u_nm/bsplines2.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_u/bsplines3.txt -o ./results/poly_u_nm/bsplines3.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_u/ClassIDs0.txt -o ./results/poly_u_nm/ClassIDs0.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_u/ClassIDs1.txt -o ./results/poly_u_nm/ClassIDs1.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_u/ClassIDs2.txt -o ./results/poly_u_nm/ClassIDs2.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_u/Filters1.txt -o ./results/poly_u_nm/Filters1.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_u/Filters2.txt -o ./results/poly_u_nm/Filters2.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_u/Filters3.txt -o ./results/poly_u_nm/Filters3.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_u/Filters4.txt -o ./results/poly_u_nm/Filters4.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_u/RigidBody1.txt -o ./results/poly_u_nm/RigidBody1.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_u/RigidBody2.txt -o ./results/poly_u_nm/RigidBody2.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_u/Sine.txt -o ./results/poly_u_nm/Sine.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_u/SolveCubic.txt -o ./results/poly_u_nm/SolveCubic.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_u/Sqrt.txt -o ./results/poly_u_nm/Sqrt.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_u/Traincars1.txt -o ./results/poly_u_nm/Traincars1.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_u/Traincars2.txt -o ./results/poly_u_nm/Traincars2.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_u/Traincars3.txt -o ./results/poly_u_nm/Traincars3.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_u/Traincars4.txt -o ./results/poly_u_nm/Traincars4.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_u/Trid.txt -o ./results/poly_u_nm/Trid.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_u/Trid2.txt -o ./results/poly_u_nm/Trid2.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_u/Trid3.txt -o ./results/poly_u_nm/Trid3.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_u/Trid4.txt -o ./results/poly_u_nm/Trid4.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_u/ksin.txt -o ./results/poly_u_nm/ksin.out --nmopt --order 36 --tri
./bin/pt ./benchmarks/poly_u/kcos.txt -o ./results/poly_u_nm/kcos.out --nmopt --order 36 --tri

./bin/pt ./benchmarks/poly_n/bsplines0.txt -o ./results/poly_n_nm/bsplines0.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_n/bsplines1.txt -o ./results/poly_n_nm/bsplines1.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_n/bsplines2.txt -o ./results/poly_n_nm/bsplines2.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_n/bsplines3.txt -o ./results/poly_n_nm/bsplines3.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_n/ClassIDs0.txt -o ./results/poly_n_nm/ClassIDs0.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_n/ClassIDs1.txt -o ./results/poly_n_nm/ClassIDs1.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_n/ClassIDs2.txt -o ./results/poly_n_nm/ClassIDs2.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_n/Filters1.txt -o ./results/poly_n_nm/Filters1.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_n/Filters2.txt -o ./results/poly_n_nm/Filters2.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_n/Filters3.txt -o ./results/poly_n_nm/Filters3.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_n/Filters4.txt -o ./results/poly_n_nm/Filters4.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_n/RigidBody1.txt -o ./results/poly_n_nm/RigidBody1.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_n/RigidBody2.txt -o ./results/poly_n_nm/RigidBody2.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_n/Sine.txt -o ./results/poly_n_nm/Sine.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_n/SolveCubic.txt -o ./results/poly_n_nm/SolveCubic.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_n/Sqrt.txt -o ./results/poly_n_nm/Sqrt.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_n/Traincars1.txt -o ./results/poly_n_nm/Traincars1.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_n/Traincars2.txt -o ./results/poly_n_nm/Traincars2.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_n/Traincars3.txt -o ./results/poly_n_nm/Traincars3.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_n/Traincars4.txt -o ./results/poly_n_nm/Traincars4.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_n/Trid.txt -o ./results/poly_n_nm/Trid.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_n/Trid2.txt -o ./results/poly_n_nm/Trid2.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_n/Trid3.txt -o ./results/poly_n_nm/Trid3.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_n/Trid4.txt -o ./results/poly_n_nm/Trid4.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_n/ksin.txt -o ./results/poly_n_nm/ksin.out --nmopt --order 36 --tri
./bin/pt ./benchmarks/poly_n/kcos.txt -o ./results/poly_n_nm/kcos.out --nmopt --order 36 --tri

./bin/pt ./benchmarks/poly_e/bsplines0.txt -o ./results/poly_ewide_nm/bsplines0.out --nmopt --order 36  --sigma 1
./bin/pt ./benchmarks/poly_e/bsplines1.txt -o ./results/poly_ewide_nm/bsplines1.out --nmopt --order 36  --sigma 1
./bin/pt ./benchmarks/poly_e/bsplines2.txt -o ./results/poly_ewide_nm/bsplines2.out --nmopt --order 36  --sigma 1
./bin/pt ./benchmarks/poly_e/bsplines3.txt -o ./results/poly_ewide_nm/bsplines3.out --nmopt --order 36  --sigma 1
./bin/pt ./benchmarks/poly_e/ClassIDs0.txt -o ./results/poly_ewide_nm/ClassIDs0.out --nmopt --order 36  --sigma 1
./bin/pt ./benchmarks/poly_e/ClassIDs1.txt -o ./results/poly_ewide_nm/ClassIDs1.out --nmopt --order 36  --sigma 1
./bin/pt ./benchmarks/poly_e/ClassIDs2.txt -o ./results/poly_ewide_nm/ClassIDs2.out --nmopt --order 36  --sigma 1
./bin/pt ./benchmarks/poly_e/Filters1.txt -o ./results/poly_ewide_nm/Filters1.out --nmopt --order 36  --sigma 1
./bin/pt ./benchmarks/poly_e/Filters2.txt -o ./results/poly_ewide_nm/Filters2.out --nmopt --order 36  --sigma 1
./bin/pt ./benchmarks/poly_e/Filters3.txt -o ./results/poly_ewide_nm/Filters3.out --nmopt --order 36  --sigma 1
./bin/pt ./benchmarks/poly_e/Filters4.txt -o ./results/poly_ewide_nm/Filters4.out --nmopt --order 36  --sigma 1
./bin/pt ./benchmarks/poly_e/RigidBody1.txt -o ./results/poly_ewide_nm/RigidBody1.out --nmopt --order 36  --sigma 1
./bin/pt ./benchmarks/poly_e/RigidBody2.txt -o ./results/poly_ewide_nm/RigidBody2.out --nmopt --order 36  --sigma 1
./bin/pt ./benchmarks/poly_e/Sine.txt -o ./results/poly_ewide_nm/Sine.out --nmopt --order 36  --sigma 1
./bin/pt ./benchmarks/poly_e/SolveCubic.txt -o ./results/poly_ewide_nm/SolveCubic.out --nmopt --order 36  --sigma 1
./bin/pt ./benchmarks/poly_e/Sqrt.txt -o ./results/poly_ewide_nm/Sqrt.out --nmopt --order 36  --sigma 1
./bin/pt ./benchmarks/poly_e/Traincars1.txt -o ./results/poly_ewide_nm/Traincars1.out --nmopt --order 36  --sigma 1
./bin/pt ./benchmarks/poly_e/Traincars2.txt -o ./results/poly_ewide_nm/Traincars2.out --nmopt --order 36  --sigma 1
./bin/pt ./benchmarks/poly_e/Traincars3.txt -o ./results/poly_ewide_nm/Traincars3.out --nmopt --order 36  --sigma 1
./bin/pt ./benchmarks/poly_e/Traincars4.txt -o ./results/poly_ewide_nm/Traincars4.out --nmopt --order 36  --sigma 1
./bin/pt ./benchmarks/poly_e/Trid.txt -o ./results/poly_ewide_nm/Trid.out --nmopt --order 36  --sigma 1
./bin/pt ./benchmarks/poly_e/Trid2.txt -o ./results/poly_ewide_nm/Trid2.out --nmopt --order 36  --sigma 1
./bin/pt ./benchmarks/poly_e/Trid3.txt -o ./results/poly_ewide_nm/Trid3.out --nmopt --order 36  --sigma 1
./bin/pt ./benchmarks/poly_e/Trid4.txt -o ./results/poly_ewide_nm/Trid4.out --nmopt --order 36  --sigma 1
./bin/pt ./benchmarks/poly_e/ksin.txt -o ./results/poly_ewide_nm/ksin.out --nmopt --order 36  --sigma 1 --tri
./bin/pt ./benchmarks/poly_e/kcos.txt -o ./results/poly_ewide_nm/kcos.out --nmopt --order 36  --sigma 1 --tri

./bin/pt ./benchmarks/poly_e/bsplines0.txt -o ./results/poly_e_nm/bsplines0.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_e/bsplines1.txt -o ./results/poly_e_nm/bsplines1.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_e/bsplines2.txt -o ./results/poly_e_nm/bsplines2.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_e/bsplines3.txt -o ./results/poly_e_nm/bsplines3.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_e/ClassIDs0.txt -o ./results/poly_e_nm/ClassIDs0.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_e/ClassIDs1.txt -o ./results/poly_e_nm/ClassIDs1.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_e/ClassIDs2.txt -o ./results/poly_e_nm/ClassIDs2.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_e/Filters1.txt -o ./results/poly_e_nm/Filters1.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_e/Filters2.txt -o ./results/poly_e_nm/Filters2.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_e/Filters3.txt -o ./results/poly_e_nm/Filters3.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_e/Filters4.txt -o ./results/poly_e_nm/Filters4.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_e/RigidBody1.txt -o ./results/poly_e_nm/RigidBody1.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_e/RigidBody2.txt -o ./results/poly_e_nm/RigidBody2.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_e/Sine.txt -o ./results/poly_e_nm/Sine.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_e/SolveCubic.txt -o ./results/poly_e_nm/SolveCubic.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_e/Sqrt.txt -o ./results/poly_e_nm/Sqrt.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_e/Traincars1.txt -o ./results/poly_e_nm/Traincars1.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_e/Traincars2.txt -o ./results/poly_e_nm/Traincars2.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_e/Traincars3.txt -o ./results/poly_e_nm/Traincars3.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_e/Traincars4.txt -o ./results/poly_e_nm/Traincars4.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_e/Trid.txt -o ./results/poly_e_nm/Trid.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_e/Trid2.txt -o ./results/poly_e_nm/Trid2.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_e/Trid3.txt -o ./results/poly_e_nm/Trid3.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_e/Trid4.txt -o ./results/poly_e_nm/Trid4.out --nmopt --order 36 
./bin/pt ./benchmarks/poly_e/ksin.txt -o ./results/poly_e_nm/ksin.out --nmopt --order 36 --tri
./bin/pt ./benchmarks/poly_e/kcos.txt -o ./results/poly_e_nm/kcos.out --nmopt --order 36 --tri

echo "Done. Results are in ./results/"
