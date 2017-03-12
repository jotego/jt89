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

wire signed [11:0] sound;
wire signed [11:0] sound_att = sound >>> 3;
wire signed [11:0] sound_amp = sound <<< 3;

wire overflow = ^sound[10:8];
wire overflow2 = overflow ^ sound[11];
wire overflow3 = ^sound[11:8];

wire signed [11:0] sound_ov = overflow2 ? { sound[11], {11{~sound[11]}}} : sound_amp;

reg [1:0] cnt2;
reg clk_en;

always @(posedge clk)
	if( rst ) begin
		cnt2 <= 2'b0;
		clk_en <= 1'b0;
	end
	else begin
		cnt2 <= cnt2 +1'b1;		
		clk_en <= cnt2==2'b11;
	end

reg rst2;

always @(posedge clk)
	if( rst ) rst2<=1'b1;
	else if(clk_en ) rst2<=1'b0;

jt89 u_uut(
	.clk	( clk	),
	.clk_en	( 1'b1  ),
	.rst	( rst2	),
	.wr_n	( wr_n	),
	.din	( din	),
	.ch0	( ch0	),
	.ch1	( ch1	),
	.ch2	( ch2	),
	.noise	( noise	),
	.sound	( sound	)
);


endmodule
