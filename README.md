# riscv_ctb_challenges

## Challenge Level 1

### Logical

Output of compile:
```assembly
test.S: Assembler messages:
test.S:15855: Error: illegal operands `and s7,ra,z4'
test.S:25584: Error: illegal operands `andi s5,t1,s0'![image](https://github.com/vyomasystems-lab/riscv-ctb-challenge-S34m1n4t0r/assets/81908108/bf85bf45-e6ef-454f-b3bd-ad98c666cd91)
```

Cause of Error in line test.S:15855:  z4 is not a CPU register. Can be fixed by using t4 for example
```assembly
and s7,ra,t4
```
Cause of Error in line test.S:25584: **addi** requires an immidiate value, instead of two registers. As all other instructions in the test are **add** instructions, this is most likely a typo:
```assembly
and s5,t1,s0
```



### Loop

```listing
80000198:	00200193          	li	gp,2
8000019c:	00002297          	auipc	t0,0x2\_layouts\15\spappbar.aspx
800001a0:	e6428293          	addi	t0,t0,-412 # 80002000 <begin_signature>
800001a4:	00300f13          	li	t5,3
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

**Proposed changes**

```assembly
  lui t0, %hi(test_cases)
  addi t0, t0, %lo(test_cases)
```
