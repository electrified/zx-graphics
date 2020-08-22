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
