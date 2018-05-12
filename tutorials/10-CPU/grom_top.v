module grom_top
  (input  CLK,        // Main Clock
   input  B0,         // button

   output LED_R,
   output LED_G,
   output LED_B,

   output LCD_PWM
   );

  wire [7:0] display_out;
  wire hlt;

  grom_computer computer(.clk(CLK),.reset(B0),.hlt(hlt),.display_out(display_out));

  assign LED_R = ~display_out[0];
  assign LED_G = ~display_out[1];
  assign LED_B = ~display_out[2];

  assign LCD_PWM = 0;
endmodule
