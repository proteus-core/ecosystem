#include "riscv_test.h"

#include "test_macros_cap.h"
#include "cheri.h"

RVTEST_RV32U
RVTEST_CODE_BEGIN

    INIT_ROOT_CAP

    # Check otype is correctly set when sealing
    TEST_CASE_START(1)
        SEAL_ROOT(c1, 6) //before 1234, now 6, reduced otype
        CHECK_CAP_NEW_TYPE(c1, ROOT, 6)

    # Check unsealing a capability results in original capability
    TEST_CASE_START(2)
        SEAL_ROOT(c1, 12) //before 1234, now 12, reduced otype
        li t0, 12
        CSetOffset c2, ROOT, t0
        CUnseal c3, c1, c2
        CHECK_CAP_EQ(c3, ROOT)

    # Sealing without permission
    TEST_CASE_START(3)
        li t0, ~(1 << PERM_PERMIT_SEAL)
        CAndPerm c1, ROOT, t0
        CSeal c2, ROOT, c1
        CHECK_TAG(c2, 0)

    # Unsealing without permission
    TEST_CASE_START(4)
        SEAL_ROOT(c1, 5) //before 1234, now 5, reduced otype
        li t0, 5
        CSetOffset c2, ROOT, t0
        li t0, ~(1 << PERM_PERMIT_UNSEAL)
        CAndPerm c2, c2, t0
        CUnseal c3, c1, c2
        CHECK_TAG(c3, 0)

    # Unsealing using wrong otype
    TEST_CASE_START(5)
        SEAL_ROOT(c1, 10) //before 1234, now 10, reduced otype
        li t0, 11
        CSetOffset c2, ROOT, t0
        CUnseal c3, c1, c2
        CHECK_TAG(c3, 0)

    # Unsealing unsealed capability
    TEST_CASE_START(6)
        CMove c1, ROOT
        CUnseal c2, c1, ROOT
        CHECK_TAG(c2, 0)

    TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END
