
all: gen compile disass spike sim

gen: clean
	@echo '[UpTickPro] Test Generation ------'
	pip install aapg
	aapg setup
	aapg gen --config_file $(PWD)/rv32i.yaml --asm_name test --output_dir $(PWD) --arch rv32

compile:
	@echo '[UpTickPro] Test Compilation ------'
	riscv32-unknown-elf-gcc -march=rv32i -mabi=ilp32 -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -I$(PWD)/work/common -T$(PWD)/test.ld test.S $(PWD)/work/common/crt.S -o test.elf

disass: compile
	@echo '[UpTickPro] Test Disassembly ------'
	riscv32-unknown-elf-objdump -D test.elf > test.disass

spike: compile
	@echo '[UpTickPro] Spike ------'
	spike --isa=rv32i test.elf 
	spike --log-commits --log spike.dump --isa=rv32i test.elf

sim: spike
	@echo '[UpTickPro] Simulation ------'
	elf2hex  4  1048576 test.elf 2147483648 > code.mem
	cp code.mem ../planigale_riscv/firmware/firmware_mem.hex
	cp ../riscv/boot.LSB ../planigale_riscv/firmware/start_mem.hex
	make -C ../planigale_riscv sim_extern
	cp ../planigale_riscv/trace.dump rtl.dump
	@echo '[UpTickPro] Comparison ------'
	diff rtl.dump spike.dump

clean:
	@echo '[UpTickPro] Clean ------'
	rm -rf *.elf *.disass *.log *.dump app_log code.mem signature boot.* riscv_buggy  work *.S *.ld *.ini
