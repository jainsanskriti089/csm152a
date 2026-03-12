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
    parameter DISP_HOLD_CYCLES = 50_000_000,   // 1s hold before scroll
    parameter RAND_HOLD_CYCLES = 50_000_000,   // 1s show RAND before reveal
    parameter SCROLL_STEP      = 12_500_000    // 250ms per scroll step
)(
    input        clk,
    input        rst,
    input  [5:0] ch0_in, ch1_in, ch2_in, ch3_in,
    input        is_valid,
    input        is_rand,       // ? new

    output [6:0] seg0, seg1, seg2, seg3,
    output reg   done
);
    localparam SPC = 6'd26;

    // ?? 8-entry snack ROM (excludes RAND itself) ??????????????????????
    // Index 0-7 maps to CHIP, BAR, CHOC, NUTS, CAKE, OREO, CAFE, ACAI
    reg [5:0] snack_rom [0:7][0:3];
    integer i;
    initial begin
        // CHIP: C=2  H=7  I=8  P=15
        snack_rom[0][0]=6'd2;  snack_rom[0][1]=6'd7;
        snack_rom[0][2]=6'd8;  snack_rom[0][3]=6'd15;
        // BAR : B=1  A=0  R=17 SPC=26
        snack_rom[1][0]=6'd1;  snack_rom[1][1]=6'd0;
        snack_rom[1][2]=6'd17; snack_rom[1][3]=6'd26;
        // CHOC: C=2  H=7  O=14 C=2
        snack_rom[2][0]=6'd2;  snack_rom[2][1]=6'd7;
        snack_rom[2][2]=6'd14; snack_rom[2][3]=6'd2;
        // NUTS: N=13 U=20 T=19 S=18
        snack_rom[3][0]=6'd13; snack_rom[3][1]=6'd20;
        snack_rom[3][2]=6'd19; snack_rom[3][3]=6'd18;
        // CAKE: C=2  A=0  K=10 E=4
        snack_rom[4][0]=6'd2;  snack_rom[4][1]=6'd0;
        snack_rom[4][2]=6'd10; snack_rom[4][3]=6'd4;
        // OREO: O=14 R=17 E=4  O=14
        snack_rom[5][0]=6'd14; snack_rom[5][1]=6'd17;
        snack_rom[5][2]=6'd4;  snack_rom[5][3]=6'd14;
        // CAFE: C=2  A=0  F=5  E=4
        snack_rom[6][0]=6'd2;  snack_rom[6][1]=6'd0;
        snack_rom[6][2]=6'd5;  snack_rom[6][3]=6'd4;
        // ACAI: A=0  C=2  A=0  I=8
        snack_rom[7][0]=6'd0;  snack_rom[7][1]=6'd2;
        snack_rom[7][2]=6'd0;  snack_rom[7][3]=6'd8;
    end

    // ?? 8-bit LFSR (free-running) ?????????????????????????????????????
    // Maximal-length polynomial: x^8 + x^6 + x^5 + x^4 + 1
    // Period = 255, more than enough for 8 snacks
    reg [7:0] lfsr;
    always @(posedge clk or posedge rst) begin
        if (rst)
            lfsr <= 8'hAC;   // non-zero seed
        else
            lfsr <= {lfsr[6:0], lfsr[7] ^ lfsr[5] ^ lfsr[4] ^ lfsr[3]};
    end

    // ?? Display registers ?????????????????????????????????????????????
    reg [5:0] disp [0:3];

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
    localparam S_IDLE      = 3'd0,
               S_HOLD      = 3'd1,
               S_RAND_HOLD = 3'd2,   // show RAND, then reveal random snack
               S_SCROLL    = 3'd3,
               S_DONE      = 3'd4;

    reg [2:0]  state;
    reg [25:0] timer;
    reg [1:0]  scroll_step;
    reg [2:0]  rand_idx;     // selected snack index 0-7

    // delayed is_valid so ch0-ch3 have settled
    reg is_valid_r;
    reg is_rand_r;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            is_valid_r <= 0;
            is_rand_r  <= 0;
        end else begin
            is_valid_r <= is_valid;
            is_rand_r  <= is_rand;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state       <= S_IDLE;
            timer       <= 0;
            scroll_step <= 0;
            done        <= 0;
            rand_idx    <= 0;
            disp[0] <= SPC; disp[1] <= SPC;
            disp[2] <= SPC; disp[3] <= SPC;
        end else begin
            done <= 0;

            case (state)

                S_IDLE: begin
                    if (is_valid_r) begin
                        if (is_rand_r) begin
                            // Show RAND text (already in ch0-ch3 from keypad)
                            disp[0] <= ch0_in;
                            disp[1] <= ch1_in;
                            disp[2] <= ch2_in;
                            disp[3] <= ch3_in;
                            // Snapshot LFSR now to pick snack
                            rand_idx <= lfsr[2:0] > 3'd7 ?
                                        lfsr[2:0] - 3'd8 :
                                        lfsr[2:0];
                            timer <= 0;
                            state <= S_RAND_HOLD;
                        end else begin
                            disp[0] <= ch0_in;
                            disp[1] <= ch1_in;
                            disp[2] <= ch2_in;
                            disp[3] <= ch3_in;
                            timer <= 0;
                            state <= S_HOLD;
                        end
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

                S_RAND_HOLD: begin
                    // Show RAND for RAND_HOLD_CYCLES, then swap to random snack
                    if (timer == RAND_HOLD_CYCLES - 1) begin
                        // Load random snack from ROM
                        disp[0] <= snack_rom[rand_idx][0];
                        disp[1] <= snack_rom[rand_idx][1];
                        disp[2] <= snack_rom[rand_idx][2];
                        disp[3] <= snack_rom[rand_idx][3];
                        timer       <= 0;
                        scroll_step <= 0;
                        state       <= S_HOLD;   // hold snack name, then scroll
                    end else
                        timer <= timer + 1;
                end

                S_SCROLL: begin
                    if (timer == SCROLL_STEP - 1) begin
                        timer   <= 0;
                        disp[0] <= disp[1];
                        disp[1] <= disp[2];
                        disp[2] <= disp[3];
                        disp[3] <= SPC;
                        if (scroll_step == 2'd3)
                            state <= S_DONE;
                        else
                            scroll_step <= scroll_step + 1;
                    end else
                        timer <= timer + 1;
                end

                S_DONE: begin
                    disp[0] <= SPC; disp[1] <= SPC;
                    disp[2] <= SPC; disp[3] <= SPC;
                    done    <= 1;
                    state   <= S_IDLE;
                end

            endcase
        end
    end
endmodule