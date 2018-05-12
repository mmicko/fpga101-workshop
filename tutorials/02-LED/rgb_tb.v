`timescale 1ns/1ps 
module rgb_tb();
	reg clk = 0;	
    wire led_r;
    wire led_g;
    wire led_b;
    wire led_pwm;

	rgb leds(.CLK(clk),.LED_R(led_r),.LED_G(led_g),.LED_B(led_b),.LCD_PWM(led_pwm));

	always
		#(5) clk <= !clk;

	initial
	begin
		$dumpfile("rgb_tb.vcd");
		$dumpvars(0,rgb_tb);
		#1000
		$finish;
	end
endmodule
