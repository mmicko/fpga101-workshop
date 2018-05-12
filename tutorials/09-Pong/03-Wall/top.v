module top(
    output LCD_CLK,
    output [7:0] LCD_DAT,
    output LCD_HS,
    output LCD_VS,
    output LCD_DEN,
    output LCD_RST,
    output LCD_PWM,
    input B0,
    input B2);

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
localparam SCREEN_WIDTH = 320;
localparam SCREEN_HEIGHT = 240;
localparam PADDLE_SIZE = 60;
localparam PADDLE_HEIGHT = 10;
localparam BALL_SIZE = 5;

reg [8:0] paddle_x = (SCREEN_WIDTH-PADDLE_SIZE)/2;
reg [8:0] ball_x = 50;
reg [8:0] ball_y = 50;

assign rgb_data = (h_pos > paddle_x  && h_pos < paddle_x + PADDLE_SIZE && v_pos > (SCREEN_HEIGHT-PADDLE_HEIGHT) && v_pos < SCREEN_HEIGHT) ? 24'hffffff :
            (h_pos > ball_x - BALL_SIZE && h_pos < ball_x + BALL_SIZE && v_pos > ball_y - BALL_SIZE && v_pos < ball_y + BALL_SIZE) ? 24'hffffff :
             24'h000000;


reg [31:0] cnt;
always @(posedge clk)
begin
    cnt <= cnt + 1;
end

reg reset = 0;
// Velocity
signed reg [8:0] ball_vel_x = 1;
signed reg [8:0] ball_vel_y = -1;

// Edge detection
// Moving ball
wire move;
reg prev_move;

assign move = cnt[17];

always @(posedge clk)
begin  
    if (ball_x - BALL_SIZE == 0)
    begin
        ball_vel_x <= 1;
    end
    if (ball_x + BALL_SIZE == SCREEN_WIDTH)
    begin
        ball_vel_x <= -1;
    end
    if (ball_y - BALL_SIZE == 0)
    begin
        ball_vel_y <= 1;
    end
    if ((ball_y + BALL_SIZE) > (SCREEN_HEIGHT - PADDLE_HEIGHT) )
    begin
        if ((ball_x + BALL_SIZE) < paddle_x || (ball_x - BALL_SIZE) > (paddle_x+PADDLE_SIZE) )
        begin
            if ((ball_y + BALL_SIZE) == SCREEN_HEIGHT)
                reset <= 1;  
        end
        else 
            ball_vel_y <= -1;
    end
  
    prev_move <= move;
    if (move==1 && prev_move==0)
        begin
        if (reset == 1)
        begin
            ball_x <= 50;
            ball_y <= 50;
            reset  <= 0;
        end
        else 
        begin
            ball_x <= ball_x + ball_vel_x;
            ball_y <= ball_y + ball_vel_y;
        end
    end
end

always @(posedge cnt[16])
begin
    if (B0==1'b1)
        paddle_x <= (paddle_x >0) ? paddle_x - 1 : paddle_x;
    if (B2==1'b1)
        paddle_x <= (paddle_x < (SCREEN_WIDTH-PADDLE_SIZE)) ? paddle_x +1 : paddle_x;
end    

endmodule
