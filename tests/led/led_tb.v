`default_nettype none
`timescale 100 ns / 10 ns

module led_tb();

reg clk = 0;

wire led;

always 
  #5 clk = ~clk;

  led unit(.LED_B(led));


initial begin
  $dumpfile("led_tb.vcd");
  $dumpvars(0, led_tb);

  #100 $display("finish");
  $finish;
end

endmodule
