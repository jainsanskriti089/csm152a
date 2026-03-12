`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2026 11:16:18 AM
// Design Name: 
// Module Name: hex_keypad_scanner
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
module hex_keypad_scanner (
    input        clk,
    input        rst,
    input  [3:0] col,
    output reg [3:0] row,
    output reg [3:0] key,
    output reg       valid
);
    reg [1:0]  scan_row;
    reg [19:0] debounce_cnt;
    reg [3:0]  col_stable;
    reg        scanning;
    reg [9:0]  settle_cnt;

    // ?? Row drive: reversed order ?????????????????????????????????????
    always @(*) begin
        case (scan_row)
            2'd0: row = 4'b0111;   // was 4'b1110
            2'd1: row = 4'b1011;   // was 4'b1101
            2'd2: row = 4'b1101;   // was 4'b1011
            2'd3: row = 4'b1110;   // was 4'b0111
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            scan_row     <= 0;
            debounce_cnt <= 0;
            settle_cnt   <= 0;
            valid        <= 0;
            scanning     <= 1;
        end else begin
            valid <= 0;

            if (scanning) begin
                if (col != 4'b1111) begin
                    settle_cnt <= 0;
                    if (debounce_cnt < 20'hFFFFF)
                        debounce_cnt <= debounce_cnt + 1;
                    else begin
                        debounce_cnt <= 0;
                        col_stable   <= col;

                        // ?? col bits also reversed ????????????????????
                        case ({scan_row, col})
                            // Row 0: 1, 2, 3, A
                            {2'd0,4'b0111}: key <= 4'hD;   // col reversed
                            {2'd0,4'b1011}: key <= 4'hE;
                            {2'd0,4'b1101}: key <= 4'hF;
                            {2'd0,4'b1110}: key <= 4'h0;
                            // Row 1: 4, 5, 6, B
                            {2'd1,4'b0111}: key <= 4'hC;
                            {2'd1,4'b1011}: key <= 4'h9;
                            {2'd1,4'b1101}: key <= 4'h8;
                            {2'd1,4'b1110}: key <= 4'h7;
                            // Row 2: 7, 8, 9, C
                            {2'd2,4'b0111}: key <= 4'hB;
                            {2'd2,4'b1011}: key <= 4'h6;
                            {2'd2,4'b1101}: key <= 4'h5;
                            {2'd2,4'b1110}: key <= 4'h4;
                            // Row 3: *, 0, #, D
                            {2'd3,4'b0111}: key <= 4'hA;
                            {2'd3,4'b1011}: key <= 4'h3;
                            {2'd3,4'b1101}: key <= 4'h2;
                            {2'd3,4'b1110}: key <= 4'h1;
                            default:        key <= 4'h0;
                        endcase
                        valid    <= 1;
                        scanning <= 0;
                    end
                end else begin
                    debounce_cnt <= 0;
                    if (settle_cnt < 10'd1000)
                        settle_cnt <= settle_cnt + 1;
                    else begin
                        settle_cnt <= 0;
                        scan_row   <= scan_row + 1;
                    end
                end
            end else begin
                if (col == 4'b1111)
                    scanning <= 1;
            end
        end
    end
endmodule