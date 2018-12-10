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
   
    */

module jt89_mixer(
    input            rst,
    input            clk,
    input            clk_en,
    input            cen_16,
    input     [ 8:0] ch0,
    input     [ 8:0] ch1,
    input     [ 8:0] ch2,
    input     [ 8:0] noise,
    output    [10:0] sound
);

reg signed [11:0] a,b,c;
reg signed [10:0] fresh, old;

always @(*)
    fresh = {2'b0,  ch0} +
            {2'b0,  ch1} +
            {2'b0,  ch2} +
            {2'b0,noise};

// Comb filter
reg signed [14:0] comb1, old_comb1, comb2;
always @(posedge clk) if(cen_16) begin
    old <= fresh;
    comb1 <= fresh-old;
    old_comb1 <= comb1;
    comb2 <= comb1-old_comb1;
end

// interpolator x16
reg signed [14:0] interp;
always @(posedge clk) if(clk_en) begin // clk_en = 16xcen_16
    interp <= cen_16 ? comb2 : 15'd0;

// integrator
reg signed [14:0] integ1, integ2;
always @(posedge clk) 
    if( rst ) begin
        integ1 <= 15'd0;
        integ2 <= 15'd0;
    end else if(clk_en) begin
        integ1 <= integ1 + comb2;
        integ2 <= integ2 + integ1;
    end
// scale back
assign sound = integ2[14:4];



endmodule