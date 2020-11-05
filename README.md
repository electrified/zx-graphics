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



10 LET A = &h4000
20 WHILE A < &h5aff
30 POKE A, 1
35 A = A + 1
40 WEND


10 PRINT "setting colour attributes"
20 LET A = &H1800
30 WHILE A <= &H1B00
35 print a
40 OUT &H40, A AND &HFF
50 OUT &H41, A / 256
60 OUT &H42, &H13
65 a = a +1
70 WEND
80 PRINT "setting data"
90 LET A = &H0
100 WHILE A <= &H1800
110 OUT &H40, A AND &HFF
120 OUT &H41, A / 256
130 OUT &H42, &H44
140 A = A + 1
150 WEND

https://1bitsquared.de/products/pmod-digital-video-interface


10 PRINT "setting colour attributes"
30 for ov = 0 to 255
40 PRINT "commencing iteration " OV
60 for A = 0 to 27
65 for b = 0 to 255
70 PRINT "a:" A  "b:" b
80 OUT &H40, A
90 OUT &H41, B
100 OUT &H42, OV
115 next b
120 next a
130 next ov

