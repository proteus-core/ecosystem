/*
 * Runs the full CoreMark workload (list, matrix, state-machine) via the
 * embench initialise_benchmark / benchmark / verify_benchmark interface.
 *
 * Seeds: seed1=0, seed2=0, seed3=0x66 (2K performance run).
 * Expected CRC values (seedcrc=0xe9f5, known_id=3, size 666 per algorithm):
 *   crclist   = 0xe714
 *   crcmatrix = 0x1fd7
 *   crcstate  = 0x8e3a
 *
 */
#include "coremark.h"

/* Static memory block shared among the three algorithms */
static ee_u8 static_memblk[TOTAL_DATA_SIZE];

/* Persistent CoreMark state across benchmark() calls */
static core_results res;

/*
 * run_iterate - one pass of all CoreMark algorithms.
 * Adapted from iterate() in the original core_main.c.
 * The list, matrix, and state data are restored to their initial values at
 * the end of each pass, so repeated calls produce consistent results.
 */
static void
run_iterate(void)
{
    ee_u32 i;
    ee_u16 crc;

    res.crc       = 0;
    res.crclist   = 0;
    res.crcmatrix = 0;
    res.crcstate  = 0;

    for (i = 0; i < res.iterations; i++)
    {
        crc      = core_bench_list(&res, 1);
        res.crc  = crcu16(crc, res.crc);
        crc      = core_bench_list(&res, -1);
        res.crc  = crcu16(crc, res.crc);
        if (i == 0)
            res.crclist = res.crc;
    }
}

void __attribute__((noinline))
initialise_benchmark(void)
{
    ee_u32 per_algo = TOTAL_DATA_SIZE / NUM_ALGORITHMS;

    res.seed1      = 0;
    res.seed2      = 0;
    res.seed3      = 0x66;
    res.iterations = 1;
    res.execs      = ALL_ALGORITHMS_MASK;
    res.err        = 0;
    res.size       = per_algo;

    /* Partition the static block among list / matrix / state */
    res.memblock[0] = (void *)static_memblk;
    res.memblock[1] = (char *)res.memblock[0];
    res.memblock[2] = (char *)res.memblock[0] + per_algo;
    res.memblock[3] = (char *)res.memblock[0] + per_algo * 2;

    res.list = core_list_init(per_algo, res.memblock[1], res.seed1);
    core_init_matrix(per_algo, res.memblock[2],
                     (ee_s32)res.seed1 | (((ee_s32)res.seed2) << 16),
                     &res.mat);
    core_init_state(per_algo, res.seed1, res.memblock[3]);
}

void __attribute__((noinline))
warm_caches(int heat)
{
    int i;
    for (i = 0; i < heat; i++)
        run_iterate();
}

int __attribute__((noinline))
benchmark(void)
{
    run_iterate();
    return (int)res.crc;
}

int __attribute__((noinline))
verify_benchmark(int r)
{
    (void)r;

    /* Known CRC values for 2K performance run (seed1=0, seed2=0, seed3=0x66,
     * 666 bytes per algorithm).  All three are set during the first iteration
     * and do not change with additional iterations, so iterations=1 is fine. */
    if ((res.execs & ID_LIST)   && res.crclist   != (ee_u16)0xe714) return 0;
    if ((res.execs & ID_MATRIX) && res.crcmatrix != (ee_u16)0x1fd7) return 0;
    if ((res.execs & ID_STATE)  && res.crcstate  != (ee_u16)0x8e3a) return 0;

    return 1;
}
