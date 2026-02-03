`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/27/2026 10:34:31 AM
// Design Name: 
// Module Name: test_module
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module FPCVT(input[11:0] ogtc, output[7:0] result);
wire [11:0] abstc;
wire sign_bit;

wire [2:0] exp;
wire [3:0] figs;
wire [3:0] i;

wire [2:0] nexp;
wire [3:0] nfigs;

absolute_value abs_convert(
    .ogtc(ogtc),
    .abstc(abstc),
    .sign_bit(sign_bit)
);

extract_bits extract(
    .abstc(abstc),
    .exp(exp),
    .figs(figs),
    .i(i)
);

rounding rounded(
    .abstc(abstc),
    .i(i),
    .exp(exp),
    .figs(figs),
    .nexp(nexp),
    .nfigs(nfigs)
);

assign result = {sign_bit, nexp, nfigs};
endmodule

// ogtc = original two's complement
// abstc = absolute value two's complement
module absolute_value(ogtc, abstc, sign_bit);

input  [11:0] ogtc; 
output [11:0] abstc;
output sign_bit;
reg [11:0] val;

always @(*) begin
    if (ogtc == 12'b111111111111) begin
        val = 12'b011111111111;
    end
    else begin
        val = ogtc[11] ? (~ogtc + 1) : ogtc;
    end
end
assign sign_bit = ogtc[11];
assign abstc = val;
endmodule

// extract E and F
module extract_bits(abstc, exp, figs, i);

input [11:0] abstc;
output reg [2:0] exp;
output reg [3:0] figs;

output reg [3:0] i;

always@(*) begin
    
    i = 3;
    
    if (abstc[11]) begin
        i = 4'd11;
    end
    else if (abstc[10]) begin 
        i = 4'd10;
    end
    else if (abstc[9]) begin 
        i = 4'd9;
    end
    else if (abstc[8]) begin 
        i = 4'd8;
    end
    else if (abstc[7]) begin 
        i = 4'd7;
    end
    else if (abstc[6]) begin 
        i = 4'd6;
    end
    else if (abstc[5]) begin 
        i = 4'd5;
    end
    else if (abstc[4]) begin 
        i = 4'd4;
    end
    else begin 
        i = 4'd3;
    end
   
    exp = 8-(11-i);
    figs = abstc[i -: 4];
end 

endmodule

module rounding(abstc, i, exp, figs, nexp, nfigs);

input [11:0] abstc;
input [3:0] i;

input [2:0] exp;
input [3:0] figs;

output reg [2:0] nexp;
output reg [3:0] nfigs;

//look at i and see where the fifth bit is: i-4
//if it is 0, output as is
//if 1 add 1 to figs and increment exp
//edge cases: figs and exp overflow

reg [1:0] rounding_bit;
always @(*) begin
    nexp = exp;
    nfigs = figs;
    if (i > 3) begin
        rounding_bit = abstc[i-4];
        if (rounding_bit) begin
            if (figs == 4'b1111 && exp != 3'b111) begin
                nfigs = 4'b1000;
                nexp = exp + 1;
            end
            else if (figs == 4'b1111 && exp == 3'b111) begin
                nfigs = 4'b1111;
                nexp = 4'b111;
            end
            else begin
                nfigs = figs + 1;
                nexp = exp;
            end
        end
    end
end

endmodule