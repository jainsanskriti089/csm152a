`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2026 10:16:42 AM
// Design Name: 
// Module Name: cycle_4dig
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
// Multiplexes four 7-bit pre-encoded segment values onto one shared bus.
// Each digit gets its own pre-computed seg pattern (for letters A-Z + hex).
module cycle_4dig (
    input        clk,
    input        rst,
    input  [6:0] seg0,   // leftmost  character segments
    input  [6:0] seg1,
    input  [6:0] seg2,
    input  [6:0] seg3,   // rightmost character segments
    output reg [6:0] seg,
    output reg [3:0] anode   // active-low, one-hot per digit
);
    reg [15:0] cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) cnt <= 0;
        else     cnt <= cnt + 1;
    end

    always @(*) begin
        case (cnt[15:14])
            2'd0: begin seg = seg0; anode = 4'b1110; end
            2'd1: begin seg = seg1; anode = 4'b1101; end
            2'd2: begin seg = seg2; anode = 4'b1011; end
            2'd3: begin seg = seg3; anode = 4'b0111; end
        endcase
    end
endmodule


// letter_encoder.v
// Encodes a 6-bit ASCII-ish code (A=0..Z=25, space=26, dash=27)
// to 7-segment patterns (segments: gfedcba, active-high).

module letter_encoder (
    input  [5:0] ch,      // 0-25 = A-Z, 26 = space, 27 = dash
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
            6'd10: seg = 7'b1110101; // K  (approx)
            6'd11: seg = 7'b0111000; // L
            6'd12: seg = 7'b0010101; // M  (approx)
            6'd13: seg = 7'b1010100; // N  (approx)
            6'd14: seg = 7'b0111111; // O
            6'd15: seg = 7'b1110011; // P
            6'd16: seg = 7'b1100111; // Q  (approx)
            6'd17: seg = 7'b1010000; // R  (approx)
            6'd18: seg = 7'b1101101; // S
            6'd19: seg = 7'b0000111; // T  (approx top bar)
            6'd20: seg = 7'b0111110; // U
            6'd21: seg = 7'b0111110; // V  (same as U on 7-seg)
            6'd22: seg = 7'b0101010; // W  (approx)
            6'd23: seg = 7'b1110110; // X  (same as H)
            6'd24: seg = 7'b1101110; // Y  (approx)
            6'd25: seg = 7'b1011011; // Z
            6'd26: seg = 7'b0000000; // space
            6'd27: seg = 7'b1000000; // dash (-)
            default: seg = 7'b0000000;
        endcase
    end
endmodule
