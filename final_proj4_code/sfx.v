// AIN is driven as a center-biased PWM:
//   silence  ? 50% duty (net AC = 0V after cap)
//   tone     ? duty oscillates 25%?75% at the target frequency
//
// PWM carrier: 8-bit counter ? 256 steps @ 50MHz = ~195 kHz carrier
// Phase accumulator: 24-bit, top bit drives duty hi/lo at target freq
// Silence: tone_active=0, duty held at 8'h80 (50%)

module sfx #(
    parameter CLK_FREQ = 50_000_000
)(
    input  clk,
    input  rst,
    input  is_valid,      // single-cycle trigger
    input  is_invalid,    // single-cycle trigger

    output reg ain,       // PWM ? PmodAMP2 AIN (JA pin 1)
    output     gain,      // PmodAMP2 GAIN      (JA pin 2)
    output     shutdown_n // PmodAMP2 ~SHUTDOWN (JA pin 3)
);

    // ?? AMP2 control ?????????????????????????????????????????????????
    assign gain       = 1'b0;   // high-volume mode
    assign shutdown_n = ~rst;   // mute during reset, enable otherwise

    // ?? Duty cycle (combinational) ????????????????????????????????????
    reg [7:0] duty;
    reg       tone_active;

    always @(*) begin
        if (!tone_active)
            duty = 8'h80;                           // silence = 50%
        else
            duty = phase_acc[23] ? 8'hC0 : 8'h40;  // ±25% swing
    end

    // ?? PWM carrier + comparator ??????????????????????????????????????
    // 8-bit counter ? ~195 kHz carrier at 50 MHz
    reg [7:0] pwm_cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pwm_cnt <= 0;
            ain     <= 0;
        end else begin
            pwm_cnt <= pwm_cnt + 1;
            ain     <= (pwm_cnt < duty);
        end
    end

    // ?? Phase accumulator ?????????????????????????????????????????????
    // Top bit toggles at target_freq = (phase_step * CLK_FREQ) / 2^24
    reg [23:0] phase_acc;
    reg [23:0] phase_step;

    always @(posedge clk or posedge rst) begin
        if (rst) phase_acc <= 0;
        else     phase_acc <= phase_acc + phase_step;
    end

    // ?? Phase step constants ??????????????????????????????????????????
    // step = round(freq * 2^24 / 50_000_000)
    localparam STEP_C6 = 24'd352_187;   // 1047 Hz  - valid hi ding
    localparam STEP_G5 = 24'd263_314;   //  784 Hz  - valid lo dong
    localparam STEP_A3 = 24'd73_819;    //  220 Hz  - dispense rattle
    localparam STEP_E4 = 24'd110_728;   //  330 Hz  - invalid buzz start

    // ?? Duration constants ????????????????????????????????????????????
    localparam DUR_SHORT  = CLK_FREQ / 4;   // 250 ms
    localparam DUR_MEDIUM = CLK_FREQ / 2;   // 500 ms
    localparam DUR_RATTLE = CLK_FREQ / 8;   // 125 ms per burst

    // ?? FSM ??????????????????????????????????????????????????????????
    localparam S_IDLE     = 3'd0,
               S_VALID_HI = 3'd1,
               S_VALID_LO = 3'd2,
               S_DISPENSE = 3'd3,
               S_INVALID  = 3'd4;

    reg [2:0]  state;
    reg [25:0] dur_cnt;
    reg [1:0]  rattle_cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state      <= S_IDLE;
            dur_cnt    <= 0;
            rattle_cnt <= 0;
            phase_step <= 0;
            tone_active <= 0;
            phase_acc  <= 0;
        end else begin
            case (state)

                S_IDLE: begin
                    tone_active <= 0;
                    phase_acc   <= 0;
                    dur_cnt     <= 0;
                    rattle_cnt  <= 0;
                    if (is_valid) begin
                        phase_step  <= STEP_C6;
                        tone_active <= 1;
                        state       <= S_VALID_HI;
                    end else if (is_invalid) begin
                        phase_step  <= STEP_E4;
                        tone_active <= 1;
                        state       <= S_INVALID;
                    end
                end

                S_VALID_HI: begin
                    if (dur_cnt == DUR_SHORT - 1) begin
                        dur_cnt     <= 0;
                        phase_step  <= STEP_G5;
                        phase_acc   <= 0;   // reset on freq change to avoid click
                        state       <= S_VALID_LO;
                    end else
                        dur_cnt <= dur_cnt + 1;
                end

                S_VALID_LO: begin
                    if (dur_cnt == DUR_SHORT - 1) begin
                        dur_cnt    <= 0;
                        phase_step <= STEP_A3;
                        phase_acc  <= 0;
                        rattle_cnt <= 0;
                        state      <= S_DISPENSE;
                    end else
                        dur_cnt <= dur_cnt + 1;
                end

                S_DISPENSE: begin
                    // Alternate: tone burst ? silence ? tone burst ...
                    tone_active <= ~rattle_cnt[0];
                    if (dur_cnt == DUR_RATTLE - 1) begin
                        dur_cnt <= 0;
                        if (rattle_cnt == 2'd3) begin
                            tone_active <= 0;
                            state       <= S_IDLE;
                        end else begin
                            rattle_cnt <= rattle_cnt + 1;
                            phase_acc  <= 0;
                        end
                    end else
                        dur_cnt <= dur_cnt + 1;
                end

                S_INVALID: begin
                    // Chirp down: reduce phase_step every ~50 ms
                    if (dur_cnt[20:0] == 21'd0 && dur_cnt != 0)
                        phase_step <= phase_step - 24'd800;
                    if (dur_cnt == DUR_MEDIUM - 1) begin
                        tone_active <= 0;
                        state       <= S_IDLE;
                    end else
                        dur_cnt <= dur_cnt + 1;
                end

                default: state <= S_IDLE;

            endcase
        end
    end

endmodule