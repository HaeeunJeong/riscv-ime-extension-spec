#ifndef _PARAMS_H_
#define _PARAMS_H_

#include "common.h"

typedef struct Params {
    uint32_t N_SIZE;
    uint32_t M_SIZE;
    uint32_t K_SIZE;
    uint32_t n;
    uint32_t m;
    uint32_t k;
/* int   n_warmup; */
/* int   n_reps; */
}Params;

static void usage() {
    fprintf(stderr,
        "\nUsage:  ./program [options]"
        "\n"
        "\nGeneral options:"
        "\n    -h        help"
        "\n"
        "\nBenchmark-specific options:"
        "\n    -N <N>    size of N (default=1024)"
        "\n    -M <M>    size of M (default=1024)"
        "\n    -K <K>    size of K (default=1024)"
        "\n    -n <n>    number of partitions over N (default=1)"
        "\n    -m <m>    number of partitions over M (default=1)"
        "\n    -k <k>    number of partitions over K (default=1)"
        "\n"
        "\n");
}

struct Params input_params(int argc, char **argv) {
    struct Params p;
    p.N_SIZE    = 1024;
    p.M_SIZE    = p.N_SIZE;
    p.K_SIZE    = p.N_SIZE;
    p.n    = 1;
    p.m    = 1;
    p.k    = 4;

    int opt;
    while((opt = getopt(argc, argv, "hN:M:K:n:m:k:")) >= 0) {
        switch(opt) {
        case 'h':
        usage();
        exit(0);
        break;
        case 'N': p.N_SIZE = atoi(optarg); break;
        case 'M': p.M_SIZE = atoi(optarg); break;
        case 'K': p.K_SIZE = atoi(optarg); break;
        case 'n': p.n = atoi(optarg); break;
        case 'm': p.m = atoi(optarg); break;
        case 'k': p.k = atoi(optarg); break;
        default:
            fprintf(stderr, "\nUnrecognized option!\n");
            usage();
            exit(0);
        }
    }
/* assert(NR_DPUS > 0 && "Invalid # of dpus!"); */

    return p;
}
#endif
