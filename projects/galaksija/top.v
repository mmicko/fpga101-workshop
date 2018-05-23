module top(
    output LCD_CLK,
    output [7:0] LCD_DAT,
    output LCD_HS,
    output LCD_VS,
    output LCD_DEN,
    output LCD_RST,
    output LCD_PWM,
	output mreq_n,
	input ser_rx);

/* ------------------------
       Clock generator 
   ------------------------*/

wire clk;
wire locked;
wire pixclk;

(* ROUTE_THROUGH_FABRIC=1 *)
SB_HFOSC #(.CLKHF_DIV("0b10")) hfosc_i (
  .CLKHFEN(1'b1),
  .CLKHFPU(1'b1),
  .CLKHF(clk)
);

reg [5:0] reset_cnt = 0;
wire resetn = &reset_cnt;

always @(posedge clk) begin
	reset_cnt <= reset_cnt + !resetn;
end


pll pll_i(.clock_in(clk), .clock_out(pixclk), .locked(locked));

/* ----------------------------
       Video signal generator 
   ----------------------------*/

reg [23:0] rgb_data;
wire [9:0] h_pos;
wire [9:0] v_pos;
reg rd_ram1;
reg wr_ram1;
wire [7:0] ram1_out;

	wire [15:0] addr;
	wire [7:0] odata;

assign LCD_CLK = pixclk;
assign LCD_RST = 1'b1;
assign LCD_PWM = 1'b1;
video generator ( .clk(pixclk), // pixel clock in
                  .resetn(locked),
                  .lcd_dat(LCD_DAT),
                  .lcd_hsync(LCD_HS),
                  .lcd_vsync(LCD_VS),
                  .lcd_den(LCD_DEN),
                  .rd_ram1(rd_ram1),
                  .wr_ram1(wr_ram1),
                  .ram1_out(ram1_out),
				  .addr(addr[10:0]),
				  .data(odata));


/* ----------------------------
       Custom video generator 
   ----------------------------*/



	reg ce = 0;
	reg [7:0] idata;

	wire m1_n;
	wire mreq_n;
	wire iorq_n;
	wire rd_n;
	wire wr_n;
	wire rfsh_n;
	wire halt_n;
	wire busak_n;
	wire wait_n = 1'b1;
	reg int_n = 1'b1;
	wire nmi_n = 1'b1;
	wire busrq_n = 1'b1;
		
	reg keys[63:0];

	wire rx_valid;
	wire [7:0] uart_out;
	wire starting;
	uart_rx uart(
		.clk(clk),
		.resetn(locked),

		.ser_rx(ser_rx),

		.cfg_divider(12000000/9600),

		.data(uart_out),
		.valid(rx_valid),

		.starting(starting)
	);

	integer num;
	initial 
	begin
		for(num=0;num<63;num=num+1)
		begin
			keys[num] <= 0;
		end
	end

	reg[31:0] int_cnt = 0;

	always @(posedge clk) begin
		if (int_cnt==(12000000 / (50 * 2)))
		begin
			int_n <= 1'b0;		
			int_cnt <= 0;
		end
		else
		begin
			int_n <= 1'b1;		
			int_cnt <= int_cnt + 1;
		end
	end

	wire [7:0] rom1_out;
	wire [7:0] rom2_out;	

	wire [7:0] ram00_out;
	wire [7:0] ram01_out;
	wire [7:0] ram10_out;
	wire [7:0] ram11_out;

	reg [7:0] key_out;
	
	reg rd_rom1;
	reg rd_rom2;

	reg rd_ram2;

	reg wr_ram2;

	reg rd_key;
	reg wr_latch;

	always @(*)
	begin
		rd_rom1 = 0;		
		rd_rom2 = 0;

		rd_ram1 = 0;
		rd_ram2 = 0;

		wr_ram1 = 0;
		wr_ram2 = 0;

		rd_key = 0;

		wr_latch = 0;

		casex ({~wr_n,~rd_n,mreq_n,addr[15:0]})
			// MEM MAP
			{3'b010,16'b0000xxxxxxxxxxxx}: begin idata = rom1_out; rd_rom1 = 1; end         // 0x0000-0x0fff
			{3'b010,16'b0001xxxxxxxxxxxx}: begin idata = rom2_out; rd_rom2 = 1; end         // 0x1000-0x1fff

			{3'b010,16'b00100xxxxxxxxxxx}: begin idata = key_out;  rd_key = 1; end         // 0x2000-0x27ff

			{3'b010,16'b00101xxxxxxxxxxx}: begin idata = ram1_out; rd_ram1 = 1; end         // 0x2800-0x2fff
			{3'b010,16'b00110xxxxxxxxxxx}: begin idata = ram00_out; rd_ram2 = 1; end         // 0x3000-0x37ff
			{3'b010,16'b00111xxxxxxxxxxx}: begin idata = ram00_out; rd_ram2 = 1; end         // 0x3800-0x3fff
			{3'b010,16'b01xxxxxxxxxxxxxx}: begin idata = ram01_out; rd_ram2 = 1; end         // 0x4000-0xffff
			{3'b010,16'b10xxxxxxxxxxxxxx}: begin idata = ram10_out; rd_ram2 = 1; end         // 0x4000-0xffff
            {3'b010,16'b11xxxxxxxxxxxxxx}: begin idata = ram11_out; rd_ram2 = 1; end         // 0x4000-0xffff

			// MEM MAP
			{3'b100,16'b00100xxxxxxxxxxx}: wr_latch= 1; // 0x2000-0x27ff
			{3'b100,16'b00101xxxxxxxxxxx}: wr_ram1= 1; // 0x2800-0x2fff
			{3'b100,16'b00110xxxxxxxxxxx}: wr_ram2= 1; // 0x3000-0x37ff
			{3'b100,16'b00111xxxxxxxxxxx}: wr_ram2= 1; // 0x3000-0x37ff
			{3'b100,16'b01xxxxxxxxxxxxxx}: wr_ram2= 1;
			{3'b100,16'b10xxxxxxxxxxxxxx}: wr_ram2= 1;
			{3'b100,16'b11xxxxxxxxxxxxxx}: wr_ram2= 1;
			//{3'b100,16'b10xxxxxxxxxxxxxx}: wr_ram2= 1;			
			
			//{3'b100,16'b11xxxxxxxxxxxxxx}: wr_ram2= 1; // 0x3000-0x37ff
		endcase
	end
	
	reg prev_starting = 0;
	always @(posedge clk) 
	begin	
		prev_starting	<= starting;
		if (starting==1 && prev_starting==0)
		begin
			for(num=0;num<63;num=num+1)
			begin
				keys[num] <= 0;
			end
		end
		if (rd_key)
		begin
			key_out <= (keys[addr[5:0]]==1) ? 8'hfe : 8'hff;
		end			

		if(rx_valid)
		begin
			for(num=0;num<63;num=num+1)
			begin
				keys[num] <= 0;
			end
			if (uart_out>="A" && uart_out<="Z")  keys[uart_out-8'd64] <= 1;
			if (uart_out>="a" && uart_out<="z") keys[uart_out-8'd96] <= 1;
			if (uart_out>="0" && uart_out<="9")  keys[uart_out-8'd48+8'd32] <= 1;
			if (uart_out==8'd10 || uart_out==8'd13)  keys[8'd48] <= 1; // ENTER
			if (uart_out==8'd8 || uart_out==8'd127)  keys[8'd29] <= 1; // BACKSPACE to CURSOR LEFT
			if (uart_out==8'd27)  keys[8'd49] <= 1; // ESC to BREAK

			if (uart_out==" ")  keys[8'd31] <= 1;
			if (uart_out=="_") begin keys[8'd32] <= 1; keys[8'd53] <= 1; end
			if (uart_out=="!") begin keys[8'd33] <= 1; keys[8'd53] <= 1; end
			if (uart_out=="\"") begin keys[8'd34] <= 1; keys[8'd53] <= 1; end
			if (uart_out=="#") begin keys[8'd35] <= 1; keys[8'd53] <= 1; end
			if (uart_out=="$") begin keys[8'd36] <= 1; keys[8'd53] <= 1; end
			if (uart_out=="%") begin keys[8'd37] <= 1; keys[8'd53] <= 1; end
			if (uart_out=="&") begin keys[8'd38] <= 1; keys[8'd53] <= 1; end
			if (uart_out=="\\") begin keys[8'd39] <= 1; keys[8'd53] <= 1; end

			if (uart_out=="(") begin keys[8'd40] <= 1; keys[8'd53] <= 1; end
			if (uart_out==")") begin keys[8'd41] <= 1; keys[8'd53] <= 1; end
			if (uart_out=="+") begin keys[8'd42] <= 1; keys[8'd53] <= 1; end
			if (uart_out=="*") begin keys[8'd43] <= 1; keys[8'd53] <= 1; end
			if (uart_out=="<") begin keys[8'd44] <= 1; keys[8'd53] <= 1; end
			if (uart_out=="-") begin keys[8'd45] <= 1; keys[8'd53] <= 1; end
			if (uart_out==">") begin keys[8'd46] <= 1; keys[8'd53] <= 1; end
			if (uart_out=="?") begin keys[8'd47] <= 1; keys[8'd53] <= 1; end

			if (uart_out==";") begin keys[8'd42] <= 1; end
			if (uart_out==":") begin keys[8'd43] <= 1; end
			if (uart_out==",") begin keys[8'd44] <= 1; end
			if (uart_out=="=") begin keys[8'd45] <= 1; end
			if (uart_out==".") begin keys[8'd46] <= 1; end
			if (uart_out=="/") begin keys[8'd47] <= 1; end
		end
	end
	
	tv80n cpu (
		.m1_n(m1_n), .mreq_n(mreq_n), .iorq_n(iorq_n), 
		.rd_n(rd_n), .wr_n(wr_n), .rfsh_n(rfsh_n), .halt_n(halt_n), .busak_n(busak_n),
		.A(addr), .do(odata), 
		.reset_n(resetn), .clk(clk), .wait_n(wait_n), .int_n(int_n), .nmi_n(nmi_n), .busrq_n(busrq_n), .di(idata)
	);
	
	rom_memory #(.ADDR_WIDTH(12),.FILENAME("galrom1.bin.mem")) rom1(.clk(clk),.addr(addr[11:0]),.rd(rd_rom1),.data_out(rom1_out));
	rom_memory #(.ADDR_WIDTH(12),.FILENAME("galrom2.bin.mem")) rom2(.clk(clk),.addr(addr[11:0]),.rd(rd_rom2),.data_out(rom2_out));
	
reg [7:0] tmp00;
reg [7:0] tmp01;
reg [7:0] tmp10;
reg [7:0] tmp11;

wire cs_0,cs_1;
wire cs_2,cs_3;

assign cs_0 = ~addr[15] & ~addr[14];
assign cs_1 = ~addr[15] &  addr[14];
assign cs_2 =  addr[15] & ~addr[14];
assign cs_3 =  addr[15] &  addr[14];

SB_SPRAM256KA ram00
  (
    .ADDRESS(addr[13:0]),
    .DATAIN({ 8'd0,odata[7:0]}),
    .MASKWREN({2'b0, wr_ram2, wr_ram2}),
    .WREN(wr_ram2),
    .CHIPSELECT(cs_0),
    .CLOCK(clk),
    .STANDBY(1'b0),
    .SLEEP(1'b0),
    .POWEROFF(1'b1),
    .DATAOUT({tmp00, ram00_out[7:0]})
  );

SB_SPRAM256KA ram01
  (
    .ADDRESS(addr[13:0]),
    .DATAIN({ 8'd0,odata[7:0]}),
    .MASKWREN({2'b0, wr_ram2, wr_ram2}),
    .WREN(wr_ram2),
    .CHIPSELECT(cs_1),
    .CLOCK(clk),
    .STANDBY(1'b0),
    .SLEEP(1'b0),
    .POWEROFF(1'b1),
    .DATAOUT({tmp01, ram01_out[7:0]})
  );

SB_SPRAM256KA ram10
  (
    .ADDRESS(addr[13:0]),
    .DATAIN({ 8'd0,odata[7:0]}),
    .MASKWREN({2'b0, wr_ram2, wr_ram2}),
    .WREN(wr_ram2),
    .CHIPSELECT(cs_2),
    .CLOCK(clk),
    .STANDBY(1'b0),
    .SLEEP(1'b0),
    .POWEROFF(1'b1),
    .DATAOUT({tmp10, ram10_out[7:0]})
  );

SB_SPRAM256KA ram11
  (
    .ADDRESS(addr[13:0]),
    .DATAIN({ 8'd0,odata[7:0]}),
    .MASKWREN({2'b0, wr_ram2, wr_ram2}),
    .WREN(wr_ram2),
    .CHIPSELECT(cs_3),
    .CLOCK(clk),
    .STANDBY(1'b0),
    .SLEEP(1'b0),
    .POWEROFF(1'b1),
    .DATAOUT({tmp11, ram11_out[7:0]})
  );        
endmodule
