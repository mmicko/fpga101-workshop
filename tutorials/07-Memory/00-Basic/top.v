module top(
    output LCD_CLK,
    output [7:0] LCD_DAT,
    output LCD_HS,
    output LCD_VS,
    output LCD_DEN,
    output LCD_RST,
    output LCD_PWM);

/* ------------------------
       Clock generator 
   ------------------------*/

wire clkhf;
wire locked;
wire pixclk;

(* ROUTE_THROUGH_FABRIC=1 *)
SB_HFOSC #(.CLKHF_DIV("0b01")) hfosc_i (
  .CLKHFEN(1'b1),
  .CLKHFPU(1'b1),
  .CLKHF(clkhf)
);

pll pll_i(.clock_in(clkhf), .clock_out(pixclk), .locked(locked));

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
                  .resetn(locked),
                  .lcd_dat(LCD_DAT),
                  .lcd_hsync(LCD_HS),
                  .lcd_vsync(LCD_VS),
                  .lcd_den(LCD_DEN),
                  .h_pos(h_pos),
                  .v_pos(v_pos),
                  .rgb_data(rgb_data));


/* ----------------------------
       Custom video generator 
   ----------------------------*/
wire [7:0] data_out;

font_rom vga_font(
    .clk(pixclk),
    .addr({ 8'd65, v_pos[3:0] }),
    .data_out(data_out)
);

assign rgb_data = data_out[7-h_pos[2:0]+1] ? 24'hffffff : 24'h0000aa; // +1 for sync

endmodule
