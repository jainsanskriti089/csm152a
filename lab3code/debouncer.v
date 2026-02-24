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

module debouncer(
  clk, button, 
  bounce_state
  );

  input clk;
  input button;
  
  output bounce_state;
  
  reg debounce_temp;
  reg [15:0] counter;

  reg sync_to_clk0;
  reg sync_to_clk1;

  always @ (posedge clk) begin
    sync_to_clk0 <= button;
  end
  always @ (posedge clk) begin
    sync_to_clk1 <= sync_to_clk0;
  end


  always @ (posedge clk) begin
  	if (debounce_temp == sync_to_clk1) begin
		counter <= 0;
	end
	else begin
		counter <= counter + 1'b1;
		if (counter == 16'hffff) begin
	     		debounce_temp <= ~bounce_state;
		end
        end
  end
  assign bounce_state = debounce_temp;
endmodule 