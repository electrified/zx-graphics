`default_nettype none

module vga_mem (
    input             clk25,
    output            HS,
    output            VS,
    output reg [ 3:0] RED,
    output reg [ 3:0] GREEN,
    output reg [ 3:0] BLUE,
    inout      [15:0] sd_data,  // 16 bit bidirectional data bus
    output     [10:0] sd_addr,  // 11 bit multiplexed address bus
    output     [ 1:0] sd_dqm,  // two byte masks
    output     [ 0:0] sd_ba,  // two banks
    output            sd_cs,  // a single chip select
    output            sd_we,  // write enable
    output            sd_ras,  // row address select
    output            sd_cas,  // columns address select
    output            sd_cke,  // clock enable
    output            sd_clk,  // sdram clock
    output     [ 2:0] leds,
    input             button
);

  reg [3:0] rst_cnt = 0;
  wire rst_n = !rst_cnt[3];

  always @(posedge clk25) if (rst_n) rst_cnt <= rst_cnt + 1;

  wire clk_vga = clk32;
  reg clk_vga_en = 0;

  always @(posedge clk_vga) clk_vga_en <= !clk_vga_en;

  reg [15:0] address;
  reg [ 7:0] cpu_dout;

  reg        hard_reset_n;

  wire [9:0] x, y;

  wire display_on;

  reg [9:0] scaled_x;
  reg [9:0] scaled_y;

  hvsync_generator hvsync_gen (
      .clk(clk25),
      .reset(rst_n),
      .hsync(HS),
      .vsync(VS),
      .display_on(display_on),
      .hpos(x),
      .vpos(y)
  );

  /*
      Displaying on the screen
  */
  always @(posedge clk25) begin
    scaled_x <= (x >> 1);
    scaled_y <= (y >> 1);

    if (x < 512 && y < 384) begin
      address <= {scaled_y[7:0], scaled_x[7:0]};

      RED <= 4'b1111;  ///sdram_read_data[3:0];
      GREEN <= 4'b1111;  //sdram_read_data[7:4];
      BLUE <= 4'b1111;  //sdram_read_data[11:8];
    end else begin
      RED   <= 0;
      GREEN <= 0;
      BLUE  <= 0;
    end
  end

  //   /*
  //       Initialising RAM
  //   */
  //   always @(posedge clk25)
  //   begin
  //     if (rst_n)
  //     begin
  //       sdram_access <= 1;
  //       write_to_sdram <= 1;
  assign load_write_data = 'b1010101010101010;
  //     end
  //   end

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

  reg [5:0] clkdiv = 6'b000000;
  reg sync, cpu_clken;
  reg sdram_access = 0;
  reg clk32;

  always @(posedge clk64) begin
    clkdiv <= clkdiv + 1;
    cpu_clken <= (clkdiv == 0);
    sdram_access <= (clkdiv >= 8 && clkdiv < 16);
    sync <= (clkdiv[2:0] == 0);
    clk32 <= clkdiv[0];
  end

  // ===============================================================
  // Reset generation
  // ===============================================================

  reg [15:0] pwr_up_reset_counter = 0;  // hold reset low for ~1ms
  wire pwr_up_reset_n = &pwr_up_reset_counter;

  always @(posedge clk64) begin
    if (cpu_clken) begin
      if (!pwr_up_reset_n) pwr_up_reset_counter <= pwr_up_reset_counter + 1;
      hard_reset_n <= pwr_up_reset_n;
    end
  end


  wire reset = !hard_reset_n | !load_done;

  reg reload;
  reg btn_dly;

  always @(posedge clk64) begin
    btn_dly <= button;
    reload  <= button && !btn_dly;
  end



  // Use SB_IO for tristate sd_data
  wire [15:0] sd_data_in;
  wire [15:0] sd_data_out;
  wire        sd_data_dir;

  // `ifdef use_sb_io
  SB_IO #(
      .PIN_TYPE(6'b1010_01),
      .PULLUP  (1'b0)
  ) ram[15:0] (
      .PACKAGE_PIN(sd_data),
      .OUTPUT_ENABLE(sd_data_dir),
      .D_OUT_0(sd_data_out),
      .D_IN_0(sd_data_in)
  );
  // `else
  //    assign sd_data = sd_data_dir ? sd_data_out : 16'hzzzz;
  //    assign sd_data_in = sd_data;
  // `endif

  assign sd_cke = 1;
  assign sd_clk = clk64;

  wire [15:0] sdram_address = load_done ? address[17:1] : (16'h6000 + load_addr[15:0]);
  wire sdram_wren = load_done ? (sdram_access && 1'b0  /*!atom_RAMWE_b*/) : load_wren;
  wire [15:0] sdram_write_data = load_done ? {cpu_dout, cpu_dout} : load_write_data;
  wire [15:0] sdram_read_data;
  wire [1:0] sdram_mask = load_done ? (2'b01 << address[0]) : 2'b11;

  // SDRAM
  sdram sdram_inst (
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
      .init(!locked || reload),
      .sync(sync),
      .ds(sdram_mask),
      .we(sdram_wren),
      .oe(load_done && sdram_access  /* && !atom_RAMOE_b*/),
      .addr({4'b0, sdram_address}),
      .din(sdram_write_data),
      .dout(sdram_read_data)
  );


  reg                                        load_done;
  reg                                 [15:0] load_addr;
  reg                                 [ 1:0] sdram_written = 0;
  wire                                [15:0] load_write_data;

  //    reg         flashmem_valid;
  //    wire        flashmem_ready;
  wire load_wren = sdram_written > 1;
  //    wire [23:0] flashmem_addr = 24'h70000 | {load_addr, 1'b0};
  reg                                        load_done_pre;
  reg                                 [ 7:0] wait_ctr;

  assign leds[0] = !load_done;
  assign leds[1] = !hard_reset_n;
  assign leds[2] = !reload;

  // Flash memory load interface
  always @(posedge clk64) begin
    //  diag <= sdram_read_data;
    if (!hard_reset_n) begin
      load_done_pre <= 1'b0;
      load_done <= 1'b0;
      load_addr <= 17'h00000;
      wait_ctr <= 8'h00;
      //    flashmem_valid <= 1;
    end else begin
      if (reload) begin
        load_done_pre <= 1'b0;
        load_done <= 1'b0;
        load_addr <= 17'h0000;
        wait_ctr <= 8'h00;
        //    flashmem_valid <= 1;
      end else if (!load_done) begin
        if (sdram_written > 0 && sdram_written < 3) begin
          if (sync) sdram_written <= sdram_written + 1;
          if (sdram_written == 2 && sync) begin
            if (load_addr == 17'h1fff) begin
              load_done_pre <= 1'b1;
            end else begin
              load_addr <= load_addr + 1'b1;
              //  flashmem_valid <= 1;
              sdram_written <= 0;
            end
          end
        end
        if (!load_done_pre) begin
          //  if (flashmem_ready == 1'b1) begin
          //    flashmem_valid <= 0;
          //    sdram_written <= 1;
          //if (load_addr == 16'h1ffe) diag <= load_write_data;
          //  end
        end else begin
          if (wait_ctr < 8'hFF) wait_ctr <= wait_ctr + 1;
          else load_done <= 1'b1;
        end
      end
    end
  end

endmodule
