
  /*
  RC2014 bus interface
  */
module moduleName (
    input clk25,
    input [7:0] A,
    input M1,
    input RFSH,
    input RESET,
    input Z80_CLK,
    input INT,
    input BUSACK,
    output OUTPUT_ENABLE,
    input MREQ,
    input HALT,
    input WR,
    input BUSREQ,
    input RD,
    input WAIT,
    input IORQ,
    input NMI,
    input [7:0] D
);
  reg wr_0;
  reg wr_1;
  reg wr_2;
  reg iorq_0;
  reg iorq_1;
  reg iorq_2;
  reg z80_clk_0;
  reg z80_clk_1;
  reg z80_clk_2;
  reg [15:0] A_0;
  reg [15:0] A_1;
  reg [15:0] A_2;
  reg [15:0] D_0;
  reg [15:0] D_1;

  reg [15:0] vram_addr = 0;
  reg [15:0] vram_value = 0;
  reg  [1:0] sdram_written = 0;
  reg blanking_all_ram;


  reg [31:0] led_countdown = 0;

  always @(posedge clk25)
  begin
    z80_clk_0 <= Z80_CLK;
    z80_clk_1 <= z80_clk_0;
    z80_clk_2 <= z80_clk_1;

    wr_0 <= WR;
    wr_1 <= wr_0;
    wr_2 <= wr_1;

    iorq_0 <= IORQ;
    iorq_1 <= iorq_0;
    iorq_2 <= iorq_1;

    A_0 <= A;
    A_1 <= A_0;
    A_2 <= A_1;

    D_0 <= D;
    D_1 <= D_0;
  end
endmodule