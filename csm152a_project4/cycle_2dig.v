`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/26/2026 10:54:05 AM
// Design Name: 
// Module Name: cycle_2dig
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

// dig_sel=0 ? left digit,  dig_sel=1 ? right digit.
// Refresh rate: clk_div bit selects toggle frequency.

module cycle_2dig (
    input        clk,
    input        rst,
    input  [3:0] digit_l,     
    input  [3:0] digit_r,    
    output [6:0] seg,
    output reg   dig_sel,     // 0=left anode on, 1=right anode on
    output [1:0] anode
);
    reg [15:0] cnt;
    reg [3:0]  disp_val;

    always @(posedge clk or posedge rst) begin
        if (rst) cnt <= 0;
        else cnt <= cnt + 1;
    end

    always @(*) begin
        dig_sel  = cnt[15];
        disp_val = dig_sel ? digit_r : digit_l;
    end

    assign anode = dig_sel ? 2'b10 : 2'b01;

    seg7_encoder enc (.hex(disp_val), .seg(seg));
endmodule

module seg7_encoder (
    input  [3:0] hex,
    output reg [6:0] seg  // segments: gfedcba
);
    always @(*) begin
        case (hex)
            4'h0: seg = 7'b0111111;
            4'h1: seg = 7'b0000110;
            4'h2: seg = 7'b1011011;
            4'h3: seg = 7'b1001111;
            4'h4: seg = 7'b1100110;
            4'h5: seg = 7'b1101101;
            4'h6: seg = 7'b1111101;
            4'h7: seg = 7'b0000111;
            4'h8: seg = 7'b1111111;
            4'h9: seg = 7'b1101111;
            4'hA: seg = 7'b1110111;
            4'hB: seg = 7'b1111100;
            4'hC: seg = 7'b0111001;
            4'hD: seg = 7'b1011110;
            4'hE: seg = 7'b1111001;
            4'hF: seg = 7'b1110001;
            default: seg = 7'b0000000;
        endcase
    end
endmodule