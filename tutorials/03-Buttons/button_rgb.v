module button_rgb (
    input CLK,
    output LED_R,
    output LED_G,
    output LED_B,
    output LCD_PWM,
    input B0,
    input B1,
    input B2
);
    assign LCD_PWM = 1'b0;
    
    assign LED_R = !B0;
    assign LED_G = !B1;
    assign LED_B = !B2;
endmodule
