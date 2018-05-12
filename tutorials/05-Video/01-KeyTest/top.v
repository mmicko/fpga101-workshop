module top(
    output LCD_CLK,
    output [7:0] LCD_DAT,
    output LCD_HS,
    output LCD_VS,
    output LCD_DEN,
    output LCD_RST,
    output LCD_PWM,
    input B0,
    input B1,
    input B2,
    input B3,
    input B4,
    input B5,
    output reg AUDIO);

/* ------------------------
       Clock generator 
   ------------------------*/

wire clk;
wire locked;
wire pixclk;

(* ROUTE_THROUGH_FABRIC=1 *)
SB_HFOSC #(.CLKHF_DIV("0b01")) hfosc_i (
  .CLKHFEN(1'b1),
  .CLKHFPU(1'b1),
  .CLKHF(clk)
);

pll pll_i(.clock_in(clk), .clock_out(pixclk), .locked(locked));

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
assign rgb_data = (h_pos > 50  && h_pos < 100 && v_pos > 100 && v_pos < 150 && B0) ? 24'hffffff :
                  (h_pos > 100 && h_pos < 150 && v_pos > 50 && v_pos < 100  && B1) ? 24'hffffff :
                  (h_pos > 150 && h_pos < 200 && v_pos > 100 && v_pos < 150 && B2) ? 24'hffffff :
                  (h_pos > 100 && h_pos < 150 && v_pos > 150 && v_pos < 200 && B3) ? 24'hffffff :

                  (h_pos > 250 && h_pos < 300 && v_pos > 50 && v_pos < 100  && B5) ? 24'hff6633 :
                  (h_pos > 250 && h_pos < 300 && v_pos > 150 && v_pos < 200 && B4) ? 24'hff6633 :
             24'h000000;

/* ----------------------------
       Audio section
   ----------------------------*/

parameter TONE_A4 = 24000000/440/2;
parameter TONE_B4 = 24000000/494/2;
parameter TONE_C5 = 24000000/523/2;
parameter TONE_D5 = 24000000/587/2;
parameter TONE_E5 = 24000000/659/2;
parameter TONE_F5 = 24000000/698/2;
parameter TONE_G5 = 24000000/783/2;

reg [14:0] counter;

always @(posedge clk) 
    if(counter==0) counter <= (B0 ? TONE_A4-1 : 
                               B1 ? TONE_B4-1 : 
                               B2 ? TONE_C5-1 : 
                               B3 ? TONE_D5-1 : 
                               B4 ? TONE_E5-1 : 
                               B5 ? TONE_F5-1 : 
                               0); else counter <= counter-1;

always @(posedge clk) if(counter==0) AUDIO <= ~AUDIO;

endmodule
