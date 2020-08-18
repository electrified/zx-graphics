
`include "hvsync_generator.v"

/*
A simple test pattern using the hvsync_generator module.
*/

module test_hvsync_top(clk, hsync, vsync, rgb);

  input clk;//, reset;
  output hsync, vsync;
  output [11:0] rgb;
  wire display_on;
  wire [9:0] hpos;
  wire [9:0] vpos;
  wire reset = 1'b0;
  wire [9:0] prescaler;

  always @(posedge clk)
    begin

    prescaler = prescaler + 1;

    if (prescaler == 3)
    begin
      prescaler <= 0;
    end
  end

  hvsync_generator hvsync_gen(
    .clk(prescaler),
    .reset(0),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(display_on),
    .hpos(hpos),
    .vpos(vpos)
  );

  wire r = display_on && (((hpos&7)==0) || ((vpos&7)==0));
  wire g = display_on && vpos[4];
  wire b = display_on && hpos[4];
  assign rgb = {b,b,b,b,g,g,g,g,r,r,r,r};

endmodule
