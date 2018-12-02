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
    input               clk,
(* direct_enable = 1 *) input   clk_en,
    input               rst,
    input               clr,
    input         [2:0] ctrl3,
    input         [3:0] vol,
    input               ch2,
    output        [8:0] snd
);

reg [15:0] shift;
reg [ 7:0] cnt;
reg        update;

jt89_vol u_vol(
    .rst    ( rst     ),
    .clk    ( clk     ),
    .clk_en ( clk_en  ),
    .din    ( cnt[7]  ),
    .vol    ( vol     ),
    .snd    ( snd     )
);

reg last_ch2;

always @(posedge clk) 
    if( rst ) begin
        cnt <= 8'd0;
    end else if( clk_en ) begin
        last_ch2 <= ch2;    
        if( cnt[6:0]==7'd0 )
            case( ctrl3[1:0] )
                2'd0: cnt[6:0] <= 7'h10; // clk_en already divides by 16
                2'd1: cnt[6:0] <= 7'h20;
                2'd2: cnt[6:0] <= 7'h40;
                2'd3: cnt[6:0] <= 7'h00;
            endcase
        else
            cnt <= cnt-8'b1;
    end

always @(*)
    update = ctrl3[1:0]==2'b11 ? (ch2&& !last_ch2) : cnt[7];

wire fb = ctrl3[2]?(shift[0]^shift[3]):shift[0];
    
always @(posedge clk)
    if( rst || clr )
        shift <= { 1'b1, 15'd0 };
    else if( clk_en ) begin
        if( update) begin
            shift <= (|shift == 1'b0) ? {1'b1, 15'd0 } : {fb, shift[15:1]};
        end
    end

endmodule
