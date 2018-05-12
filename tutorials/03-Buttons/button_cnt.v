module button_cnt (
    input CLK,
    output LED_R,
    output LED_G,
    output LED_B,
    output LCD_PWM,
    input B0
);

    reg [2:0] cnt = 0;

    always @(posedge B0)
    begin
        cnt <= cnt + 1;
    end

    assign LCD_PWM = 1'b0;
    
    assign LED_R = !cnt[0];
    assign LED_G = !cnt[1];
    assign LED_B = !cnt[2];
endmodule
