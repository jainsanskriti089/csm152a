`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/10/2026 11:51:38 AM
// Design Name: 
// Module Name: letter_encoder
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


module letter_encoder (
    input  [5:0] ch,
    output reg [6:0] seg
);
    always @(*) begin
        case (ch)
            6'd0:  seg = 7'b1110111; // A
            6'd1:  seg = 7'b1111100; // B
            6'd2:  seg = 7'b0111001; // C
            6'd3:  seg = 7'b1011110; // D
            6'd4:  seg = 7'b1111001; // E
            6'd5:  seg = 7'b1110001; // F
            6'd6:  seg = 7'b0111101; // G
            6'd7:  seg = 7'b1110110; // H
            6'd8:  seg = 7'b0000110; // I
            6'd9:  seg = 7'b0011110; // J
            6'd10: seg = 7'b1110101; // K
            6'd11: seg = 7'b0111000; // L
            6'd12: seg = 7'b0010101; // M
            6'd13: seg = 7'b1010100; // N
            6'd14: seg = 7'b0111111; // O
            6'd15: seg = 7'b1110011; // P
            6'd16: seg = 7'b1100111; // Q
            6'd17: seg = 7'b1010000; // R
            6'd18: seg = 7'b1101101; // S
            6'd19: seg = 7'b0000111; // T
            6'd20: seg = 7'b0111110; // U
            6'd21: seg = 7'b0111110; // V
            6'd22: seg = 7'b0101010; // W
            6'd23: seg = 7'b1110110; // X
            6'd24: seg = 7'b1101110; // Y
            6'd25: seg = 7'b1011011; // Z
            6'd26: seg = 7'b0000000; // space
            6'd27: seg = 7'b1000000; // dash
            default: seg = 7'b0000000;
        endcase
    end
endmodule