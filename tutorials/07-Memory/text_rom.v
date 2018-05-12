module text_rom(
  input clk,
  input [9:0] addr,
  output [7:0] data_out
);

  reg [7:0] store[0:600];

  initial
  begin
		$readmemh("text.mem", store);
  end

  always @(posedge clk) 
	  data_out <= store[addr];
endmodule
