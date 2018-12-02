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
    Date: December, 1st 2018
    
    This work was originally based in the implementation found on the
    SMS core of MiST. Some of the changes, all according to data sheet:
    
    */

module jt89_mixer(
    input            rst,
    input            clk,
    input     [ 8:0] ch0,
    input     [ 8:0] ch1,
    input     [ 8:0] ch2,
    input     [ 8:0] noise,
    output    [10:0] sound
);

reg signed [10:0] a,b,c;
reg signed [10:0] fresh;

always @(*)
    fresh = {2'b0,  ch0} +
            {2'b0,  ch1} +
            {2'b0,  ch2} +
            {2'b0,noise};

assign sound = a;

always @(posedge clk) 
    if(rst) begin
        a <= 12'd0;
        b <= 12'd0;
        c <= 12'd0;
    end else begin
        a <= (a + b)>>1;
        b <= (b + c)>>1;
        c <= (c + fresh)>>1;
    end

endmodule