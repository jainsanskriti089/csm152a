`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/26/2026 10:45:02 AM
// Design Name: 
// Module Name: top
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
// Port map:
//   clk          50 MHz board clock
//   rst_raw      Reset pushbutton (active-high, bouncy)
//   confirm_raw  Confirm pushbutton (active-high, bouncy)
//   col[3:0]     Keypad column inputs
//   row[3:0]     Keypad row drive outputs
//   seg2[6:0]    2-digit display segment bus  (input_buffer live view)
//   anode2[1:0]  2-digit display anode selects (active-low)
//   seg4[6:0]    4-digit display segment bus  (snack name / dispenser)
//   anode4[3:0]  4-digit display anode selects (active-low)
//   speaker      1-bit buzzer output

module top (
    input        clk,
    input        rst_raw, //top button
    input        confirm_raw, //middle button
    input  [3:0] col,
    output [3:0] row,
    output [6:0] seg2,
    output [1:0] anode2,
    output [6:0] seg4,
    output [3:0] anode4,
    output       ain,
    output       gain,
    output       shutdown_n
);
    assign gain = 1'b0;
    assign shutdown_n = 1'b1;
    
    wire       db_reset, db_confirm;
    wire [3:0] db_key;
    wire       db_valid;

    wire [3:0] key_raw;
    wire       valid_raw;

    hex_keypad_scanner scanner (
        .clk(clk), .rst(db_reset),
        .col(col), .row(row),
        .key(key_raw), .valid(valid_raw)
    );

    debouncer_top deb (
        .clk(clk), .rst_raw(rst_raw), .confirm_raw(confirm_raw),
        .key_in(key_raw), .valid_in(valid_raw),
        .db_reset(db_reset), .db_confirm(db_confirm),
        .db_key(db_key), .db_valid(db_valid)
    );

    wire [7:0] snack_code;
    wire       snack_valid;
    wire [3:0] ibuf_digit_l, ibuf_digit_r;

    input_buffer ibuf (
        .clk(clk), .rst(db_reset),
        .db_key(db_key), .db_valid(db_valid),
        .db_confirm(db_confirm),
        .snack_code(snack_code), .snack_valid(snack_valid),
        .digit_l(ibuf_digit_l), .digit_r(ibuf_digit_r)
    );

    cycle_2dig c2d (
        .clk(clk), .rst(db_reset),
        .digit_l(ibuf_digit_l), .digit_r(ibuf_digit_r),
        .seg(seg2), .anode(anode2)
    );

    wire [5:0] ch0, ch1, ch2, ch3;
    wire       is_valid, is_invalid;

    keypad kp (
        .clk(clk), .rst(db_reset),
        .snack_code(snack_code), .snack_valid(snack_valid),
        .ch0(ch0), .ch1(ch1), .ch2(ch2), .ch3(ch3),
        .is_valid(is_valid), .is_invalid(is_invalid)
    );

    wire [6:0] dseg0, dseg1, dseg2, dseg3;
    wire       disp_done;

    dispenser disp (
        .clk(clk), .rst(db_reset),
        .ch0_in(ch0), .ch1_in(ch1), .ch2_in(ch2), .ch3_in(ch3),
        .is_valid(is_valid),
        .seg0(dseg0), .seg1(dseg1), .seg2(dseg2), .seg3(dseg3),
        .done(disp_done)
    );

    cycle_4dig c4d (
        .clk(clk), .rst(db_reset),
        .seg0(dseg0), .seg1(dseg1), .seg2(dseg2), .seg3(dseg3),
        .seg(seg4), .anode(anode4)
    );

    sfx sound (
        .clk(clk), .rst(db_reset),
        .is_valid(is_valid), .is_invalid(is_invalid),
        .ain(ain), .gain(gain), .shutdown_n(shutdown_n)
    );

endmodule
