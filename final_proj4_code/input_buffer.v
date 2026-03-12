`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2026 10:25:24 AM
// Design Name: 
// Module Name: input_buffer
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

// Accepts up to 2 hex keypad presses, displays them live on the 2-digit
// display, then outputs snack_code on confirm. A local rst clears input.
//
// states:
//   IDLE      ? waiting for first keypress
//   GOT_ONE   ? first digit received, show it on left display (right blank)
//   GOT_TWO   ? both digits received, show both; wait for confirm or rst
//   CONFIRMED ? pulse snack_valid for one cycle, go to WAIT_RST
//   WAIT_RST  ? hold until external reset returns us to IDLE

module input_buffer (
    input        clk,
    input        rst,
    input  [3:0] db_key,
    input        db_valid,
    input        db_confirm,
    input        is_invalid,    // ? new: triggers blink on bad code
    input        done,

    output reg [7:0] snack_code,
    output reg       snack_valid,
    output reg [3:0] digit_l,
    output reg [3:0] digit_r
);
    localparam IDLE      = 3'd0,
               GOT_ONE   = 3'd1,
               GOT_TWO   = 3'd2,
               CONFIRMED = 3'd3,
               WAIT_RST  = 3'd4,
               BLINK     = 3'd5;

    localparam DASH = 4'hF;

    // Blink timing: 50MHz, 250ms per half-blink
    // 2 full blinks = 4 half-blinks of 12_500_000 cycles each
    localparam BLINK_HALF = 26'd12_500_000;

    reg [2:0] state;
    reg [3:0] buf_l, buf_r;
    reg [25:0] blink_cnt;
    reg [2:0]  blink_phase;  // counts 0-3 (4 half-blinks = 2 full blinks)
    reg        blink_on;     // 1=show dash, 0=show blank

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state       <= IDLE;
            buf_l       <= DASH;
            buf_r       <= DASH;
            snack_code  <= 8'h00;
            snack_valid <= 1'b0;
            digit_l     <= DASH;
            digit_r     <= DASH;
            blink_cnt   <= 0;
            blink_phase <= 0;
            blink_on    <= 1;
        end else begin
            snack_valid <= 1'b0;

            case (state)

                IDLE: begin
                    digit_l <= DASH;
                    digit_r <= DASH;
                    buf_l   <= DASH;
                    buf_r   <= DASH;
                    if (db_valid) begin
                        buf_r <= db_key;
                        state <= GOT_ONE;
                    end
                end

                GOT_ONE: begin
                    digit_l <= DASH;
                    digit_r <= buf_r;
                    if (db_valid) begin
                        buf_l <= buf_r;
                        buf_r <= db_key;
                        state <= GOT_TWO;
                    end
                end

                GOT_TWO: begin
                    digit_l <= buf_l;
                    digit_r <= buf_r;
                    if (db_valid) begin
                        buf_l <= buf_r;
                        buf_r <= db_key;
                    end else if (db_confirm) begin
                        snack_code  <= {buf_l, buf_r};
                        snack_valid <= 1'b1;
                        state       <= CONFIRMED;
                    end
                end

                CONFIRMED: begin
                    state <= WAIT_RST;
                end

                WAIT_RST: begin
                    // Wait for keypad.v to respond with is_invalid
                    // (is_valid just lets dispenser handle it, we reset)
                    if (is_invalid) begin
                        blink_cnt   <= 0;
                        blink_phase <= 0;
                        blink_on    <= 1;
                        digit_l     <= DASH;
                        digit_r     <= DASH;
                        state       <= BLINK;
                    end else begin
                        // valid code - stay until global rst
                        state <= IDLE;
                        digit_l <= DASH;
                        digit_r <= DASH;
                    end
                end

                BLINK: begin
                    // Alternate between showing -- and blank every BLINK_HALF
                    digit_l <= blink_on ? DASH : 4'hE;  
                    digit_r <= blink_on ? DASH : 4'hE;  

                    if (blink_cnt == BLINK_HALF - 1) begin
                        blink_cnt   <= 0;
                        blink_on    <= ~blink_on;
                        blink_phase <= blink_phase + 1;
                        if (blink_phase == 3'd3) begin
                            // Done blinking - reset to IDLE
                            state   <= IDLE;
                            digit_l <= DASH;
                            digit_r <= DASH;
                        end
                    end else
                        blink_cnt <= blink_cnt + 1;
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule