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

integer cnt;

initial begin
	rst = 0;
	din = 8'd0;
	wr_n= 1'b1;
	#5 rst = 1;
	#35 rst = 0;
	`include "inputs.vh"
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