`default_nettype none

module vga_mem(
    input CLK,
    output HS,
    output VS,
    output reg [3:0] RED,
    output reg [3:0] GREEN,
    output reg [3:0] BLUE
    );

wire [9:0] x, y;

reg [7:0] mem[8192:0];//6912
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
endmodule
