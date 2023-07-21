all: compile disass spike sim

compile: clean
	@echo '[UpTickPro] Compilation ------'
	riscv32-unknown-elf-gcc -march=rv32i -mabi=ilp32 -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles  -I$(PWD)/common -T$(PWD)/common/link.ld test.S -o test.elf

disass: compile
	riscv32-unknown-elf-objdump -D test.elf > test.disass

spike: compile
	@echo '[UpTickPro] Spike ------'
	spike --isa=rv32i test.elf 
	spike --log-commits --log spike.dump --isa=rv32i test.elf

sim: spike
	@echo '[UpTickPro] Simulation ------'
	elf2hex  4  8388608 test.elf 2147483648 > code.mem
	cp code.mem ../planigale_riscv/firmware/firmware_mem.hex
	cp ../riscv/boot.LSB ../planigale_riscv/firmware/start_mem.hex
	make -C ../planigale_riscv sim_extern
	cp ../planigale_riscv/trace.dump rtl.dump
	@echo '[UpTickPro] Comparison ------'
	diff rtl.dump spike.dump
	
clean:
	@echo '[UpTickPro] Clean ------'
	rm -rf *.elf *.disass *.log *.dump app_log code.mem signature boot.* riscv_buggy
