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
module sel_adj(
	adj, onehz_clk, twohz_clk,
	choose_clk
    );

	input adj;
	input onehz_clk;
	input twohz_clk;
	output choose_clk;

	reg chosen_clk_temp;
	
	always @ (*) begin
		// Adjust Mode (CYCLE QUICKER)
		if (adj) begin
			chosen_clk_temp = twohz_clk;
		end
		// Normal Mode
		else begin
			chosen_clk_temp = onehz_clk;
		end
	end

	assign choose_clk = chosen_clk_temp;

endmodule