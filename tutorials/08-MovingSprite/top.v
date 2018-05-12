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

wire [23:0] rgb_data;
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
                  .sprite_x(h_pos),
                  .sprite_y(v_pos),
                  .rgb_data(rgb_data));


/* ----------------------------
       Custom video generator 
   ----------------------------*/

wire [23:0] sprite_rgb;

reg [10:0] pos_x = 100;
reg [10:0] pos_y = 100;

wire [10:0] sprite_x;
wire [10:0] sprite_y;

assign sprite_x = h_pos - pos_x;
assign sprite_y = v_pos - pos_y;

sprite_rom sprite(
    .clk(pixclk),
    .addr({ sprite_y[5:0], sprite_x[5:0] }),
    .data_out(sprite_rgb));

assign rgb_data = (h_pos > pos_x && h_pos < pos_x + 64
     && v_pos > pos_y && v_pos < pos_y + 64) ? sprite_rgb :
     24'hffffff;


reg [31:0] cnt;
always @(posedge pixclk)
begin
    cnt <= cnt + 1;
end

localparam SCREEN_WIDTH = 320;
localparam SCREEN_HEIGHT = 240;

// Velocity
reg [10:0] sprite_vel_x = 1;
reg [10:0] sprite_vel_y = -1;

always @(posedge cnt[17])
begin  
    if (pos_x == 0)
    begin
        sprite_vel_x <= 1;
    end
    if (pos_x + 64 == SCREEN_WIDTH)
    begin
        sprite_vel_x <= -1;
    end
    if (pos_y == 0)
    begin
        sprite_vel_y <= 1;
    end
    if (pos_y + 64 == SCREEN_HEIGHT)
    begin
        sprite_vel_y <= -1;
    end    

    pos_x <= pos_x + sprite_vel_x;
    pos_y <= pos_y + sprite_vel_y;
end

endmodule
