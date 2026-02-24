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
module top(
	sel, adj, rst, pause, clk,
	anodes, segments
    );
	input sel;
	input adj;
	input rst;
	input pause;
	input clk;
	output [3:0] anodes;
	output [6:0] segments;

	wire rst_db;
	wire pause_db;
	wire sel_db;
	wire adj_db;
	
	wire onehz_clk;
	wire twohz_clk;
	wire fast_clk;
	wire blink_clk;
	
	debouncer pause_db_func(.clk(clk), .button(pause), .bounce_state(pause_db));
	debouncer rst_db_func(.clk(clk), .button(rst), .bounce_state(rst_db));
	debouncer sel_db_func(.clk(clk), .button(sel), .bounce_state(sel_db));
	debouncer adj_db_func(.clk(clk), .button(adj), .bounce_state(adj_db));
	
	clk_div clock_divider(.sys_clk(clk), .rst(rst_db), .onehz_clk(onehz_clk), .twohz_clk(twohz_clk), .fast_clk(fast_clk), .blink_clk(blink_clk));

	wire [5:0] minutes;
	wire [5:0] seconds;
	
	wire [3:0] min_10s;
	wire [3:0] min_1s;
	wire [3:0] sec_10s;
	wire [3:0] sec_1s;
	
	wire [6:0] dig0;
	wire [6:0] dig1;
	wire [6:0] dig2;
	wire [6:0] dig3;

	counter min_sec_counter(.onehz_clk(onehz_clk), .twohz_clk(twohz_clk), .pause(pause_db), .rst(rst_db), .sel(sel_db), .adj(adj_db), .minutes(minutes), .seconds(seconds));
	
	separate_digits digits(.min(minutes), .sec(seconds), .min_10s(min_10s), .min_1s(min_1s), .sec_10s(sec_10s), .sec_1s(sec_1s));

	display seven_seg_min10s(.decimal(min_10s), .segmented(dig0));
	display seven_seg_min1s(.decimal(min_1s), .segmented(dig1));
	display seven_seg_sec10s(.decimal(sec_10s), .segmented(dig2));
	display seven_seg_sec1s(.decimal(sec_1s), .segmented(dig3));

	final_display digsegments(.fast_clk(fast_clk), .blink_clk(blink_clk), .sel(sel_db), .adj(adj_db), .dig1(dig0), .dig2(dig1), .dig3(dig2), .dig4(dig3), .seg7(segments), .dig(anodes));

endmodule