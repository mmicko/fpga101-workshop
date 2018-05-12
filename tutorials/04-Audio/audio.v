module audio(
    input CLK,
    output LCD_PWM,
    input B0,
    input B1,
    input B2,
    input B3,
    input B4,
    input B5,
    output reg AUDIO);

parameter TONE_A4 = 12000000/440/2;
parameter TONE_B4 = 12000000/494/2;
parameter TONE_C5 = 12000000/523/2;
parameter TONE_D5 = 12000000/587/2;
parameter TONE_E5 = 12000000/659/2;
parameter TONE_F5 = 12000000/698/2;
parameter TONE_G5 = 12000000/783/2;

reg [14:0] counter;

always @(posedge CLK) 
    if(counter==0) counter <= (B0 ? TONE_A4-1 : 
                               B1 ? TONE_B4-1 : 
                               B2 ? TONE_C5-1 : 
                               B3 ? TONE_D5-1 : 
                               B4 ? TONE_E5-1 : 
                               B5 ? TONE_F5-1 : 
                               0); else counter <= counter-1;

always @(posedge CLK) 
    if(counter==0) 
        AUDIO <= ~AUDIO;

assign LCD_PWM = 1'b0;
endmodule
