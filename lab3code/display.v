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
module display(
	decimal,
	segmented
   );
	 
	input [3:0] decimal;
	output [6:0] segmented;

	reg [6:0] segs7;

	always @ (*) begin
	   // Order: GFEDCBA
		case(decimal)
			 0: segs7 = 7'b1000000; 
             1: segs7 = 7'b1111001;
             2: segs7 = 7'b0100100; 
             3: segs7 = 7'b0110000; 
             4: segs7 = 7'b0011001; 
             5: segs7 = 7'b0010010; 
             6: segs7 = 7'b0000010; 
             7: segs7 = 7'b1111000; 
             8: segs7 = 7'b0000000; 
             9: segs7 = 7'b0010000; 
            default: segs7 = 7'b1111111;
		endcase
	end
	
	assign segmented = segs7;

endmodule