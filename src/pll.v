/**
 * PLL configuration
 *
 * This Verilog module was generated automatically
 * using the icepll tool from the IceStorm project.
 * Use at your own risk.
 *
 * Given input frequency:        25.000 MHz
 * Requested output frequency:   64.000 MHz
 * Achieved output frequency:    64.062 MHz
 */

module pll(
	input  clock_in,
	output reg clock_out,
	output locked
	);

`ifdef sim
    parameter PERIOD = 16; //15.6ns == 64mhz

    reg [4:0] lock_count;

    initial begin
        clock_out = 0;
        lock_count = 0;
    end

    always #(PERIOD/2) begin
        clock_out=~clock_out;

        if(lock_count != 5'h1f)
		    lock_count <= lock_count + 5'd1;
    end

    assign locked = &lock_count;
`else
SB_PLL40_CORE #(
		.FEEDBACK_PATH("SIMPLE"),
		.DIVR(4'b0000),		// DIVR =  0
		.DIVF(7'b0101000),	// DIVF = 40
		.DIVQ(3'b100),		// DIVQ =  4
		.FILTER_RANGE(3'b010)	// FILTER_RANGE = 2
	) uut (
		.LOCK(locked),
		.RESETB(1'b1),
		.BYPASS(1'b0),
		.REFERENCECLK(clock_in),
		.PLLOUTCORE(clock_out)
		);
`endif
endmodule
