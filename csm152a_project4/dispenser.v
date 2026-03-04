`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2026 10:35:26 AM
// Design Name: 
// Module Name: dispenser
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
// Drives the 4-digit display with the validated snack name.
// Also runs a simple "dispensing" animation: the name scrolls off
// left over ~1 second, then blanks (indicating the snack has dropped).

// DISP_HOLD_CYCLES: how long to show name before scrolling (50M = 1 s)
// SCROLL_STEP_CYCLES: time between scroll steps (12.5M = 250 ms)

module dispenser #(
    parameter CLK_FREQ         = 50_000_000,
    parameter DISP_HOLD_CYCLES = 50_000_000,
    parameter SCROLL_STEP      = 12_500_000
)(
    input        clk,
    input        rst,
    input  [5:0] ch0_in, ch1_in, ch2_in, ch3_in,
    input        is_valid,      // single-cycle trigger to start dispensing

    output [6:0] seg0, seg1, seg2, seg3,  // to cycle_4dig
    output reg   done           // pulses when animation complete
);
    localparam SPC = 26;

    // We keep 8 letter slots so we can scroll: [blank×4 | ch0..ch3 | blank×4]
    // but a simpler 4-step right-shift is enough for the vending effect.

    reg [5:0] disp [0:3];   // display registers
    reg [5:0] ch0_r, ch1_r, ch2_r, ch3_r;

    wire [6:0] sego [0:3];
    letter_encoder le0 (.ch(disp[0]), .seg(sego[0]));
    letter_encoder le1 (.ch(disp[1]), .seg(sego[1]));
    letter_encoder le2 (.ch(disp[2]), .seg(sego[2]));
    letter_encoder le3 (.ch(disp[3]), .seg(sego[3]));

    assign seg0 = sego[0];
    assign seg1 = sego[1];
    assign seg2 = sego[2];
    assign seg3 = sego[3];

    // ?? FSM ??????????????????????????????????????????????????????????
    localparam S_IDLE   = 2'd0,
               S_HOLD   = 2'd1,
               S_SCROLL = 2'd2,
               S_DONE   = 2'd3;

    reg [1:0] state;
    reg [25:0] timer;
    reg [1:0]  scroll_step;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state       <= S_IDLE;
            timer       <= 0;
            scroll_step <= 0;
            done        <= 0;
            disp[0] <= SPC; disp[1] <= SPC;
            disp[2] <= SPC; disp[3] <= SPC;
        end else begin
            done <= 0;

            case (state)
                S_IDLE: begin
                    if (is_valid) begin
                        // latch snack name
                        ch0_r <= ch0_in; ch1_r <= ch1_in;
                        ch2_r <= ch2_in; ch3_r <= ch3_in;
                        disp[0] <= ch0_in; disp[1] <= ch1_in;
                        disp[2] <= ch2_in; disp[3] <= ch3_in;
                        timer   <= 0;
                        state   <= S_HOLD;
                    end
                end

                S_HOLD: begin
                    if (timer == DISP_HOLD_CYCLES - 1) begin
                        timer       <= 0;
                        scroll_step <= 0;
                        state       <= S_SCROLL;
                    end else
                        timer <= timer + 1;
                end

                S_SCROLL: begin
                    // Each step shifts display one position left, filling right with blank
                    if (timer == SCROLL_STEP - 1) begin
                        timer <= 0;
                        // Shift left
                        disp[0] <= disp[1];
                        disp[1] <= disp[2];
                        disp[2] <= disp[3];
                        disp[3] <= SPC;
                        if (scroll_step == 2'd3) begin
                            state <= S_DONE;
                        end else
                            scroll_step <= scroll_step + 1;
                    end else
                        timer <= timer + 1;
                end

                S_DONE: begin
                    disp[0] <= SPC; disp[1] <= SPC;
                    disp[2] <= SPC; disp[3] <= SPC;
                    done  <= 1;
                    state <= S_IDLE;
                end
            endcase
        end
    end
endmodule

