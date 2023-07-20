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

To fix the above isue, the line ```.align 4``` i
**Fixed output**
```listing
core   0: 3 0 0x80000198 (0x00200193) x3  0x00000002
core   0: 3 0x800001a4 (0x00002297) x5  0x800021a4
core   0: 3 0x800001a8 (0xe5c28293) x5  0x80002000
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

The implementation of the '''mtvec_handler''' misses, that the '''mepc'''-CSR register still holds the address of the illegal instruction. After the '''mret''', there is no call to the '''pass''' function. 
As the test is completed however with the call to the '''mtvec_handler''', the '''mepc'' register can be written to contain the address of '''pass'''

'''assembler
mtvec_handler:
  li t1, CAUSE_ILLEGAL_INSTRUCTION
  csrr t0, mcause
  bne t0, t1, fail
  csrr t0, mepc

  li t1, illegal_instruction
  bne t0, t1, fail
  la t0, pass
  csrw mepc, t0
'''

At 0x800001fc, the '''mret''' instruction is called, returning from the '''mtvec_handler'''. The next instuction is called from 0x800001cc, the first line of '''pass'''. After completing this function, the '''trap_vector''' is called again, this time continuing to '''write_tohost''', indicating to the host, that the test was passed successfully and the illegal instruction was processed as expected.
'''
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
'''

'''
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
'''
