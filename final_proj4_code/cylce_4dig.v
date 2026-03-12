`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2026 10:20:27 AM
// Design Name: 
// Module Name: cylce_4dig
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

// cycle_4dig.v
// Multiplexes four 7-bit pre-encoded segment values onto one shared bus.
// Each digit gets its own pre-computed seg pattern (for letters A-Z + hex).

module cycle_4dig (
    input        clk,
    input        rst,
    input  [6:0] seg0,   // leftmost  character
    input  [6:0] seg1,
    input  [6:0] seg2,
    input  [6:0] seg3,   // rightmost character
    output reg [6:0] seg,
    output reg [3:0] anode   // active-low anodes, AN3=left, AN0=right
);
    reg [17:0] cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) cnt <= 0;
        else     cnt <= cnt + 1;
    end

    always @(*) begin
        case (cnt[17:16])
            2'd0: begin seg = ~seg0; anode = 4'b0111; end  // AN3 = leftmost
            2'd1: begin seg = ~seg1; anode = 4'b1011; end  // AN2
            2'd2: begin seg = ~seg2; anode = 4'b1101; end  // AN1
            2'd3: begin seg = ~seg3; anode = 4'b1110; end  // AN0 = rightmost
        endcase
    end
endmodule