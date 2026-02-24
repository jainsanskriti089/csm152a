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
module final_display(
	fast_clk, blink_clk, sel, adj, dig1, dig2, dig3, dig4,
	seg7, dig
    ); 
	input fast_clk;
   	input blink_clk;
	input sel;
	input adj;
	input [6:0] dig1;
	input [6:0] dig2;
	input [6:0] dig3;
	input [6:0] dig4;
	 
	output [6:0] seg7;
	output [3:0] dig;


	reg [1:0] switch_dig = 2'b00;
	reg [6:0] seg7_temp;
	reg [3:0] dig_temp;
	
	always @ (posedge fast_clk) begin
		if (switch_dig == 0) begin
			switch_dig <= switch_dig + 2'b1;
			dig_temp <= 4'b0111;
			// Adjust 10s of minutes
			if (adj && !sel) begin
				if (blink_clk) begin
					seg7_temp <= dig1;
				end
				else begin
					seg7_temp <= 7'b1111111;
				end
			end
			// If not Adjust Mode, or adjusting only seconds, minutes don't change
			else begin
				seg7_temp <= dig1;
			end
		end
		else if (switch_dig == 1) begin
			switch_dig <= switch_dig + 2'b1;
			dig_temp <= 4'b1011;
			// Adjust minutes (1's spot)
			if (adj && !sel) begin
				if (blink_clk) begin
					seg7_temp <= dig2;
				end
				else begin
					seg7_temp <= 7'b1111111;
				end
			end
			// If not Adjust Clock Mode, or adjusting seconds, minutes don't change
			else begin
				seg7_temp <= dig2;
			end
		end 
		else if (switch_dig == 2) begin
			switch_dig <= switch_dig + 2'b1;
			dig_temp <= 4'b1101;
			// Adjust seconds (10's spot)
			if (adj && sel) begin
				if (blink_clk) begin
					seg7_temp <= dig3;
				end
				else begin
					seg7_temp <= 7'b1111111;
				end
			end
			// If not Adjust Clock Mode, or adjusting minutes, seconds don't change
			else begin
				seg7_temp <= dig3;
			end
		end 
		else if (switch_dig == 3) begin
			switch_dig <= 2'b0;
			dig_temp <= 4'b1110;
			// Adjust seconds (1's spot)
			if (adj && sel) begin
				if (blink_clk) begin
					seg7_temp <= dig4;
				end
				else begin
					seg7_temp <= 7'b1111111;
				end
			end
			// If not Adjust Clock Mode, or adjusting minutes, seconds don't change
			else begin
				seg7_temp <= dig4;
			end
		end
	end

	assign seg7 = seg7_temp;
	assign dig = dig_temp;
	
endmodule