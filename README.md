# riscv_ctb_challenges

## Challenge Level 1

### Logical

Output of compile:
```assembly
test.S: Assembler messages:
test.S:15855: Error: illegal operands `and s7,ra,z4'
test.S:25584: Error: illegal operands `andi s5,t1,s0'![image](https://github.com/vyomasystems-lab/riscv-ctb-challenge-S34m1n4t0r/assets/81908108/bf85bf45-e6ef-454f-b3bd-ad98c666cd91)
```
**Proposed changes**

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

Problem: The address of the .data region is not loaded correctly to ```t0/x5```. As the dissassembly shows, the expected value should be **0x80002000**. 
```data
Disassembly of section .data:

80002000 <begin_signature>:
80002000:	0020                	.2byte	0x20
80002002:	0000                	.2byte	0x0
80002004:	0020                	.2byte	0x20
80002006:	0000                	.2byte	0x0
80002008:	0040                	.2byte	0x40
8000200a:	0000                	.2byte	0x0
8000200c:	4078                	.2byte	0x4078
8000200e:	344d0303          	lb	t1,836(s10)
80002012:	5d70                	.2byte	0x5d70
80002014:	74c5                	.2byte	0x74c5
80002016:	cafe6073          	csrsi	0xcaf,28
8000201a:	0000                	.2byte	0x0
8000201c:	0001                	.2byte	0x1
8000201e:	0000                	.2byte	0x0
80002020:	caff                	.2byte	0xcaff
```


**Proposed changes**

To fix the above isue, the line ```la t0, test_cases``` is replaxes with the following instructions, which explicitly load the address to ```t0/x5```, not leaving it up for the compiler:
```assembly
lui t0, %hi(test_cases)
addi t0, t0, %lo(test_cases)
```
**Fixed output**
```listing
core   0: 3 0 0x80000198 (0x00200193) x3  0x00000002
core   0: 3 0 0x8000019c (0x800022b7) x5  0x80002000
core   0: 3 0 0x800001a0 (0x00028293) x5  0x80002000
core   0: 3 0 0x800001a4 (0x00300f13) x30 0x00000003
core   0: 3 0 0x800001a8 (0x0002a303) x6  0x00000020 mem 0x80002000
core   0: 3 0 0x800001ac (0x0042a383) x7  0x00000020 mem 0x80002004
core   0: 3 0 0x800001b0 (0x0082ae03) x28 0x00000040 mem 0x80002008
core   0: 3 0 0x800001b4 (0x00730eb3) x29 0x00000040
core   0: 3 0 0x800001b8 (0x00c28293) x5  0x8000200c
core   0: 3 0 0x800001bc (0xffde06e3)
core   0: 3 0 0x800001a8 (0x0002a303) x6  0x03034078 mem 0x8000200c
core   0: 3 0 0x800001ac (0x0042a383) x7  0x5d70344d mem 0x80002010
core   0: 3 0 0x800001b0 (0x0082ae03) x28 0x607374c5 mem 0x80002014
core   0: 3 0 0x800001b4 (0x00730eb3) x29 0x607374c5
core   0: 3 0 0x800001b8 (0x00c28293) x5  0x80002018
core   0: 3 0 0x800001bc (0xffde06e3)
core   0: 3 0 0x800001a8 (0x0002a303) x6  0x0000cafe mem 0x80002018
core   0: 3 0 0x800001ac (0x0042a383) x7  0x00000001 mem 0x8000201c
core   0: 3 0 0x800001b0 (0x0082ae03) x28 0x0000caff mem 0x80002020
core   0: 3 0 0x800001b4 (0x00730eb3) x29 0x0000caff
core   0: 3 0 0x800001b8 (0x00c28293) x5  0x80002024
core   0: 3 0 0x800001bc (0xffde06e3)
core   0: 3 0 0x800001a8 (0x0002a303) x6  0x00000000 mem 0x80002024
core   0: 3 0 0x800001ac (0x0042a383) x7  0x00000000 mem 0x80002028
core   0: 3 0 0x800001b0 (0x0082ae03) x28 0x00000000 mem 0x8000202c
core   0: 3 0 0x800001b4 (0x00730eb3) x29 0x00000000
core   0: 3 0 0x800001b8 (0x00c28293) x5  0x80002030
```

The values of ```x28``` and ```x29``` are compared in the loop, then the address in ```t0/x5``` is incremented, to check the next data pair.


### Illegal
