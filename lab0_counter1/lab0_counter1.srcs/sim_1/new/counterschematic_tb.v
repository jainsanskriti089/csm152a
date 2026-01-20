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


module counterschematic_tb;
    reg clk;
    reg rst;
//    reg a0;
//    reg a1;
//    reg a2;
//    reg a3;
    
    always #5 clk = ~clk;
    
    counter_schematic dut (
        .clk(clk),
        .rst(rst)
    );
    
    initial begin
        clk = 0;
        rst = 1;
        
        #20;
        rst = 0;
        
        #100;
        $finish;
    end
endmodule
