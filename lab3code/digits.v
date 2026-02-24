`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name:
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module separate_digits(
	min, sec,
	min_10s, min_1s, sec_10s, sec_1s
    );

	input [5:0] min;
	input [5:0] sec;
	
	output [3:0] min_10s;
	output [3:0] min_1s;
	output [3:0] sec_10s;
	output [3:0] sec_1s;

	assign min_10s = min/10;
	assign sec_10s = sec/10;
	assign min_1s = min - (10 * min_10s);
	assign sec_1s = sec - (10 * sec_10s);

endmodule