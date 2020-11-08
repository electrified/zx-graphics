`default_nettype none

module vga_mem(
    input clk25,
    output HS,
    output VS,
    output reg [3:0] RED,
    output reg [3:0] GREEN,
    output reg [3:0] BLUE,
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
    input [7:0] D,
    inout      [15:0] sd_data,    // 16 bit bidirectional data bus
    output     [10:0] sd_addr,    // 11 bit multiplexed address bus
    output     [1:0]  sd_dqm,     // two byte masks
    output     [0:0]  sd_ba,      // two banks
    output            sd_cs,      // a single chip select
    output            sd_we,      // write enable
    output            sd_ras,     // row address select
    output            sd_cas,     // columns address select
    output            sd_cke,     // clock enable
    output            sd_clk     // sdram clock
    );

parameter ADDR_IO_ADDR_LOW = 'h40;
parameter ADDR_IO_ADDR_HIGH = ADDR_IO_ADDR_LOW + 1;
parameter VALUE_IO_ADDR = ADDR_IO_ADDR_HIGH + 1;

assign OUTPUT_ENABLE = 0;
wire [9:0] x, y;

/*
640 x 480

Screen resolution = 192 x 256
192 lines of 32 bytes

*/
wire display_on;

reg [9:0] scaled_x;
reg [9:0] scaled_y;

  hvsync_generator hvsync_gen(
    .clk(clk25),
    .reset(1'b0),
    .hsync(HS),
    .vsync(VS),
    .display_on(display_on),
    .hpos(x),
    .vpos(y)
  );


always @(posedge clk25)
    begin
        scaled_x <= (x >> 1);
        scaled_y <= (y >> 1);
        
        if(x < 512 && y < 384)
        begin
            display_read_addr <= {scaled_y[7:0], scaled_x[7:0]};

            RED <= sdram_read_data[3:0];
            GREEN <= sdram_read_data[7:4];
            BLUE <= sdram_read_data[11:8];
        end
        else
        begin
            RED <= 0;
            GREEN <= 0;
            BLUE <= 0;
        end
    end

reg [23:0] palette [15:0];

initial begin
    palette[0] <= 'h000000;
    palette[1] <= 'h1d2b53;
    palette[2] <= 'h7e2553;
    palette[3] <= 'h008751;
    palette[4] <= 'hab5236;
    palette[5] <= 'h5f574f;
    palette[6] <= 'hc2c3c7;
    palette[7] <= 'hfff1e8;
    palette[8] <= 'hff004d;
    palette[9] <= 'hffa300;
    palette[10] <= 'hffec27;
    palette[11] <= 'h00e436;
    palette[12] <= 'h29adff;
    palette[13] <= 'h83769c;
    palette[14] <= 'hff77a8;
    palette[15] <= 'hffccaa;
end

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

reg [15:0] vram_addr;
reg [15:0] vram_value;
reg  [1:0] sdram_written = 0;
reg blanking_all_ram;


reg [31:0] led_countdown = 0;

always @(posedge clk64)
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

    if(iorq_2 == 0 && wr_2 == 0 && wr_1 == 1)
    begin

        // if (A_2 == ADDR_IO_ADDR_HIGH)
        // begin
        //     vram_addr[15:8] <= D_1;
        // end

        // if (A_2 == ADDR_IO_ADDR_LOW)
        // begin
        //     vram_addr[7:0] <= D_1;
        // end

        if (A_2 == VALUE_IO_ADDR)
        begin;
            sdram_written <= 1;
            // vram_addr <= 0
            vram_value <= D_1;
            write_to_sdram <= 1;
            load_write_data <= 'b1010101010101010;
            blanking_all_ram <= 1;
        end

        if (blanking_all_ram)
        begin
            if (sync)
            begin
                sdram_written <= sdram_written + 1;
            end

            if(sync && sdram_written == 3)
            begin
                sdram_written <= 0;
                vram_addr <= vram_addr + 1;

                if(vram_addr == 'h7FF)
                begin
                    blanking_all_ram <= 0;
                    write_to_sdram <= 0;
                end
            end
        end
    end
end

  // Pll for SDRAM clock
   wire clk64, locked;

   pll pll_i (
     .clock_in(clk25),
     .clock_out(clk64),
     .locked(locked)
   );

   // ===============================================================
   // Clock Enable Generation
   // ===============================================================

   reg [5:0] clkdiv;
   reg sync;
   reg sdram_access = 1;
   reg clk32;

   always @(posedge clk64) begin
     clkdiv <= clkdiv + 1;
     sdram_access <= (clkdiv >= 8 && clkdiv < 16);
     sync <= (clkdiv[2:0] == 0);
     clk32 <= clkdiv[0];
   end

   // Use SB_IO for tristate sd_data
   wire [15:0] sd_data_in;
   reg  [15:0] sd_data_out;
   reg         sd_data_dir;

`ifdef use_sb_io
   SB_IO #(
     .PIN_TYPE(6'b 1010_01),
     .PULLUP(1'b 0)
   ) ram [15:0] (
     .PACKAGE_PIN(sd_data),
     .OUTPUT_ENABLE(sd_data_dir),
     .D_OUT_0(sd_data_out),
     .D_IN_0(sd_data_in)
   );
`else 
   assign sd_data = sd_data_dir ? sd_data_out : 16'hzzzz;
   assign sd_data_in = sd_data; 
`endif

   assign sd_cke = 1;
   assign sd_clk = clk64;

    // assign sdram_access = 1;

    reg write_to_sdram;
    // assign write_to_sdram = 0;

    reg  [15:0] display_read_addr;

    wire [15:0] load_write_data;
    assign load_write_data = 'b1010101010101010;

   wire [15:0] sdram_address = write_to_sdram ? vram_addr[15:0] : display_read_addr[15:0];
   wire        sdram_wren = write_to_sdram;
   wire [15:0] sdram_write_data = load_write_data;
   wire [15:0] sdram_read_data;
   wire  [1:0] sdram_mask = 2'b00; //write_to_sdram ? (2'b01 << vram_addr[0]) : display_read_addr[10:0];

   // SDRAM
   sdram ram(
    .sd_data_in(sd_data_in),
    .sd_data_out(sd_data_out),
    .sd_data_dir(sd_data_dir),
    .sd_addr(sd_addr),
    .sd_dqm(sd_dqm),
    .sd_ba(sd_ba),
    .sd_cs(sd_cs),
    .sd_we(sd_we),
    .sd_ras(sd_ras),
    .sd_cas(sd_cas),
    .clk(clk64),
    .init(!locked),
    .sync(sync),
    .ds(sdram_mask),
    .we(sdram_wren),
    .oe(sdram_access),
    .addr({4'b0, sdram_address}),
    .din(sdram_write_data),
    .dout(sdram_read_data)
   );

endmodule
