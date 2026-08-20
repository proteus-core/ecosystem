/*
 * Timing is handled by the embench boardsupport (start_trigger/stop_trigger),
 * so we only need seed variables and portable_init/fini here.
 */
#include "coremark.h"
#include "core_portme.h"

/* Performance run seeds: seed1=0, seed2=0, seed3=0x66 */
#if VALIDATION_RUN
volatile ee_s32 seed1_volatile = 0x3415;
volatile ee_s32 seed2_volatile = 0x3415;
volatile ee_s32 seed3_volatile = 0x66;
#endif
#if PERFORMANCE_RUN
volatile ee_s32 seed1_volatile = 0x0;
volatile ee_s32 seed2_volatile = 0x0;
volatile ee_s32 seed3_volatile = 0x66;
#endif
#if PROFILE_RUN
volatile ee_s32 seed1_volatile = 0x8;
volatile ee_s32 seed2_volatile = 0x8;
volatile ee_s32 seed3_volatile = 0x8;
#endif
/* seed4 (iterations) and seed5 (execs) are not used; driver hardcodes them */
volatile ee_s32 seed4_volatile = 1;
volatile ee_s32 seed5_volatile = 0;

ee_u32 default_num_contexts = 1;

void
portable_init(core_portable *p, int *argc, char *argv[])
{
    (void)argc;
    (void)argv;
    p->portable_id = 1;
}

void
portable_fini(core_portable *p)
{
    p->portable_id = 0;
}
