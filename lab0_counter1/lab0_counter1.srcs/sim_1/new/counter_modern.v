`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/08/2026 11:32:43 AM
// Design Name: 
// Module Name: counterschematic_tb
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


module counter_modern(input clk, input rst);
    reg [3:0] a;
    always @ (posedge clk)
        if (rst)
            a <= 4'b0000;
        else
            a <= a + 1'b1;
endmodule
