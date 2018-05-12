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
    input B5);

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
                  .h_pos(h_pos),
                  .v_pos(v_pos),
                  .rgb_data(rgb_data));

/* ----------------------------
       Custom video generator 
   ----------------------------*/
localparam SCREEN_WIDTH = 320;
localparam SCREEN_HEIGHT = 240;
localparam PADDLE_SIZE = 60;
localparam PADDLE_WIDTH = 10;
localparam BALL_SIZE = 5;
localparam NET_WIDTH = 2;

reg [8:0] paddle1_y = (SCREEN_HEIGHT-PADDLE_SIZE)/2;
reg [8:0] paddle2_y = (SCREEN_HEIGHT-PADDLE_SIZE)/2;
reg [8:0] ball_x = SCREEN_WIDTH/2;
reg [8:0] ball_y = SCREEN_HEIGHT/2;

assign rgb_data = 
            (h_pos > 0 && h_pos < PADDLE_WIDTH && v_pos > paddle1_y  && v_pos < paddle1_y + PADDLE_SIZE) ? 24'hffffff :
            (h_pos > (SCREEN_WIDTH-PADDLE_WIDTH) && h_pos < SCREEN_WIDTH && v_pos > paddle2_y  && v_pos < paddle2_y + PADDLE_SIZE) ? 24'hffffff :
            (h_pos > ball_x - BALL_SIZE && h_pos < ball_x + BALL_SIZE && v_pos > ball_y - BALL_SIZE && v_pos < ball_y + BALL_SIZE) ? 24'hffffff :
            (h_pos > (SCREEN_WIDTH/2) - NET_WIDTH && h_pos < (SCREEN_WIDTH/2) + NET_WIDTH && v_pos[4]==0) ? 24'hffffff :
             24'h000000;


reg [31:0] cnt;
always @(posedge clk)
begin
    cnt <= cnt + 1;
end

// Velocity
reg [8:0] ball_vel_x = 1;
reg [8:0] ball_vel_y = -1;

// Edge detection
// Moving ball
wire move;
reg prev_move;

assign move = cnt[17];

always @(posedge clk)
begin  
    if (ball_x - BALL_SIZE < PADDLE_WIDTH)
    begin
        if ((ball_y + BALL_SIZE) < paddle1_y || (ball_y - BALL_SIZE) > (paddle1_y+PADDLE_SIZE) )
        begin
            if ((ball_x - BALL_SIZE) == 0)
            begin
                ball_vel_x <= 1;
            end
        end
        else
        begin
            ball_vel_x <= 1;
        end
    end
    if (ball_x + BALL_SIZE > (SCREEN_WIDTH-PADDLE_WIDTH))
    begin
        if ((ball_y + BALL_SIZE) < paddle2_y || (ball_y - BALL_SIZE) > (paddle2_y+PADDLE_SIZE) )
        begin
            if ((ball_x + BALL_SIZE) == SCREEN_WIDTH)
            begin
                ball_vel_x <= -1;
            end
        end
        else
        begin
            ball_vel_x <= -1;
        end
    end
    if (ball_y - BALL_SIZE == 0)
    begin
        ball_vel_y <= 1;
    end
    if (ball_y + BALL_SIZE == SCREEN_HEIGHT)
    begin
        ball_vel_y <= -1;
    end

    prev_move <= move;
    if (move==1 && prev_move==0)
    begin
        ball_x <= ball_x + ball_vel_x;
        ball_y <= ball_y + ball_vel_y;
    end
end

always @(posedge cnt[16])
begin
    if (B1==1'b1)
        paddle1_y <= (paddle1_y > 0) ? paddle1_y - 1 : paddle1_y;
    if (B3==1'b1)
        paddle1_y <= (paddle1_y < (SCREEN_HEIGHT-PADDLE_SIZE)) ? paddle1_y +1 : paddle1_y;
    if (B5==1'b1)
        paddle2_y <= (paddle2_y > 0) ? paddle2_y - 1 : paddle2_y;
    if (B4==1'b1)
        paddle2_y <= (paddle2_y < (SCREEN_HEIGHT-PADDLE_SIZE)) ? paddle2_y +1 : paddle2_y;
end    

endmodule
