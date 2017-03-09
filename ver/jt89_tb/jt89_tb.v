`timescale 1ns / 1ps

module jt89_tb;

wire signed [9:0] ch0, ch1, ch2, noise;
reg clk, rst, wr_n;
reg [7:0] din;

initial begin
	$dumpfile("jt89_tb.lxt");
	$dumpvars;
	$dumpon;
end

initial begin
	clk = 0;
	forever #10 clk = ~clk;
end

initial begin
	rst = 0;
	din = 8'd0;
	wr_n= 1'b1;
	#5 rst = 1;
	#35 rst = 0;
	// tone 0
	wr_n=1'b0;
	din = { 1'b1, 3'b000, 4'b1111 };
	#500;
	din = { 3'b000, 5'b1111 };
	#500;
	// vol noise
	din = { 1'b1, 3'b111, 4'b1010 };
	#500;
	// tone 1
	din = { 1'b1, 3'b010, 4'b0011 };
	#500;
	din = { 3'b000, 5'b1001 };
	#500;
	// tone 2
	din = { 1'b1, 3'b100, 4'b1000 };
	#500;
	din = { 3'b000, 5'b0110 };
	#500;
	// vol 0
	din = { 1'b1, 3'b001, 4'b1000 };
	#500;
	// vol 1
	din = { 1'b1, 3'b011, 4'b0100 };
	#500;
	// vol 2
	din = { 1'b1, 3'b101, 4'b0010 };
	#500;
	// ctrl3
	//din = { 1'b1, 3'b110, 4'b0111 };
	#500;
	#1000000 
	// vol 0
	din = { 1'b1, 3'b001, 4'b0100 };
	#1000000 
	// vol 0
	din = { 1'b1, 3'b001, 4'b0010 };
	#1000000 
	// vol 0
	din = { 1'b1, 3'b001, 4'b0001 };
	#1000000 
	// vol 0
	din = { 1'b1, 3'b001, 4'b0000 };
	#1000000 
	// vol 0
	din = { 1'b1, 3'b001, 4'b1111 };
	// Change to use ch2 for noise rate
	// ctrl3
	din = { 1'b1, 3'b110, 4'b0111 };	

	#500;
	wr_n=1'b1;
	#900000 $finish;
end

jt89 u_uut(
	.clk	( clk	),
	.clken	( 1'b1	),
	.rst	( rst	),
	.wr_n	( wr_n	),
	.din	( din	),
	.ch0	( ch0	),
	.ch1	( ch1	),
	.ch2	( ch2	),
	.noise	( noise	)
);


endmodule
