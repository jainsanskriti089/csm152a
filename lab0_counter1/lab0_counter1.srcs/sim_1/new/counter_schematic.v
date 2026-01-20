`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/08/2026 11:18:40 AM
// Design Name: 
// Module Name: counter_schematic
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


module counter_schematic(input clk, input rst);
    reg a0;
    reg a1;
    reg a2;
    reg a3;
    always @ (posedge clk)
        if (rst)
            a0 <= 1'b0;
        else
            a0 <= ~a0;
    always @ (posedge clk)
        if (rst)
            a1 <= 1'b0;
        else
            a1 <= a0^a1;
    always @ (posedge clk)
        if (rst)
            a2 <= 1'b0;
        else
            a2 <= (a0 & a1)^a2;
    always @ (posedge clk)
        if (rst)
            a3 <= 1'b0;
        else
            a3 <= (a0&a1&a2)^a3;
endmodule
