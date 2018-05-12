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

    reg [32:0] clk_cnt;

    reg [1:0] state = 2'b00;

    initial
    begin
        rgb_data <= 24'h0000ff;
    end

    always @(posedge pixclk)
    begin    
        clk_cnt <= clk_cnt + 1;

        case(state)
            2'b00 : begin
                        if (clk_cnt > 32'h02ffffff)
                        begin
                            rgb_data <= 24'hffffff;
                            clk_cnt <= 32'd0;
                            state <= 2'b01;
                        end
                    end
            2'b01 : begin
                        if (clk_cnt > 32'h02ffffff)
                        begin
                            rgb_data <= 24'hff0000;
                            clk_cnt <= 32'd0;
                            state <= 2'b10;                        
                        end
                    end
            2'b10 : begin
                        if (clk_cnt > 32'h02ffffff)
                        begin
                            rgb_data <= 24'h00ff00;
                            clk_cnt <= 32'd0;
                            state <= 2'b11;                        
                        end
                    end
            2'b11 : begin
                        if (clk_cnt > 32'h02ffffff)
                        begin
                            rgb_data <= 24'h0000ff;
                            clk_cnt <= 32'd0;
                            state <= 2'b00;  
                        end
                    end
        endcase 

    end
endmodule
