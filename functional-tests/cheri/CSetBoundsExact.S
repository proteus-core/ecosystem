#include "riscv_test.h"

#include "test_macros_cap.h"
#include "cheri.h"

#define SET_BOUNDS_EXACT(cs, rs_val) \
    li x1, rs_val; \
    CSetBoundsExact c31, cs, x1; \

#define TEST_CSetBoundsExact_NO_CHANGE(testnum, cs, rs_val) \
    TEST_CASE_CAP_EQ(testnum, c31, cs, SET_BOUNDS_EXACT(cs, rs_val))

#define TEST_CSetBoundsExact_NEW_BOUNDS_OFFSET_EXACT(testnum, cs, rs_val, base, len, offset) \
    TEST_CASE_CAP_NEW_BOUNDS_OFFSET(testnum, c31, cs, base, len, offset, SET_BOUNDS_EXACT(cs, rs_val))

#define CHECK_LEN_NOT_EQ(cr, wrong_result) \
    CGetLen x30, cr; \
    li  x29, MASK_XLEN(wrong_result); \
    bne x29, x30, 1f; \
    RESTORE_SAFE_STATE; \
    j fail; \
1:

RVTEST_RV32U
RVTEST_CODE_BEGIN

    CSpecialR c1, ddc;

    TEST_CSetBoundsExact_NEW_BOUNDS_OFFSET_EXACT(1, c1, 4, 0, 4, 0)

    TEST_CASE_FREE(2)
        li x2, 1280
        CSetBoundsExact c2, c1, x2
        CHECK_GETTER(CGetLen, c2, 1280)
        CHECK_TAG(c2, 1)

    TEST_CASE_FREE(3)
        li x2, 1234
        CSetBoundsExact c2, c1, x2
        CHECK_LEN_NOT_EQ(c2, 1234)
        CHECK_TAG(c2, 0)

    TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END