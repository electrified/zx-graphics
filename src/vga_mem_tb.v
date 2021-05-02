`timescale 1ns/10ps
`define sim

module vga_mem_tb;

reg               clk25            ;
wire              HS               ;
wire              VS               ;
wire    [3:0]     RED              ;
wire    [3:0]     GREEN            ;
wire    [3:0]     BLUE             ;
wire    [15:0]    sd_data          ;
wire    [10:0]    sd_addr          ;
wire    [1:0]     sd_dqm           ;
wire    [0:0]     sd_ba            ;
wire              sd_cs            ;
wire              sd_we            ;
wire              sd_ras           ;
wire              sd_cas           ;
wire              sd_cke           ;
reg              button;
wire       [2:0] leds;
vga_mem uut (
    .clk25            (    clk25            ),
    .HS               (    HS               ),
    .VS               (    VS               ),
    .RED              (    RED              ),
    .GREEN            (    GREEN            ),
    .BLUE             (    BLUE             ),
    .sd_data          (    sd_data          ),
    .sd_addr          (    sd_addr          ),
    .sd_dqm           (    sd_dqm           ),
    .sd_ba            (    sd_ba            ),
    .sd_cs            (    sd_cs            ),
    .sd_we            (    sd_we            ),
    .sd_ras           (    sd_ras           ),
    .sd_cas           (    sd_cas           ),
    .sd_cke           (    sd_cke           ),
    .leds             (     leds            ),
    .button           (     button          )
);

parameter PERIOD = 40;

/*
25MHZ period = 40ns

-7 memory should run at a frequency of 143Mhz
== period = 7ns

Actual memory speed == 64.062Mhz
== period = 15.6098779 ns

*/

initial begin
    $dumpfile("tb_output.vcd");
    $dumpvars(2, vga_mem_tb);
    button = 1'b1;
    clk25 = 1'b0;
    // #(PERIOD/2);

    // always #(PERIOD/2) clock_out=~clock_out;
    #50000000 $finish;
end

always #(PERIOD/2) clk25=~clk25;

// initial begin
//     WR = 1;
//     IORQ = 1;
//     A = 8'h0;
//     #40

//     A = 8'h42;
//     IORQ = 0;
//     WR = 0;
//     #40;
//     WR = 1;
//     #40;
//     IORQ = 1;
//     // #PERIOD;
//     A = 8'h0;
//     // #PERIOD;
// end
// `include "user.tb_vga_mem.v"
endmodule
