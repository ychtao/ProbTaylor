set -euo pipefail

./bin/pt ./benchmarks/poly_u/bsplines0.txt -o ./results/poly_u_cmb/bsplines0.out --cmb --order 4 --num 8 --er1
./bin/pt ./benchmarks/poly_u/bsplines1.txt -o ./results/poly_u_cmb/bsplines1.out --cmb --order 4 --num 8 --er1
./bin/pt ./benchmarks/poly_u/bsplines2.txt -o ./results/poly_u_cmb/bsplines2.out --cmb --order 4 --num 8 --er1
./bin/pt ./benchmarks/poly_u/bsplines3.txt -o ./results/poly_u_cmb/bsplines3.out --cmb --order 4 --num 8 --er1
./bin/pt ./benchmarks/poly_u/ClassIDs0.txt -o ./results/poly_u_cmb/ClassIDs0.out --cmb --order 4 --num 1 --er1
./bin/pt ./benchmarks/poly_u/ClassIDs1.txt -o ./results/poly_u_cmb/ClassIDs1.out --cmb --order 4 --num 1 --er1
./bin/pt ./benchmarks/poly_u/ClassIDs2.txt -o ./results/poly_u_cmb/ClassIDs2.out --cmb --order 4 --num 1 --er1
./bin/pt ./benchmarks/poly_u/Filters1.txt -o ./results/poly_u_cmb/Filters1.out --cmb --order 4 --num 8 --er1  
./bin/pt ./benchmarks/poly_u/Filters2.txt -o ./results/poly_u_cmb/Filters2.out --cmb --order 4 --num 8 --er1
./bin/pt ./benchmarks/poly_u/Filters3.txt -o ./results/poly_u_cmb/Filters3.out --cmb --order 4 --num 8 --er1
./bin/pt ./benchmarks/poly_u/Filters4.txt -o ./results/poly_u_cmb/Filters4.out --cmb --order 4 --num 1 --er1
./bin/pt ./benchmarks/poly_u/RigidBody1.txt -o ./results/poly_u_cmb/RigidBody1.out --cmb --order 4 --num 8 --er1
./bin/pt ./benchmarks/poly_u/RigidBody2.txt -o ./results/poly_u_cmb/RigidBody2.out --cmb --order 4 --num 1 --er1
./bin/pt ./benchmarks/poly_u/Sine.txt -o ./results/poly_u_cmb/Sine.out --cmb --order 4 --num 8 --er1
./bin/pt ./benchmarks/poly_u/SolveCubic.txt -o ./results/poly_u_cmb/SolveCubic.out --cmb --order 4 --num 8 --er1
./bin/pt ./benchmarks/poly_u/Sqrt.txt -o ./results/poly_u_cmb/Sqrt.out --cmb --order 4 --num 8 --er1
./bin/pt ./benchmarks/poly_u/Traincars1.txt -o ./results/poly_u_cmb/Traincars1.out --cmb --order 4 --num 8 --er1
./bin/pt ./benchmarks/poly_u/Traincars2.txt -o ./results/poly_u_cmb/Traincars2.out --cmb --order 4 --num 1 --er1
./bin/pt ./benchmarks/poly_u/Traincars3.txt -o ./results/poly_u_cmb/Traincars3.out --cmb --order 4 --num 1 --er1
./bin/pt ./benchmarks/poly_u/Traincars4.txt -o ./results/poly_u_cmb/Traincars4.out --cmb --order 4 --num 1 --er1
./bin/pt ./benchmarks/poly_u/Trid.txt -o ./results/poly_u_cmb/Trid.out --cmb --order 4 --num 8 --er1
./bin/pt ./benchmarks/poly_u/Trid2.txt -o ./results/poly_u_cmb/Trid2.out --cmb --order 4 --num 1 --er1
./bin/pt ./benchmarks/poly_u/Trid3.txt -o ./results/poly_u_cmb/Trid3.out --cmb --order 4 --num 1 --er1
./bin/pt ./benchmarks/poly_u/Trid4.txt -o ./results/poly_u_cmb/Trid4.out --cmb --order 4 --num 1 --er1
./bin/pt ./benchmarks/poly_u/ksin.txt -o ./results/poly_u_cmb/ksin.out --cmb --order 4 --num 1 --er1
./bin/pt ./benchmarks/poly_u/kcos.txt -o ./results/poly_u_cmb/kcos.out --cmb --order 4 --num 1 --er1

./bin/pt ./benchmarks/poly_n/bsplines0.txt -o ./results/poly_n_cmb/bsplines0.out --cmb --order 4 --num 8 --er1
./bin/pt ./benchmarks/poly_n/bsplines1.txt -o ./results/poly_n_cmb/bsplines1.out --cmb --order 4 --num 8 --er1
./bin/pt ./benchmarks/poly_n/bsplines2.txt -o ./results/poly_n_cmb/bsplines2.out --cmb --order 4 --num 8 --er1
./bin/pt ./benchmarks/poly_n/bsplines3.txt -o ./results/poly_n_cmb/bsplines3.out --cmb --order 4 --num 8 --er1
./bin/pt ./benchmarks/poly_n/ClassIDs0.txt -o ./results/poly_n_cmb/ClassIDs0.out --cmb --order 4 --num 1 --er1
./bin/pt ./benchmarks/poly_n/ClassIDs1.txt -o ./results/poly_n_cmb/ClassIDs1.out --cmb --order 4 --num 1 --er1
./bin/pt ./benchmarks/poly_n/ClassIDs2.txt -o ./results/poly_n_cmb/ClassIDs2.out --cmb --order 4 --num 1 --er1
./bin/pt ./benchmarks/poly_n/Filters1.txt -o ./results/poly_n_cmb/Filters1.out --cmb --order 4 --num 8 --er1  
./bin/pt ./benchmarks/poly_n/Filters2.txt -o ./results/poly_n_cmb/Filters2.out --cmb --order 4 --num 8 --er1
./bin/pt ./benchmarks/poly_n/Filters3.txt -o ./results/poly_n_cmb/Filters3.out --cmb --order 4 --num 8 --er1
./bin/pt ./benchmarks/poly_n/Filters4.txt -o ./results/poly_n_cmb/Filters4.out --cmb --order 4 --num 1 --er1
./bin/pt ./benchmarks/poly_n/RigidBody1.txt -o ./results/poly_n_cmb/RigidBody1.out --cmb --order 4 --num 8 --er1
./bin/pt ./benchmarks/poly_n/RigidBody2.txt -o ./results/poly_n_cmb/RigidBody2.out --cmb --order 4 --num 1 --er1
./bin/pt ./benchmarks/poly_n/Sine.txt -o ./results/poly_n_cmb/Sine.out --cmb --order 4 --num 8 --er1
./bin/pt ./benchmarks/poly_n/SolveCubic.txt -o ./results/poly_n_cmb/SolveCubic.out --cmb --order 4 --num 8 --er1
./bin/pt ./benchmarks/poly_n/Sqrt.txt -o ./results/poly_n_cmb/Sqrt.out --cmb --order 4 --num 8 --er1
./bin/pt ./benchmarks/poly_n/Traincars1.txt -o ./results/poly_n_cmb/Traincars1.out --cmb --order 4 --num 8 --er1
./bin/pt ./benchmarks/poly_n/Traincars2.txt -o ./results/poly_n_cmb/Traincars2.out --cmb --order 4 --num 1 --er1
./bin/pt ./benchmarks/poly_n/Traincars3.txt -o ./results/poly_n_cmb/Traincars3.out --cmb --order 4 --num 1 --er1
./bin/pt ./benchmarks/poly_n/Traincars4.txt -o ./results/poly_n_cmb/Traincars4.out --cmb --order 4 --num 1 --er1
./bin/pt ./benchmarks/poly_n/Trid.txt -o ./results/poly_n_cmb/Trid.out --cmb --order 4 --num 8 --er1
./bin/pt ./benchmarks/poly_n/Trid2.txt -o ./results/poly_n_cmb/Trid2.out --cmb --order 4 --num 1 --er1
./bin/pt ./benchmarks/poly_n/Trid3.txt -o ./results/poly_n_cmb/Trid3.out --cmb --order 4 --num 1 --er1
./bin/pt ./benchmarks/poly_n/Trid4.txt -o ./results/poly_n_cmb/Trid4.out --cmb --order 4 --num 1 --er1
./bin/pt ./benchmarks/poly_n/ksin.txt -o ./results/poly_n_cmb/ksin.out --cmb --order 4 --num 1 --er1
./bin/pt ./benchmarks/poly_n/kcos.txt -o ./results/poly_n_cmb/kcos.out --cmb --order 4 --num 1 --er1

./bin/pt ./benchmarks/poly_e/bsplines0.txt -o ./results/poly_ewide_cmb/bsplines0.out --cmb --order 4 --num 8 --er1 --sigma 1
./bin/pt ./benchmarks/poly_e/bsplines1.txt -o ./results/poly_ewide_cmb/bsplines1.out --cmb --order 4 --num 8 --er1 --sigma 1
./bin/pt ./benchmarks/poly_e/bsplines2.txt -o ./results/poly_ewide_cmb/bsplines2.out --cmb --order 4 --num 8 --er1 --sigma 1
./bin/pt ./benchmarks/poly_e/bsplines3.txt -o ./results/poly_ewide_cmb/bsplines3.out --cmb --order 4 --num 8 --er1 --sigma 1
./bin/pt ./benchmarks/poly_e/ClassIDs0.txt -o ./results/poly_ewide_cmb/ClassIDs0.out --cmb --order 4 --num 1 --er1 --sigma 1
./bin/pt ./benchmarks/poly_e/ClassIDs1.txt -o ./results/poly_ewide_cmb/ClassIDs1.out --cmb --order 4 --num 1 --er1 --sigma 1
./bin/pt ./benchmarks/poly_e/ClassIDs2.txt -o ./results/poly_ewide_cmb/ClassIDs2.out --cmb --order 4 --num 1 --er1 --sigma 1
./bin/pt ./benchmarks/poly_e/Filters1.txt -o ./results/poly_ewide_cmb/Filters1.out --cmb --order 4 --num 8 --er1   --sigma 1
./bin/pt ./benchmarks/poly_e/Filters2.txt -o ./results/poly_ewide_cmb/Filters2.out --cmb --order 4 --num 8 --er1 --sigma 1
./bin/pt ./benchmarks/poly_e/Filters3.txt -o ./results/poly_ewide_cmb/Filters3.out --cmb --order 4 --num 8 --er1 --sigma 1
./bin/pt ./benchmarks/poly_e/Filters4.txt -o ./results/poly_ewide_cmb/Filters4.out --cmb --order 4 --num 1 --er1 --sigma 1
./bin/pt ./benchmarks/poly_e/RigidBody1.txt -o ./results/poly_ewide_cmb/RigidBody1.out --cmb --order 4 --num 8 --er1 --sigma 1
./bin/pt ./benchmarks/poly_e/RigidBody2.txt -o ./results/poly_ewide_cmb/RigidBody2.out --cmb --order 4 --num 1 --er1 --sigma 1
./bin/pt ./benchmarks/poly_e/Sine.txt -o ./results/poly_ewide_cmb/Sine.out --cmb --order 4 --num 8 --er1 --sigma 1
./bin/pt ./benchmarks/poly_e/SolveCubic.txt -o ./results/poly_ewide_cmb/SolveCubic.out --cmb --order 4 --num 8 --er1 --sigma 1
./bin/pt ./benchmarks/poly_e/Sqrt.txt -o ./results/poly_ewide_cmb/Sqrt.out --cmb --order 4 --num 8 --er1 --sigma 1
./bin/pt ./benchmarks/poly_e/Traincars1.txt -o ./results/poly_ewide_cmb/Traincars1.out --cmb --order 4 --num 8 --er1 --sigma 1
./bin/pt ./benchmarks/poly_e/Traincars2.txt -o ./results/poly_ewide_cmb/Traincars2.out --cmb --order 4 --num 1 --er1 --sigma 1
./bin/pt ./benchmarks/poly_e/Traincars3.txt -o ./results/poly_ewide_cmb/Traincars3.out --cmb --order 4 --num 1 --er1 --sigma 1
./bin/pt ./benchmarks/poly_e/Traincars4.txt -o ./results/poly_ewide_cmb/Traincars4.out --cmb --order 4 --num 1 --er1 --sigma 1
./bin/pt ./benchmarks/poly_e/Trid.txt -o ./results/poly_ewide_cmb/Trid.out --cmb --order 4 --num 8 --er1 --sigma 1
./bin/pt ./benchmarks/poly_e/Trid2.txt -o ./results/poly_ewide_cmb/Trid2.out --cmb --order 4 --num 1 --er1 --sigma 1
./bin/pt ./benchmarks/poly_e/Trid3.txt -o ./results/poly_ewide_cmb/Trid3.out --cmb --order 4 --num 1 --er1 --sigma 1
./bin/pt ./benchmarks/poly_e/Trid4.txt -o ./results/poly_ewide_cmb/Trid4.out --cmb --order 4 --num 1 --er1 --sigma 1
./bin/pt ./benchmarks/poly_e/ksin.txt -o ./results/poly_ewide_cmb/ksin.out --cmb --order 4 --num 1 --er1 --sigma 1
./bin/pt ./benchmarks/poly_e/kcos.txt -o ./results/poly_ewide_cmb/kcos.out --cmb --order 4 --num 1 --er1 --sigma 1

./bin/pt ./benchmarks/poly_e/bsplines0.txt -o ./results/poly_e_cmb/bsplines0.out --cmb --order 4 --num 8 --er1
./bin/pt ./benchmarks/poly_e/bsplines1.txt -o ./results/poly_e_cmb/bsplines1.out --cmb --order 4 --num 8 --er1
./bin/pt ./benchmarks/poly_e/bsplines2.txt -o ./results/poly_e_cmb/bsplines2.out --cmb --order 4 --num 8 --er1
./bin/pt ./benchmarks/poly_e/bsplines3.txt -o ./results/poly_e_cmb/bsplines3.out --cmb --order 4 --num 8 --er1
./bin/pt ./benchmarks/poly_e/ClassIDs0.txt -o ./results/poly_e_cmb/ClassIDs0.out --cmb --order 4 --num 1 --er1
./bin/pt ./benchmarks/poly_e/ClassIDs1.txt -o ./results/poly_e_cmb/ClassIDs1.out --cmb --order 4 --num 1 --er1
./bin/pt ./benchmarks/poly_e/ClassIDs2.txt -o ./results/poly_e_cmb/ClassIDs2.out --cmb --order 4 --num 1 --er1
./bin/pt ./benchmarks/poly_e/Filters1.txt -o ./results/poly_e_cmb/Filters1.out --cmb --order 4 --num 8 --er1  
./bin/pt ./benchmarks/poly_e/Filters2.txt -o ./results/poly_e_cmb/Filters2.out --cmb --order 4 --num 8 --er1
./bin/pt ./benchmarks/poly_e/Filters3.txt -o ./results/poly_e_cmb/Filters3.out --cmb --order 4 --num 8 --er1
./bin/pt ./benchmarks/poly_e/Filters4.txt -o ./results/poly_e_cmb/Filters4.out --cmb --order 4 --num 1 --er1
./bin/pt ./benchmarks/poly_e/RigidBody1.txt -o ./results/poly_e_cmb/RigidBody1.out --cmb --order 4 --num 8 --er1
./bin/pt ./benchmarks/poly_e/RigidBody2.txt -o ./results/poly_e_cmb/RigidBody2.out --cmb --order 4 --num 1 --er1
./bin/pt ./benchmarks/poly_e/Sine.txt -o ./results/poly_e_cmb/Sine.out --cmb --order 4 --num 8 --er1
./bin/pt ./benchmarks/poly_e/SolveCubic.txt -o ./results/poly_e_cmb/SolveCubic.out --cmb --order 4 --num 8 --er1
./bin/pt ./benchmarks/poly_e/Sqrt.txt -o ./results/poly_e_cmb/Sqrt.out --cmb --order 4 --num 8 --er1
./bin/pt ./benchmarks/poly_e/Traincars1.txt -o ./results/poly_e_cmb/Traincars1.out --cmb --order 4 --num 8 --er1
./bin/pt ./benchmarks/poly_e/Traincars2.txt -o ./results/poly_e_cmb/Traincars2.out --cmb --order 4 --num 1 --er1
./bin/pt ./benchmarks/poly_e/Traincars3.txt -o ./results/poly_e_cmb/Traincars3.out --cmb --order 4 --num 1 --er1
./bin/pt ./benchmarks/poly_e/Traincars4.txt -o ./results/poly_e_cmb/Traincars4.out --cmb --order 4 --num 1 --er1
./bin/pt ./benchmarks/poly_e/Trid.txt -o ./results/poly_e_cmb/Trid.out --cmb --order 4 --num 8 --er1
./bin/pt ./benchmarks/poly_e/Trid2.txt -o ./results/poly_e_cmb/Trid2.out --cmb --order 4 --num 1 --er1
./bin/pt ./benchmarks/poly_e/Trid3.txt -o ./results/poly_e_cmb/Trid3.out --cmb --order 4 --num 1 --er1
./bin/pt ./benchmarks/poly_e/Trid4.txt -o ./results/poly_e_cmb/Trid4.out --cmb --order 4 --num 1 --er1
./bin/pt ./benchmarks/poly_e/ksin.txt -o ./results/poly_e_cmb/ksin.out --cmb --order 4 --num 1 --er1
./bin/pt ./benchmarks/poly_e/kcos.txt -o ./results/poly_e_cmb/kcos.out --cmb --order 4 --num 1 --er1