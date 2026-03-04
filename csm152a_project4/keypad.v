`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/26/2026 11:03:03 AM
// Design Name: 
// Module Name: keypad
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

// keypad.v
// Validates an 8-bit snack_code {hex_l, hex_r} against a lookup table
// of valid codes.  On match, outputs the 4-letter snack name as four
// 6-bit letter indices (for letter_encoder).  On miss, pulses is_invalid.
//
// Snack table (extend freely):
//   Code  Name
//   8'h1A  COLA   ? C O L A
//   8'h2B  CHIP   ? C H I P
//   8'h3C  NUTS   ? N U T S
//   8'h4D  GUMI   ? G U M I
//   8'h5E  OREO   ? O R E O
//   (add more as needed)

module keypad (
    input        clk,
    input        rst,
    input  [7:0] snack_code,    // from input_buffer
    input        snack_valid,   // single-cycle trigger

    // 4 letter indices for the 4-digit display (letter_encoder input)
    output reg [5:0] ch0, ch1, ch2, ch3,  // leftmost?rightmost
    output reg       is_valid,
    output reg       is_invalid  // single-cycle pulse on bad code
);
    // Letter constants (A=0 … Z=25, space=26)
    localparam A=0,B=1,C=2,D=3,E=4,F=5,G=6,H=7,I=8,J=9,
               K=10,L=11,M=12,N=13,O=14,P=15,Q=16,R=17,S=18,
               T=19,U=20,V=21,W=22,X=23,Y=24,Z=25,SPC=26;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ch0 <= SPC; ch1 <= SPC; ch2 <= SPC; ch3 <= SPC;
            is_valid <= 0; is_invalid <= 0;
        end else begin
            is_valid   <= 1'b0;
            is_invalid <= 1'b0;

            if (snack_valid) begin
                case (snack_code)
                    8'h1A: begin {ch0,ch1,ch2,ch3} <= {C,H,I,P}; is_valid <= 1; end
                    8'h2A: begin {ch0,ch1,ch2,ch3} <= {B,A,R,SPC}; is_valid <= 1; end
                    8'h3A: begin {ch0,ch1,ch2,ch3} <= {C,H,O,C}; is_valid <= 1; end
                    8'h4B: begin {ch0,ch1,ch2,ch3} <= {N,U,T,S}; is_valid <= 1; end
                    8'h5B: begin {ch0,ch1,ch2,ch3} <= {C,A,K,E}; is_valid <= 1; end
                    8'h6B: begin {ch0,ch1,ch2,ch3} <= {O,R,E,O}; is_valid <= 1; end
                    8'h7C: begin {ch0,ch1,ch2,ch3} <= {C,A,F,E}; is_valid <= 1; end
                    8'h8C: begin {ch0,ch1,ch2,ch3} <= {A,C,A,I}; is_valid <= 1; end
                    8'h9C: begin {ch0,ch1,ch2,ch3} <= {R,A,N,D}; is_valid <= 1; end //need to figure out how to randomize
                    default: begin
                        {ch0,ch1,ch2,ch3} <= {SPC,SPC,SPC,SPC};
                        is_invalid <= 1;
                    end
                endcase
            end
        end
    end
endmodule