chip.bin: hvsync_generator.v test_hvsync.v vga_mem.pcf
	yosys -p "synth_ice40 -json chip.json" hvsync_generator.v test_hvsync.v
	nextpnr-ice40 --hx8k --package tq144:4k --pcf vga_mem.pcf --json chip.json --asc chip.asc
	icepack chip.asc chip.bin

.PHONY: upload
upload:
	(stty raw -echo;cat) < /dev/ttyACM0 &
	cp chip.bin /dev/ttyACM0

.PHONY: clean
clean:
	$(RM) -f chip.json chip.txt chip.asc chip.bin
