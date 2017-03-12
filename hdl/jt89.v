/*  This file is part of JT89.

	JT89 is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	JT89 is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with JT89.  If not, see <http://www.gnu.org/licenses/>.

	Author: Jose Tejada Gomez. Twitter: @topapate
	Version: 1.0
	Date: March, 8th 2017
	
	This work was originally based in the implementation found on the
	SMS core of MiST. Some of the changes, all according to data sheet:
	
		-Fixed volume
		-Fixed tone 2 rate option of noise generator
		-Fixed rate of noise generator
		-Fixed noise shift clear
		-Fixed noise generator update bug by which it gets updated
			multiple times if v='0'
		-Added all 0's prevention circuit to noise generator
	
	*/

`timescale 1ns / 1ps

module jt89(
	input	clk,
(* direct_enable = 1 *)	input	clk_en,
	input	rst,
	input	wr_n,
	input	[7:0] din,
	output	signed [9:0] ch0,
	output	signed [9:0] ch1,
	output	signed [9:0] ch2,
	output	signed [9:0] noise,
	output signed [11:0] sound
);

assign sound = ch0+ch1+ch2+noise;

// configuration registers
reg [9:0] tone0, tone1, tone2;
reg [3:0] vol0, vol1, vol2, vol3;
reg [2:0] ctrl3;
reg [2:0] regn;

reg	[3:0] clk_div;
reg clk_en_32, clk_en_32_aux;

always @(posedge clk )
	if( rst ) begin
		clk_en_32 <= 1'b1;
		clk_en_32_aux <= 1'b1;
	end	else begin
		clk_en_32_aux <= &clk_div;
		clk_en_32 <= !clk_en_32_aux && (&clk_div);
	end

always @(posedge clk ) if( clk_en ) begin
	if( rst ) 
		clk_div <= 4'd0;
	else 
		clk_div <= clk_div + 1'b1;
end

reg clr_noise;

always @(posedge clk) if( clk_en ) begin
	if( rst ) begin
		{ vol0, vol1, vol2, vol3 } <= {16{1'b1}};
		{ tone0, tone1, tone2 } <= 30'd0;
		ctrl3 <= 3'b100;
	end
	else 
	if( !wr_n ) begin
		clr_noise <= din[7:4] == 4'b1110; // clear noise
			// when there is an access to the control register
		if( din[7] ) begin
			regn <= din[6:4];
			case( din[6:4] )
				3'b000: tone0[3:0] <= din[3:0];
				3'b010: tone1[3:0] <= din[3:0];
				3'b100: tone1[3:0] <= din[3:0];
				3'b110: ctrl3	   <= din[2:0];
				3'b001: vol0	   <= din[3:0];
				3'b011: vol1	   <= din[3:0];
				3'b101: vol2	   <= din[3:0];
				3'b111: vol3	   <= din[3:0];
			endcase
		end else begin
			case( regn )
				3'b000: tone0[9:4] <= din[5:0];
				3'b010: tone1[9:4] <= din[5:0];
				3'b100: tone1[9:4] <= din[5:0];
				3'b001: vol0	   <= din[3:0];
				3'b011: vol1	   <= din[3:0];
				3'b101: vol2	   <= din[3:0];
				3'b111: vol3	   <= din[3:0];
			endcase
		end
	end
	else clr_noise <= 1'b0;
end

reg rst_int;

always @(posedge clk or posedge rst) 
	if( rst )
		rst_int <= 1'b1;
	else if(clk_en_32 ) rst_int <= 1'b0;

jt89_tone u_tone0(
	.clk	( clk		),
	.rst	( rst_int	),
	.clk_en	( clk_en_32	),
	.vol	( vol0		),
	.tone	( tone0		),
	.snd	( ch0		)
);

jt89_tone u_tone1(
	.clk	( clk		),
	.rst	( rst_int	),	
	.clk_en	( clk_en_32	),
	.vol	( vol1		),
	.tone	( tone1		),
	.snd	( ch1		)
);

wire out2;

jt89_tone u_tone2(
	.clk	( clk		),
	.rst	( rst_int	),
	.clk_en	( clk_en_32	),
	.vol	( vol2		),
	.tone	( tone2		),
	.snd	( ch2		),
	.out	( out2		)
);

jt89_noise u_noise(
	.clk	( clk		),
	.rst	( rst_int	),
	.clk_en	( clk_en_32	),
	.clr	( clr_noise	),
	.vol	( vol3		),
	.ctrl3	( ctrl3		),
	.ch2	( out2		),
	.snd	( noise		)
);

endmodule
