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
	SMS core of MiST
	
	*/
	
module jt89_noise(
	input	clk,
	input	clken,
	input	rst,
	input	clr,
	input [9:0] tone,	
	input [2:0] ctrl3,
	input [3:0] vol,
	input		ch2,
	output signed reg [9:0] snd;
);

reg [15:0] shift;
reg [9:0] cnt;
reg			v;

reg	[8:0] max;

always @(*)
	case ( vol )
		4'd0: max <= 9'd511;
		4'd1: max <= 9'd322;
		4'd2: max <= 9'd203;
		4'd3: max <= 9'd128;
		4'd4: max <= 9'd81;
		4'd5: max <= 9'd51;
		4'd6: max <= 9'd32;
		4'd7: max <= 9'd20;
		4'd8: max <= 9'd13;
		4'd9: max <= 9'd8;
		4'd10: max <= 9'd5;
		4'd11: max <= 9'd3;
		4'd12: max <= 9'd2;
		4'd13: max <= 9'd1;
		4'd14: max <= 9'd1;
		4'd15: max <= 9'd0;
	endcase


always @(posedge clk) begin
	if( rst )
		snd <= 10'd0;
	else
		snd <= shift[0] ? {1'b0, max } : ( (~max)+1'b1 );
end

always @(posedge clk)
	if( rst ) begin
		cnt <= 10'd0;
		v <= 1'b0;
	end
	else if( clken ) begin
		if( ctrl3==2'b11 )
			v <= ch2;
		else begin
			if( !cnt ) begin
				v <= ~v;
				case( ctrl3[1:0] )
					2'd0: cnt <= 10'h010;
					2'd1: cnt <= 10'h020;
					2'd2: cnt <= 10'h040;
				endcase
			end
			else cnt <= cnt - 1'b1;
		end
	end
	
always @(posedge clk)
	if( rst || clr )
		shift = { 1'b1, 14'd0 };
	else if( clken && !v) begin
		shift <= { ctrl3[2]?(shift[0]^shift[3]):shift[0], shift[15:1]};
	end
endmodule
