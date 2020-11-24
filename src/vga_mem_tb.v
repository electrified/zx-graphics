`timescale 1ns/10ps //Adjust to suit
`define sim

module vga_mem_tb;

reg               clk25            ;
wire              HS               ;
wire              VS               ;
wire    [3:0]     RED              ;
wire    [3:0]     GREEN            ;
wire    [3:0]     BLUE             ;
reg     [7:0]     A                ;
reg               M1               ;
reg               RFSH             ;
reg               RESET            ;
reg               Z80_CLK          ;
reg               INT              ;
reg               BUSACK           ;
wire              OUTPUT_ENABLE    ;
reg               MREQ             ;
reg               HALT             ;
reg               WR               ;
reg               BUSREQ           ;
reg               RD               ;
reg               WAIT             ;
reg               IORQ             ;
reg               NMI              ;
reg     [7:0]     D                ;
wire    [15:0]    sd_data          ;
wire    [10:0]    sd_addr          ;
wire    [1:0]     sd_dqm           ;
wire    [0:0]     sd_ba            ;
wire              sd_cs            ;
wire              sd_we            ;
wire              sd_ras           ;
wire              sd_cas           ;
wire              sd_cke           ;

vga_mem uut (
    .clk25            (    clk25            ),
    .HS               (    HS               ),
    .VS               (    VS               ),
    .RED              (    RED              ),
    .GREEN            (    GREEN            ),
    .BLUE             (    BLUE             ),
    .A                (    A                ),
    .M1               (    M1               ),
    .RFSH             (    RFSH             ),
    .RESET            (    RESET            ),
    .Z80_CLK          (    Z80_CLK          ),
    .INT              (    INT              ),
    .BUSACK           (    BUSACK           ),
    .OUTPUT_ENABLE    (    OUTPUT_ENABLE    ),
    .MREQ             (    MREQ             ),
    .HALT             (    HALT             ),
    .WR               (    WR               ),
    .BUSREQ           (    BUSREQ           ),
    .RD               (    RD               ),
    .WAIT             (    WAIT             ),
    .IORQ             (    IORQ             ),
    .NMI              (    NMI              ),
    .D                (    D                ),
    .sd_data          (    sd_data          ),
    .sd_addr          (    sd_addr          ),
    .sd_dqm           (    sd_dqm           ),
    .sd_ba            (    sd_ba            ),
    .sd_cs            (    sd_cs            ),
    .sd_we            (    sd_we            ),
    .sd_ras           (    sd_ras           ),
    .sd_cas           (    sd_cas           ),
    .sd_cke           (    sd_cke           )
);

parameter PERIOD = 10; //adjust for your timescale

initial begin
    $dumpfile("tb_output.vcd");
    $dumpvars(2, vga_mem_tb);
    clk25 = 1'b0;
    #(PERIOD/2);
    forever
        #(PERIOD/2) clk25 = ~clk25;
end

initial begin
    WR = 1;
    IORQ = 1;
    A = 8'h0;
    #40

    A = 8'h42;
    IORQ = 0;
    WR = 0;
    #40;
    WR = 1;
    #40;
    IORQ = 1;
    // #PERIOD;
    A = 8'h0;
    // #PERIOD;
end
// `include "user.tb_vga_mem.v"
endmodule
