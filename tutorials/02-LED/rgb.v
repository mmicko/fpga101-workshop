module rgb (
    input CLK,
    output LED_R,
    output LED_G,
    output LED_B,
    output LCD_PWM
);
    assign LCD_PWM = 1'b0;
    
    reg [32:0] clk_cnt;

    initial 
    begin
        clk_cnt = 0;
    end

    always @(posedge CLK)
    begin
        clk_cnt <= clk_cnt + 1;
    end

    assign LED_R = !clk_cnt[2];
    assign LED_G = !clk_cnt[3];
    assign LED_B = !clk_cnt[4];
endmodule
