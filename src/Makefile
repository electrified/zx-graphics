chip.bin: vga_mem.v hvsync_generator.v sdram.v pll.v vga_mem_icecore.pcf
	yosys -p "synth_ice40 -json chip.json" vga_mem.v hvsync_generator.v sdram.v pll.v
	nextpnr-ice40 --hx8k --package tq144:4k --pcf vga_mem_icecore.pcf --json chip.json --asc chip.asc
	icepack chip.asc chip.bin

.PHONY: upload
upload:
	(stty raw -echo;cat) < /dev/ttyACM0 &
	cp chip.bin /dev/ttyACM0

.PHONY: clean
clean:
	$(RM) -f chip.json chip.txt chip.asc chip.bin

sim:
	iverilog vga_mem_tb.v vga_mem.v hvsync_generator.v pll.v sdram.v `yosys-config --datdir/ice40/cells_sim.v`
