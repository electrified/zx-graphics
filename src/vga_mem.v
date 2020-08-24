`default_nettype none

module vga_mem(
    input CLK,
    output HS,
    output VS,
    output reg [3:0] RED,
    output reg [3:0] GREEN,
    output reg [3:0] BLUE,
    input [15:0] A,
    input [7:0] D,
    input RD,
    input M1,
    input z80_clk,
    input MRQ,
    input IORQ,
    input RST,
    input INT,
    input WR,
    output LED1,
    output LED2
    );
// assign LED1 = 1;
assign LED2 = 0;

wire [9:0] x, y;

reg [7:0] mem[6912:0];//6912
/*
640 x 480

Screen resolution = 192 x 256
192 lines of 32 bytes

*/
reg [12:0] mem_index;
reg [12:0] colour_index;
reg [7:0] color;
wire blank;
wire display_on;

reg [9:0] scaled_x;
reg [9:0] scaled_y;

initial begin
  $readmemh("../amazonia.hex", mem);
end

  wire [9:0] prescaler;

  always @(posedge CLK)
    begin
    prescaler = prescaler + 1;

    if (prescaler == 3)
    begin
      prescaler = 0;
    end
  end


  hvsync_generator hvsync_gen(
    .clk(prescaler),
    .reset(0),
    .hsync(HS),
    .vsync(VS),
    .display_on(display_on),
    .hpos(x),
    .vpos(y)
  );


always @(posedge CLK)
    begin
        scaled_x <= (x >> 1);
        scaled_y <= (y >> 1);
        colour_index <= 'h1800 + {scaled_y[7:3], scaled_x[7:3]};

        if(x < 512 && y < 384)
        begin
            color <= mem[{scaled_y[7:6], scaled_y[2:0], scaled_y[5:3], scaled_x[7:3]}][7 - scaled_x[2:0]];
            RED <= (color? mem[colour_index][1]: mem[colour_index][4]) << 3;
            GREEN <= (color? mem[colour_index][2]: mem[colour_index][5]) << 3;
            BLUE <= (color? mem[colour_index][0]: mem[colour_index][3]) << 3;
        end
        else
        begin
            RED <= 0;
            GREEN <= 0;
            BLUE <= 0;
        end
    end

reg wr_0;
reg wr_1;
reg mrq_0;
reg mrq_1;
reg mrq_2;
reg z80_clk_0;
reg z80_clk_1;
reg z80_clk_2;
reg [15:0] A_0;
reg [15:0] A_1;
reg [15:0] A_2;
reg [15:0] D_0;
reg [15:0] D_1;

reg [31:0] led_countdown = 0;


//   assign LED1 = led_track;



always @(posedge CLK)
begin
    z80_clk_0 <= z80_clk;
    z80_clk_1 <= z80_clk_0;
    z80_clk_2 <= z80_clk_1;

    wr_0 <= WR;
    wr_1 <= wr_0;

    mrq_0 <= MRQ;
    mrq_1 <= mrq_0;
    mrq_2 <= mrq_1;

    A_0 <= A;
    A_1 <= A_0;
    A_2 <= A_1;

    D_0 <= D;
    D_1 <= D_0;

    if(z80_clk_2 == 0 && z80_clk_1 == 1&& mrq_2 == 0 && wr_1 == 0)//  
    begin

        if (A_2 >= 'h4000 && A_2 <= 'h5AFF)
        begin
            LED1 <= ~LED1;
            mem[A_2 - 'h4000] <= D_1;
        end
    end

end
endmodule
