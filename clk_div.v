`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name:    display_top
// Description:    Top-level module for 4-digit 7-segment display system
//                 Integrates: clock dividers + BCD decoder + display multiplexer
//                
// Usage Example:
//   To display "1234":
//     digit3 = 4'd1, digit2 = 4'd2, digit1 = 4'd3, digit0 = 4'd4
//
// Hardware Connections:
//   - Connect clk to 50 MHz clock source
//   - Connect segments[6:0] to 7-segment display pins {g,f,e,d,c,b,a}
//   - Connect anodes[3:0] to digit select pins (through transistors)
//   - anodes are active LOW (0 = digit ON)
//   - segments are active LOW (0 = LED ON)
//////////////////////////////////////////////////////////////////////////////////

module display_top(
    input wire clk,              // 50 MHz input clock
    input wire rst,              // Active high reset
    //wont synthesize because not mapped to xdc, just hardcode to start at 0
    input wire [3:0] digit0,     // Rightmost digit (ones place) - BCD 0-9
    input wire [3:0] digit1,     // Tens place - BCD 0-9
    input wire [3:0] digit2,     // Hundreds place - BCD 0-9
    input wire [3:0] digit3,     // Leftmost digit (thousands place) - BCD 0-9
    output wire [6:0] segments,  // 7-segment outputs {g,f,e,d,c,b,a} (active LOW)
    output wire [3:0] anodes             // Digit select {d3,d2,d1,d0} (active LOW)
);
   
   
    //==========================================================================
    // Internal Signals
    //==========================================================================
   
    // Clock signals from clock divider
    wire two_hz_clk;       // 2 Hz clock (not used in this design, but available)
    wire one_hz_clk;       // 1 Hz clock (not used in this design, but available)
    wire segment_hz_clk;   // 1 kHz clock for display multiplexing
    wire blink_hz_clk;     // 4 Hz clock (not used in this design, but available)

    //==========================================================================
    // Clock Divider Instance
    // Generates multiple clock frequencies from 50 MHz input
    //==========================================================================
   
    clock_dividers clk_div (
        .clk(clk),
        .rst(rst),
        .two_hz_clk(two_hz_clk),
        .one_hz_clk(one_hz_clk),
        .segment_hz_clk(segment_hz_clk),    // Used for multiplexing
        .blink_hz_clk(blink_hz_clk)
    );

    //==========================================================================
    // Display Multiplexer Instance
    // Cycles through 4 digits using segment_hz_clk
    // Internally uses bcd_to_7seg decoder
    //==========================================================================
   
    simple_display_mux display (
        .rst(rst),
        .segment_clk(segment_hz_clk),
        .digit0(digit0),
        .digit1(digit1),
        .digit2(digit2),
        .digit3(digit3),
        .segments(segments),
        .anodes(anodes)
    );

endmodule

module bcd_to_7seg(
    input wire [3:0] bcd,        // 4-bit BCD input (0-9)
    output reg [6:0] segments    // 7-segment output {g,f,e,d,c,b,a}
);

    always @(*) begin
        case(bcd)
            4'd0: segments = 7'b1000000; // 0
            4'd1: segments = 7'b1111001; // 1
            4'd2: segments = 7'b0100100; // 2
            4'd3: segments = 7'b0110000; // 3
            4'd4: segments = 7'b0011001; // 4
            4'd5: segments = 7'b0010010; // 5
            4'd6: segments = 7'b0000010; // 6
            4'd7: segments = 7'b1111000; // 7
            4'd8: segments = 7'b0000000; // 8
            4'd9: segments = 7'b0010000; // 9
            default: segments = 7'b1111111; // Blank (all OFF)
        endcase
    end

endmodule

module simple_display_mux(
    input wire rst,              // Reset
    input wire segment_clk,      // Multiplexing clock from clock divider
    input wire [3:0] digit0,     // Rightmost digit (ones)
    input wire [3:0] digit1,     // Tens
    input wire [3:0] digit2,     // Hundreds
    input wire [3:0] digit3,     // Leftmost digit (thousands)
    output wire [6:0] segments,  // 7-segment outputs {g,f,e,d,c,b,a}
    output reg [3:0] anodes      // Digit select (active LOW)
);

    // Counter to cycle through digits (0, 1, 2, 3)
    reg [1:0] digit_select;
   
    // Current digit being displayed
    reg [3:0] current_digit;
   
    // 7-segment decoder output
    wire [6:0] seg_out;
   
    // Instantiate your BCD to 7-segment decoder
    bcd_to_7seg decoder (
        .bcd(current_digit),
        .segments(seg_out)
    );
   
    // Counter: increment on each segment_clk rising edge
    always @(posedge segment_clk or posedge rst) begin
        if (rst) begin
            digit_select <= 2'b00;
        end
        else begin
            digit_select <= digit_select + 1'b1;  // Cycles 0→1→2→3→0...
        end
    end
   
    // Multiplexer: select which digit to display and which anode to activate
    always @(*) begin
        case(digit_select)
            2'b00: begin
                current_digit = digit0;
                anodes = 4'b1110;  // Activate digit 0 (rightmost)
            end
            2'b01: begin
                current_digit = digit1;
                anodes = 4'b1101;  // Activate digit 1
            end
            2'b10: begin
                current_digit = digit2;
                anodes = 4'b1011;  // Activate digit 2
            end
            2'b11: begin
                current_digit = digit3;
                anodes = 4'b0111;  // Activate digit 3 (leftmost)
            end
        endcase
    end
   
    // Connect decoder output to segments output
    assign segments = seg_out;

endmodule

module clock_dividers(
    input wire clk,           // 50 MHz input clock
    input wire rst,           // Active high reset
    output wire two_hz_clk,   // 2 Hz output
    output wire one_hz_clk,   // 1 Hz output
    output wire segment_hz_clk, // 1 kHz output
    output wire blink_hz_clk  // 4 Hz output
);

    // Clock division factors for 50 MHz input clock
    localparam TWO_DIV_FACTOR     = 25000000;  // 2 Hz
    localparam ONE_DIV_FACTOR     = 50000000;  // 1 Hz
    localparam SEGMENT_DIV_FACTOR = 50000;     // 1 kHz
    localparam BLINK_DIV_FACTOR   = 12500000;  // 4 Hz

    // Registers for output clocks
    reg two_hz_clk_reg;
    reg one_hz_clk_reg;
    reg segment_hz_clk_reg;
    reg blink_hz_clk_reg;

    // Counters for each divider
    reg [31:0] two_counter;
    reg [31:0] one_counter;
    reg [31:0] segment_counter;
    reg [31:0] blink_counter;

    //==========================================================================
    // 2 Hz Clock Divider
    //==========================================================================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            two_counter <= 32'd0;
            two_hz_clk_reg <= 1'b0;
        end
        else if (two_counter == TWO_DIV_FACTOR - 1) begin
            two_counter <= 32'd0;
            two_hz_clk_reg <= ~two_hz_clk_reg;  // Toggle the register
        end
        else begin
            two_counter <= two_counter + 1'b1;
        end
    end

    //==========================================================================
    // 1 Hz Clock Divider
    //==========================================================================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            one_counter <= 32'd0;
            one_hz_clk_reg <= 1'b0;
        end
        else if (one_counter == ONE_DIV_FACTOR - 1) begin
            one_counter <= 32'd0;
            one_hz_clk_reg <= ~one_hz_clk_reg;  // Toggle the register
        end
        else begin
            one_counter <= one_counter + 1'b1;
        end
    end

    //==========================================================================
    // Segment Clock Divider (1 kHz for seven segment display)
    //==========================================================================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            segment_counter <= 32'd0;
            segment_hz_clk_reg <= 1'b0;
        end
        else if (segment_counter == SEGMENT_DIV_FACTOR - 1) begin
            segment_counter <= 32'd0;
            segment_hz_clk_reg <= ~segment_hz_clk_reg;  // Toggle the register
        end
        else begin
            segment_counter <= segment_counter + 1'b1;
        end
    end

    //==========================================================================
    // Blink Clock Divider (4 Hz for blinking effects)
    //==========================================================================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            blink_counter <= 32'd0;
            blink_hz_clk_reg <= 1'b0;
        end
        else if (blink_counter == BLINK_DIV_FACTOR - 1) begin
            blink_counter <= 32'd0;
            blink_hz_clk_reg <= ~blink_hz_clk_reg;  // Toggle the register
        end
        else begin
            blink_counter <= blink_counter + 1'b1;
        end
    end

    // Assign outputs
    assign two_hz_clk = two_hz_clk_reg;
    assign one_hz_clk = one_hz_clk_reg;
    assign segment_hz_clk = segment_hz_clk_reg;
    assign blink_hz_clk = blink_hz_clk_reg;

endmodule