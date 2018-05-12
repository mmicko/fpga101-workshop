module top(
    output LCD_CLK,
    output [7:0] LCD_DAT,
    output LCD_HS,
    output LCD_VS,
    output LCD_DEN,
    output LCD_RST,
    output LCD_PWM,
    input ser_rx,
    input ser_tx,
    input B0);

/* ------------------------
       Clock generator 
   ------------------------*/

wire clkhf;
wire locked;
wire pixclk;

(* ROUTE_THROUGH_FABRIC=1 *)
SB_HFOSC #(.CLKHF_DIV("0b10")) hfosc_i (
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
wire [7:0] char;
wire [7:0] attr;

font_rom vga_font(.clk(pixclk),.addr({ char, v_pos[3:0] }),.data_out(data_out));


  wire rx_valid;
  wire [7:0] uart_out;
  
  uart_rx uart(
	.clk(clkhf),
	.resetn(locked),

	.ser_rx(ser_rx),

	.cfg_divider(12000000/9600),

	.data(uart_out),
	.valid(rx_valid)
);

assign rgb_data = data_out[7 - h_pos[2:0] + 1] ? 24'hffffff : 24'h000000;

reg [10:0] pos;
reg [10:0] pos_x;
reg [10:0] pos_y;

assign pos = pos_x + pos_y*40;

reg valid;
reg [7:0] display_char;
video_ram ram(.clk(clkhf),
            .sys_addr(pos),
            .sys_data(display_char),
            .sys_wren(valid),
            
            .video_clk(pixclk),
            .video_addr({ v_pos[9:4],5'b00000} + { v_pos[9:4],3'b000 } + h_pos[9:3]),
            .video_data(char));

reg state;

always @(posedge clkhf) 
begin
	if (!locked)     
    begin        
        state <= 0;
        pos_x <= 0;
        pos_y <= 0;
        valid <= 0;
    end
    else
    begin
        case (state)
            0: begin  // receiving char
                if (rx_valid) 
                begin                
                    if (uart_out==10 || uart_out==13)
                    begin
                        pos_y <= pos_y + 1;
                        pos_x <= 0;
                        state <= 0;
                    end
                    else if (uart_out<32 || uart_out> 126)
                    begin
                        valid <= 0;
                        state <= 0;
                    end
                    else
                    begin
                        valid <= 1;
                        display_char <= uart_out;
                        state <= 1;
                    end
                end
                end
            1: begin  // display char
                if (pos_x < 40)
                    pos_x <= pos_x + 1;
                else
                begin
                    pos_y <= pos_y + 1;
                    pos_x <= 0;
                end
                valid <= 0;
                state <= 0;
                end
        endcase  
    end
end



endmodule

//Text RAM for the VGA console
module video_ram(input clk, //system side clock
                   input [10:0] sys_addr, //system side address (word address)
                   input [7:0] sys_data, //system side write data
                   input  sys_wren, //bytewise wren
                   
                   input video_clk, //video side clock
                   input [10:0] video_addr, 
                   output reg [7:0] video_data);

reg [7:0] mem [0:600];

integer k;

initial
begin
  for (k = 0; k < 600; k = k + 1)
    mem[k] <= 32;
end

always @(posedge clk) begin
	if (sys_wren[0]) mem[sys_addr] <= sys_data;
end


always @(posedge video_clk) begin
  video_data <= mem[video_addr];
end     
                   
endmodule