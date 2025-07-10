To run ProbTaylor: `./pt <file_name_of_benchmark> <options>`

Available options:

+ `--nm`: run Naive Markov algorithm
+ `--cmb`: run Central-Moment-Based algorithm
+ `--div`: run extended Central-Moment-Based algorithm for fractional expressions
+ `--order <n>`: run in order `n`
+ `--num <b>`: run with range partition, number of partitions = `b`
+ `--er1`: analyze first-order error threshold only

Analyzing second-order error requires installation of GELPIA.