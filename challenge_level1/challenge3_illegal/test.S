# See https://gitlab.com/vyoma_systems/common/-/blob/main/LICENSE.vyoma for more details
 
#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV64M
RVTEST_CODE_BEGIN

  .align 2
  .option norvc

  li TESTNUM, 2
illegal_instruction:
  .word 0              
  j fail
  
  .align 8
  .global mtvec_handler
mtvec_handler:
  li t1, CAUSE_ILLEGAL_INSTRUCTION
  csrr t0, mcause
  bne t0, t1, fail
  csrr t0, mepc               # mepc should point to illegal_instruction
  la t1, illegal_instruction  # load actual address of illegal_instruction
  bne t0, t1, fail            # check that cause for trap was our illegal instruction
  la t0, test_end             # load address of test_end
  csrw mepc, t0;              # set mepc to test_end, to pass test
  mret


test_end:

TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END