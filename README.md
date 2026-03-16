The input file to ProbTaylor consists of two parts – the variable declarations and an arithmetic expression. Each line of the variable declarations part is in the form of `<variable name>:<distribution>(<lower>, <upper>)`. The distribution can be one of `U`, `N` and `E`, standing for uniform, normal, and Laplace distribution, respectively. The lower and upper value indicates the range of the variable. The arithmetic expression involves only declared variables, and is either a division-free expression, or a fractional expression, where the outermost operator is division. The examples of input files can be found in `/benchmarks`.

To run ProbTaylor, use the following command under root directory: `./bin/pt <benchmark> -o <output> <options>`, where the options can be:

+ `-o <filename>`: generate output at `<filename>`

+ `--nm`: run the NM algorithm

+ `--nmopt`: run the NM algorithm with different analysis orders and output the best result

+ `--cmb`: run the CMB algorithm

+ `--div`: run the extended CMB algorithm for fractional expressions

+ `--order n`: highest analysis order set to `n` in `nmopt` mode; analysis order set to `n` otherwise

+ `--num b`: number of intervals set to `b` in `cmb` or `div` mode

+ `--eps e`: unit round-off set to `e` (default value 2**(-24))

+ `--dlt d`: subnormal unit set to `d` (default value 2**(-126))

+ `--sigma s`: variance of Laplace distribution set to `s` (default value 0.01)

+ `--tri`: analyze second-order error with the brute-force method (default: using GELPIA)

+ `--er1`: analyze first-order error only

Since the dependency GELPIA has not been actively maintained, the whole system only runs on Ubuntu 18.04. To compile the whole system:

1. Under the same directory, git clone from `https://github.com/rospoly/gelpia.git` and put the unzipped ProbTaylor code.

2. Run `cd gelpia`, and then, under the `gelpia` directory, run `make requirements` and then `make`. This step compiles the GELPIA tool.

3. Run `cd ../probtaylor` and then compile ProbTaylor by running `make`.

4. Under the `probtaylor` directory, follow the instructions above to run the tool on benchmarks.
