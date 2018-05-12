/*
 *  PicoSoC - A simple example SoC using PicoRV32
 *
 *  Copyright (C) 2017  Clifford Wolf <clifford@clifford.at>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

module top (
	output flash_csb,
	output flash_clk,
	inout  flash_io0,
	inout  flash_io1,
	inout  flash_io2,
	inout  flash_io3,
		
	// Terminal
	output SER_TX,
	input  SER_RX,

	// BUTTONS
	input  B0,B1,B2,B3,B4,B5,
	// LED
	output LED_R, LED_G, LED_B,
	
	// Video
	output LCD_CLK,
    output [7:0] LCD_DAT,
    output LCD_HS,
    output LCD_VS,
    output LCD_DEN,
    output LCD_RST,
    output LCD_PWM,

	// Video
	output AUDIO
);
	
/* ------------------------
       Clock generator 
   ------------------------*/

	wire clk;
	wire resetn;
	wire pixclk;

	(* ROUTE_THROUGH_FABRIC=1 *)
	SB_HFOSC #(.CLKHF_DIV("0b10")) hfosc_i (
		.CLKHFEN(1'b1),
		.CLKHFPU(1'b1),
		.CLKHF(clk)
	);

	pll pll_i(.clock_in(clk), .clock_out(pixclk), .locked(resetn));

/* ----------------------------
       Video signal generator 
   ----------------------------*/

	reg [23:0] rgb_data;
	wire [9:0] h_pos;
	wire [9:0] v_pos;

	assign LCD_CLK = pixclk;
	assign LCD_RST = 1'b1;
	assign LCD_PWM = 1'b1;
	video generator ( .clk(pixclk), // pixel clock in
					.resetn(resetn),
					.lcd_dat(LCD_DAT),
					.lcd_hsync(LCD_HS),
					.lcd_vsync(LCD_VS),
					.lcd_den(LCD_DEN),
					.h_pos(h_pos),
					.v_pos(v_pos),
					.rgb_data(rgb_data));

/* ------------------------
       PicoSoC
   ------------------------*/

	wire flash_io0_oe, flash_io0_do, flash_io0_di;
	wire flash_io1_oe, flash_io1_do, flash_io1_di;
	wire flash_io2_oe, flash_io2_do, flash_io2_di;
	wire flash_io3_oe, flash_io3_do, flash_io3_di;

	SB_IO #(
		.PIN_TYPE(6'b 1010_01),
		.PULLUP(1'b 0)
	) flash_io_buf [3:0] (
		.PACKAGE_PIN({flash_io3, flash_io2, flash_io1, flash_io0}),
		.OUTPUT_ENABLE({flash_io3_oe, flash_io2_oe, flash_io1_oe, flash_io0_oe}),
		.D_OUT_0({flash_io3_do, flash_io2_do, flash_io1_do, flash_io0_do}),
		.D_IN_0({flash_io3_di, flash_io2_di, flash_io1_di, flash_io0_di})
	);

	wire        iomem_valid;
	reg         iomem_ready;
	wire [3:0]  iomem_wstrb;
	wire [31:0] iomem_addr;
	wire [31:0] iomem_wdata;
	reg  [31:0] iomem_rdata;

	reg [31:0] gpio;	
	reg [31:0] tone;

	assign LED_R = !gpio[0];
	assign LED_G = !gpio[1];
	assign LED_B = !gpio[2];

	always @(posedge clk) begin
		if (!resetn) begin
			gpio <= 32'd0;
			tone <= 32'd0;
		end else begin
			iomem_ready <= 0;
			if (iomem_valid && !iomem_ready && iomem_addr[31:24] == 8'h 03) begin
				iomem_ready <= 1;
				if (iomem_wstrb[0]) gpio[ 7: 0] <= iomem_wdata[ 7: 0];
				iomem_rdata <= { 26'd0, B5, B4, B3, B2, B1, B0 };				
			end else if (iomem_valid && !iomem_ready && iomem_addr[31:24] == 8'h 04) begin
				iomem_ready <= 1;
				iomem_rdata <= 32'h 0000_0000;
			end else if (iomem_valid && !iomem_ready && iomem_addr[31:24] == 8'h 05) begin
				iomem_ready <= 1;
				iomem_rdata <= 32'h 0000_0000;
			end else if (iomem_valid && !iomem_ready && iomem_addr[31:24] == 8'h 06) begin
				iomem_ready <= 1;
				if (iomem_wstrb[0]) tone[ 7: 0] <= iomem_wdata[ 7: 0];
				if (iomem_wstrb[1]) tone[15: 8] <= iomem_wdata[15: 8];
				if (iomem_wstrb[2]) tone[23:16] <= iomem_wdata[23:16];
				if (iomem_wstrb[3]) tone[31:24] <= iomem_wdata[31:24];
				iomem_rdata <= 32'h 0000_0000;
			end
		end
	end

	picosoc soc (
		.clk          (clk         ),
		.resetn       (resetn      ),

		.ser_tx       (SER_TX      ),
		.ser_rx       (SER_RX      ),

		.flash_csb    (flash_csb   ),
		.flash_clk    (flash_clk   ),

		.flash_io0_oe (flash_io0_oe),
		.flash_io1_oe (flash_io1_oe),
		.flash_io2_oe (flash_io2_oe),
		.flash_io3_oe (flash_io3_oe),

		.flash_io0_do (flash_io0_do),
		.flash_io1_do (flash_io1_do),
		.flash_io2_do (flash_io2_do),
		.flash_io3_do (flash_io3_do),

		.flash_io0_di (flash_io0_di),
		.flash_io1_di (flash_io1_di),
		.flash_io2_di (flash_io2_di),
		.flash_io3_di (flash_io3_di),

		.irq_5        (1'b0        ),
		.irq_6        (1'b0        ),
		.irq_7        (1'b0        ),

		.iomem_valid  (iomem_valid ),
		.iomem_ready  (iomem_ready ),
		.iomem_wstrb  (iomem_wstrb ),
		.iomem_addr   (iomem_addr  ),
		.iomem_wdata  (iomem_wdata ),
		.iomem_rdata  (iomem_rdata )
	);
		
/* ----------------------------
       Custom video generator 
   ----------------------------*/
   wire [23:0] palette[0:15];

	assign palette[0] = 24'h000000;
	assign palette[1] = 24'h0000aa;
	assign palette[2] = 24'h00aa00;
	assign palette[3] = 24'h00aaaa;
	assign palette[4] = 24'haa0000;
	assign palette[5] = 24'haa00aa;
	assign palette[6] = 24'haa5500;
	assign palette[7] = 24'haaaaaa;
	assign palette[8] = 24'h555555;
	assign palette[9] = 24'h5555ff;
	assign palette[10] = 24'h55ff55;
	assign palette[11] = 24'h55ffff;
	assign palette[12] = 24'hff5555;
	assign palette[13] = 24'hff55ff;
	assign palette[14] = 24'hffff55;
	assign palette[15] = 24'hffffff;  

	wire [7:0] data_out;
	wire [7:0] char;
	wire [7:0] attr;

	font_rom vga_font(.clk(pixclk),.addr({ char, v_pos[3:0] }),.data_out(data_out));

	wire vga_wren;
	assign vga_wren = (iomem_valid && !iomem_ready && iomem_addr[31:24] == 8'h 04) ? iomem_wstrb : 4'b0000;
	
	wire attr_wren;
	assign attr_wren = (iomem_valid && !iomem_ready && iomem_addr[31:24] == 8'h 05) ? iomem_wstrb : 4'b0000;

	video_ram text_mem(
		.sys_clk(clk),
	    .sys_addr(iomem_addr[11:2]),
	    .sys_data(iomem_wdata[7:0]),
	    .sys_wren(vga_wren),		
		.video_clk(pixclk),
		.video_addr({ v_pos[8:4],5'b00000} + { v_pos[9:4],3'b000 } + h_pos[9:3]),
		.video_data(char));

	video_ram attrib_mem(
		.sys_clk(clk),
	    .sys_addr(iomem_addr[11:2]),
	    .sys_data(iomem_wdata[7:0]),
	    .sys_wren(attr_wren),		
		.video_clk(pixclk),
		.video_addr({ v_pos[8:4],5'b00000} + { v_pos[9:4],3'b000 } + h_pos[9:3]),
		.video_data(attr));

	assign rgb_data = data_out[7-h_pos[2:0]+1]==1 ? palette[attr[3:0]] : palette[attr[7:4]]; // +1 for sync

/* ----------------------------
       Audio section
   ----------------------------*/

	reg [31:0] counter;

	always @(posedge clk) 
		if(counter==0) counter <= tone; else counter <= counter-1;

	always @(posedge clk) if(counter==0) AUDIO <= ~AUDIO;
		
endmodule
