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
    input        rst,           // global reset (from debouncer)
    input  [3:0] db_key,        // debounced key value
    input        db_valid,      // single-cycle key valid pulse
    input        db_confirm,    // debounced confirm button

    output reg [7:0] snack_code,   // {digit_l, digit_r}
    output reg       snack_valid,  // single-cycle pulse when confirmed

    // To cycle_2dig
    output reg [3:0] digit_l,
    output reg [3:0] digit_r
);

    localparam IDLE      = 3'd0,
               GOT_ONE   = 3'd1,
               GOT_TWO   = 3'd2,
               CONFIRMED = 3'd3,
               WAIT_RST  = 3'd4;

    reg [2:0] state;
    reg [3:0] buf_l, buf_r;

    localparam BLANK = 4'hF; // choose a value cycle_2dig can show as ' '
                              // or remap in seg7_encoder to blank segments

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state       <= IDLE;
            buf_l       <= BLANK;
            buf_r       <= BLANK;
            snack_code  <= 8'h00;
            snack_valid <= 1'b0;
            digit_l     <= BLANK;
            digit_r     <= BLANK;
        end else begin
            snack_valid <= 1'b0;   // default: no pulse

            case (state)

                IDLE: begin
                    buf_l <= BLANK;
                    buf_r <= BLANK;
                    if (db_valid) begin
                        buf_r  <= db_key;
                        state  <= GOT_ONE;
                    end
                end

                GOT_ONE: begin
                    digit_l <= BLANK;
                    digit_r <= buf_r;
                    if (db_valid) begin
                        buf_l  <= buf_r;     // shift right ? left
                        buf_r  <= db_key;
                        state  <= GOT_TWO;
                    end
                end

                GOT_TWO: begin
                    digit_l <= buf_l;
                    digit_r <= buf_r;
                    if (db_valid) begin
                        // Third press: shift again (only keep last two)
                        //we dont need this functionality as all codes are only 2 digits
                        buf_l <= buf_r;
                        buf_r <= db_key;
                    end else if (db_confirm) begin
                        snack_code  <= {buf_l, buf_r};
                        snack_valid <= 1'b1;
                        state       <= CONFIRMED;
                    end
                end

                CONFIRMED: begin
                    // snack_valid already pulsed last cycle; stay visible
                    state <= WAIT_RST;
                end

                WAIT_RST: begin
                    // Hold display; top-level FSM will assert rst when done
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule
