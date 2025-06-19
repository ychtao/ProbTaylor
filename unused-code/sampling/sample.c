// a:U(5, 10), b:U(0, 5), c:U(0, 5)
// (((((2 * a) * a) * a) - (((9 * a) * b) + (27 * c))) / 54) + (((a * a) - (3 * b)) / 9)

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

// Function to sample from a uniform distribution in the range [min, max] for float
float sample_uniform_float(float min, float max) {
    return min + ((float)rand() / RAND_MAX) * (max - min);
}

int main() {
    FILE *file = fopen("errors.txt", "w");
    srand(time(NULL));

    for (int i = 0; i < 100000; i++) {

        float a = sample_uniform_float(5, 10);
        float b = sample_uniform_float(0, 5);
        float c = sample_uniform_float(0, 5);

        float f_single = (((((2 * a) * a) * a) - (((9 * a) * b) + (27 * c))) / 54) + (((a * a) - (3 * b)) / 9);

        double a_d = (double)a;
        double b_d = (double)b;
        double c_d = (double)c;

        double f_double = (((((2 * a_d) * a_d) * a_d) - (((9 * a_d) * b_d) + (27 * c_d))) / 54) + (((a_d * a_d) - (3 * b_d)) / 9);

        double error = f_double - (double)f_single;
        if (i % 10000 == 0) { printf("i = %d\n", i); }
        fprintf(file, "%.15f\n", error);
    }

    return 0;
}