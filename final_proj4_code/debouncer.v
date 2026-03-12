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
module debouncer #(
    parameter HOLD_BITS = 20
)(
    input  clk,
    input  rst,
    input  raw,        // raw bouncy input, active-high
    output reg db      // debounced output
);
    reg [HOLD_BITS-1:0] cnt;
    reg raw_prev;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt <= 0; db <= 0; raw_prev <= 0;
        end else begin
            raw_prev <= raw;
            if (raw != raw_prev)
                cnt <= 0;                          // input changed ? restart
            else if (&cnt)                         // counter saturated
                db <= raw;                         // latch stable value
            else
                cnt <= cnt + 1;
        end
    end
endmodule

// Wraps one debouncer each for reset & confirm buttons,
// and re-registers the scanner's already-debounced key/valid signals.

module debouncer_top (
    input        clk,
    input        rst_raw,        // raw reset button
    input        confirm_raw,    // raw confirm button
    input  [3:0] key_in,         // from hex_keypad_scanner
    input        valid_in,

    output       db_reset,
    output       db_confirm,
    output [3:0] db_key,
    output       db_valid
);
    // Never reset the reset debouncer itself
    debouncer #(.HOLD_BITS(20)) u_rst (
        .clk(clk), .rst(1'b0), .raw(rst_raw), .db(db_reset)
    );

    debouncer #(.HOLD_BITS(20)) u_confirm (
        .clk(clk), .rst(rst_raw), .raw(confirm_raw), .db(db_confirm)
    );

    // Re-register scanner outputs for clean timing
    reg [3:0] db_key_r;
    reg       db_valid_r;
    always @(posedge clk or posedge rst_raw) begin
        if (rst_raw) begin
            db_key_r <= 0; db_valid_r <= 0;
        end else begin
            db_key_r   <= key_in;
            db_valid_r <= valid_in;
        end
    end

    assign db_key   = db_key_r;
    assign db_valid = db_valid_r;
endmodule