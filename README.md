# riscv_ctb_challenges

## Challenge Level 1

### challenge1_logical
Initial behavior: ```make all``` produces the following ouput on the compile stage:
Output of compile:
```assembly
test.S: Assembler messages:
test.S:15855: Error: illegal operands `and s7,ra,z4'
test.S:25584: Error: illegal operands `andi s5,t1,s0'![image](https://github.com/vyomasystems-lab/riscv-ctb-challenge-S34m1n4t0r/assets/81908108/bf85bf45-e6ef-454f-b3bd-ad98c666cd91)
```
**Proposed changes**

Cause of Error in line test.S:15855:  ```z4``` is not a valid CPU register. The instruction can be fixed by using a valid register, for example ```t4```:
```assembly
and s7,ra,t4
```

Cause of Error in line test.S:25584: **andi** requires an immidiate value, not two registers. As all other instructions in the test are **and** instructions, this is most likely a typo-error
The Error can therefore be fixed by using the **and** instriction:
```assembly
and s5,t1,s0
```



### challenge2_loop

When executing ```make all``` in the challenge2_loop directory, the ```spike``` command can only be aborted using the manual exit ```Ctrl+C```

The problem is, that the function loop is never left in the inital setup. 
Here is the proposed solution, decrement the "testcase-counter" stored in ```t5```, and jump to ```test_end``` once the counter reaches 0.
```assembly
loop:
  lw t1, (t0)
  lw t2, 4(t0)
  lw t3, 8(t0)
  add t4, t1, t2
  addi t0, t0, 12
  addi t5, t5, -1         # decrement test counter
  beqz t5 , test_end      # if end of data is reached, end loop
  beq t3, t4, loop        # check if sum is correct
  j fail

test_end:

TEST_PASSFAIL
```


Output of spike for the  first loop execution:
```listing
code
core   0: 3 0 0x800001b8 (0x00c28293) x5  0x80003d10
core   0: 3 0 0x800001bc (0xffde06e3)
core   0: 3 0 0x800001a8 (0x0002a303) x6  0x00000000 mem 0x80003d10
core   0: 3 0 0x800001ac (0x0042a383) x7  0x00000000 mem 0x80003d14
core   0: 3 0 0x800001b0 (0x0082ae03) x28 0x00000000 mem 0x80003d18
core   0: 3 0 0x800001b4 (0x00730eb3) x29 0x00000000
core   0: 3 0 0x800001b8 (0x00c28293) x5  0x80003d1c
```



The values of ```x28``` and ```x29``` are compared in the loop, then the address in ```t0/x5``` is incremented, to check the next data pair.


### challenge3_illegal

The implementation of the ```mtvec_handler``` misses, that the ```mepc```CSR register still holds the address of the illegal instruction. After the ```mret``` instruction is called, there is no call to the ```test_end``` function. 
As the test is completed and passed with the call to the ```mtvec_handler``` the ```mepc``` register can be written to contain the address of ```test_end```
The following listing shows the modified testcase:

```assembly
.align 2
.option norvc

li TESTNUM, 2
illegal_instruction:
  .word 0              
  j fail

.align 4
.global mtvec_handler
mtvec_handler:
  li t1, CAUSE_ILLEGAL_INSTRUCTION
  csrr t0, mcause
  bne t0, t1, fail
  csrr t0, mepc               # mepc should point to illegal_instruction
  la t1, illegal_instruction  # load actual address of illegal_instruction
  bne t0, t1, fail            # check that cause for trap was our illegal instruction
  la t0, test_end             # load address of test_end
  csrw mepc, t0              # set mepc to test_end, to pass test
  mret


test_end:

  TEST_PASSFAIL
```

At 0x800001fc, the '''mret''' instruction is called, returning from the '''mtvec_handler'''. The next instuction is called from 0x800001cc, the first line of '''pass'''. After completing this function, the '''trap_vector''' is called again, this time continuing to '''write_tohost''', indicating to the host, that the test was passed successfully and the illegal instruction was processed as expected.

```assembly
core   0: 3 0x800001ec (0x341022f3) x5  0x800001a4
core   0: 3 0x800001f0 (0x00000297) x5  0x800001f0
core   0: 3 0x800001f4 (0xfdc28293) x5  0x800001cc
core   0: 3 0x800001f8 (0x34129073) c833_mepc 0x800001cc
core   0: 3 0x800001fc (0x30200073) c768_mstatus 0x00000080
core   0: 3 0x800001cc (0x0ff0000f)
core   0: 3 0x800001d0 (0x00100193) x3  0x00000001
core   0: 3 0x800001d4 (0x05d00893) x17 0x0000005d
core   0: 3 0x800001d8 (0x00000513) x10 0x00000000
core   0: 3 0x80000004 (0x34202f73) x30 0x0000000b
core   0: 3 0x80000008 (0x00800f93) x31 0x00000008
core   0: 3 0x8000000c (0x03ff0a63)
core   0: 3 0x80000010 (0x00900f93) x31 0x00000009
core   0: 3 0x80000014 (0x03ff0663)
core   0: 3 0x80000018 (0x00b00f93) x31 0x0000000b
core   0: 3 0x8000001c (0x03ff0263)
core   0: 3 0x80000040 (0x00001f17) x30 0x80001040
core   0: 3 0x80000044 (0xfc3f2023) mem 0x80001000 0x00000001
core   0: 3 0x80000048 (0x00001f17) x30 0x80001048
core   0: 3 0x8000004c (0xfa0f2e23) mem 0x80001004 0x00000000
```

```assembly
800001e0 <mtvec_handler>:
800001e0:	00200313          	li	t1,2
800001e4:	342022f3          	csrr	t0,mcause
800001e8:	fc6294e3          	bne	t0,t1,800001b0 <fail>
800001ec:	341022f3          	csrr	t0,mepc
800001f0:	00000297          	auipc	t0,0x0
800001f4:	fdc28293          	addi	t0,t0,-36 # 800001cc <pass>
800001f8:	34129073          	csrw	mepc,t0
800001fc:	30200073          	mret
80000200:	c0001073          	unimp

800001cc <pass>:
800001cc:	0ff0000f          	fence
800001d0:	00100193          	li	gp,1
800001d4:	05d00893          	li	a7,93
800001d8:	00000513          	li	a0,0
800001dc:	00000073          	ecall
```
## challenge_level2

## challenge1_instructions


```python
isa-instruction-distribution:
  rel_sys: 0
  rel_sys.csr: 0
  rel_rv32i.ctrl: 0
  rel_rv32i.compute: 10
  rel_rv32i.data: 10
  rel_rv32i.fence: 10
  rel_rv64i.compute: 0
  rel_rv64i.data: 0
  rel_rv32i.zba: 0
  rel_rv64i.zba: 0
  rel_rv32i.zbb: 0
  rel_rv64i.zbb: 0
  rel_rv32i.zbc: 0
  rel_rv32i.zbs: 0
  rel_rv32i.zbe: 0
  rel_rv64i.zbe: 0
  rel_rv32i.zbf: 0
  rel_rv64i.zbf: 0
  rel_rv64i.zbm: 0
  rel_rv32i.zbp: 0
  rel_rv64i.zbp: 0
  rel_rv32i.zbr: 0
  rel_rv64i.zbr: 0
  rel_rv32i.zbt: 0
  rel_rv64i.zbt: 0
  rel_rv32m: 0
  rel_rv64m: 0      # Here was a 10 in the original config file.
  rel_rv32a: 0
  rel_rv64a: 0
  rel_rv32f: 0
  rel_rv64f: 0
  rel_rv32d: 0
  rel_rv64d: 0
```

This generates instructions for the riscv64, e.g.
```assembly
test.S: Assembler messages:
test.S:156: Error: unrecognized opcode `divuw s4,a3,t4'
test.S:157: Error: unrecognized opcode `remw s6,s6,s11'

```


### challenge2_exceptions

```python
# ---------------------------------------------------------------------------------
# Exception generation
# ---------------------------------------------------------------------------------
exception-generation:
  ecause00: 0
  ecause01: 0
  ecause02: 10    # Generates a total of 10 illegal instructions, evenly distributed
  ecause03: 0
  ecause04: 0
  ecause05: 0
  ecause06: 0
  ecause07: 0
  ecause08: 0
  ecause09: 0
  ecause10: 0
  ecause11: 0
  ecause12: 0
  ecause13: 0
  ecause14: 0
```

Output of '''make all'''
```assembler
core   0: exception trap_illegal_instruction, epc 0x800004ec
core   0: exception trap_illegal_instruction, epc 0x8000052c
core   0: exception trap_illegal_instruction, epc 0x80000534
core   0: exception trap_illegal_instruction, epc 0x800005a4
core   0: exception trap_illegal_instruction, epc 0x800005d8
core   0: exception trap_illegal_instruction, epc 0x80000610
core   0: exception trap_illegal_instruction, epc 0x8000061c
core   0: exception trap_illegal_instruction, epc 0x80000638
core   0: exception trap_illegal_instruction, epc 0x80000668
core   0: exception trap_illegal_instruction, epc 0x80000684
wc -l exceptions.log
10 exceptions.log
```
