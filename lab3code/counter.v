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
module counter(
	onehz_clk, twohz_clk, pause, rst, sel, adj,
	minutes, seconds
    );

	input onehz_clk;
	input twohz_clk;
	input pause;
	input rst;
	input sel;
	input adj;
	output [5:0] minutes;
	output [5:0] seconds;

	reg [5:0] min_temp = 5'b00000;
	reg [5:0] sec_temp = 5'b00000;
	reg is_pause = 0;
	
   sel_adj adjust(
    .adj(adj), .onehz_clk(onehz_clk), .twohz_clk(twohz_clk), .choose_clk(clk)
   );
	
	always @ (posedge pause) begin
	   if (!adj) begin
        is_pause <= ~is_pause;
       end
    end
	always @ (posedge clk or posedge rst) begin
		// Reset 
		if (rst) begin
			min_temp <= 5'b0;
			sec_temp <= 5'b0;
		end
		// Not reset (Clock mode)
		else begin
		if (~is_pause) begin
			min_temp <= minutes;
			sec_temp <= seconds;
			// Adjust Clock Mode
			if (adj) begin
				// Adjust seconds, freeze minutes
				if (sel) begin
					// If max seconds, then reset seconds
					if (sec_temp == 59) begin
						sec_temp <= 5'b0;
					end
					else begin
						sec_temp <= sec_temp + 5'b1;
					end
				end
				// Adjust minutes, freeze seconds
				else begin
					// If max minutes, then reset minutes
					if (min_temp == 59) begin
						min_temp <= 5'b0;
					end
					else begin
						min_temp <= min_temp + 5'b1;
					end
				end
			end
			// Normal Clock Mode
			else begin
                // If max stopwatch time, then reset both minutes and seconds
                if (min_temp == 59 && sec_temp == 59) begin
                    min_temp <= 5'b0;
                    sec_temp <= 5'b0;
                end
                // If max seconds, then reset seconds, increment minutes
                else if (min_temp != 59 && sec_temp == 59) begin
                    min_temp <= min_temp + 5'b1;
                    sec_temp <= 5'b0;
                end
                else begin
                    sec_temp <= sec_temp + 5'b1;
                end
			end
		end
		end
	end

	assign minutes = min_temp;
	assign seconds = sec_temp;

endmodule