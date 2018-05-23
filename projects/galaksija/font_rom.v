module font_rom(
  input clk,
  input [10:0] addr,
  output [7:0] data_out
);

  reg [7:0] store[0:2047] /* verilator public_flat */;

  initial
  begin
		$readmemh("galchr.mem", store);
  end

  always @(posedge clk)
		data_out <= store[addr];
endmodule
