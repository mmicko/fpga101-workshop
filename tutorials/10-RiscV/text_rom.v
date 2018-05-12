module video_ram  (input sys_clk, //system side clock
                   input [9:0] sys_addr, //system side address (word address)
                   input [7:0] sys_data, //system side write data
                   input sys_wren, //bytewise wren
                   
                   input video_clk, //video side clock
                   input [9:0] video_addr, 
                   output reg [7:0] video_data);

parameter WORDS = 2 ** 10;

reg [7:0] mem [0:WORDS-1];

always @(posedge sys_clk) begin
	if (sys_wren[0]) mem[sys_addr] <= sys_data;
end


always @(posedge video_clk) begin
  video_data <= mem[video_addr];
end     
                   
endmodule