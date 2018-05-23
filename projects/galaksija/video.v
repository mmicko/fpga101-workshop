module video (input clk, //19.2MHz pixel clock in
              input resetn,
              output reg [7:0] lcd_dat,
              output reg lcd_hsync,
              output reg lcd_vsync,
              output reg lcd_den,
              input rd_ram1,
              input wr_ram1,
              input [10:0] addr,
              output reg [7:0] ram1_out,
              input [7:0] data

);
              
reg [9:0] h_pos;
reg [9:0] v_pos;
wire [23:0] rgb_data;
            
parameter h_visible = 10'd320;
parameter h_front = 10'd20;
parameter h_sync = 10'd30;
parameter h_back = 10'd38;
parameter h_total = h_visible + h_front + h_sync + h_back;

parameter v_visible = 10'd240;
parameter v_front = 10'd4;
parameter v_sync = 10'd3;
parameter v_back = 10'd15;
parameter v_total = v_visible + v_front + v_sync + v_back;

reg [1:0] channel = 0;

wire h_active, v_active, visible;
wire [23:0] rgb_data;

reg [3:0] text_v_pos;
reg [3:0] font_line;

always @(posedge clk) 
begin
  if (resetn == 0) begin
    h_pos <= 10'b0;
    v_pos <= 10'b0;
    text_v_pos <= 4'b0;
    font_line  <= 4'b0;
  end else begin
    //Pixel counters
    if (channel == 2) begin
      channel <= 0;
      if (h_pos == h_total - 1) begin
        h_pos <= 0;
        if (v_pos == v_total - 1) begin
          v_pos <= 0;
          text_v_pos <= 0;
          font_line <= 0;
        end else begin
          v_pos <= v_pos + 1;          
          if (font_line != 10'd12)
            font_line <= font_line + 1;            
          else
          begin
            font_line <= 0;
            text_v_pos <= text_v_pos + 1;
          end
        end
      end else begin
        h_pos <= h_pos + 1;
        rgb_data <= (h_pos < 32*8 && v_pos<208) ? data_out[h_pos[2:0]] ? 24'h000000 : 24'hffffff : 24'h000000 ;
      end
    end else begin
      channel <= channel + 1;
    end
    lcd_den <= !visible;
    lcd_hsync <= !((h_pos >= (h_visible + h_front)) && (h_pos < (h_visible + h_front + h_sync)));
    lcd_vsync <= !((v_pos >= (v_visible + v_front)) && (v_pos < (v_visible + v_front + v_sync)));
    lcd_dat <= channel == 0 ? rgb_data[23:16] : 
               channel == 1 ? rgb_data[15:8]  :
               rgb_data[7:0];
  end
end

assign h_active = (h_pos < h_visible);
assign v_active = (v_pos < v_visible);
assign visible = h_active && v_active;

    wire [7:0] data_out;
    wire [7:0] code;
    wire [7:0] attr;

    reg [6:0] char;

    reg [10:0] video_addr;

    assign char = ((code>63 && code<96) || (code>127 && code<192)) ?  code - 64 :
	    (code>191) ? code -128 : code;

    font_rom galaxija_font(.clk(clk),.addr({ font_line, char }),.data_out(data_out));

    assign video_addr = {text_v_pos,5'b00000} + h_pos[9:3];
    

   reg [7:0] video_ram[0:2047];

    always @(posedge clk)
    begin
        if (wr_ram1)
            video_ram[addr[10:0]] <= data;
        if (rd_ram1)
            ram1_out <= video_ram[addr[10:0]];
        code <= video_ram[video_addr[10:0]];
    end
endmodule
