### Test suite goals
- [ ] Show that the memory is correctly initialised as per the data sheet
- [ ] blank memory
- [ ] read it back
- [ ] write distinctive pattern
- [ ] read it back 
- [ ] interleave reads and writes
- [ ] how to do assertions in a test bench?


### Todo
* Sensible memory layout
* Pick resolution and colour depth. VGA?
* Reduce IO requirements, auto advance
* Sprites
* Border
* Get the SDRAM working
* Have a solid test suite


Monitor the bus
replicate memory writes within range x to our memory bank
monitor bank switching

2 clock domains, video generation and bus

if bus
    is a memory write
    and is within the address range of the video output
    read byte
    submit it to block ram
    put in temporary holding place?


output enable is active low and must be done to get anything out - if high bus is isolated
direction low == from rc2014 to fpga
use regulator power if all wires from fpga not connected

https://forum.mystorm.uk/t/blackice-mx-sdram-access/664
https://forum.mystorm.uk/t/sram-emulator-for-sdram/670
https://1bitsquared.de/products/pmod-digital-video-interface


Formatted with verible-verilog-format
