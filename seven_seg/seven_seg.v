// =============================================================================
//  7-Segment Display Test — VSDSquadron FM Kit
//
//  2-digit multiplexed counter: counts 00 → 99 and wraps.
//  Each digit displayed for ~10 ms (multiplexing at ~100 Hz).
//  Counter increments every 0.5 seconds.
//
//  Segments: A=32  B=31  C=28  D=27  E=26  F=25  G=23
//  Digits:   dig0=34 (tens)   dig1=35 (ones)
//  DP is not connected (always off).
//
//        --A--
//       |     |
//       F     B
//       |     |
//        --G--
//       |     |
//       E     C
//       |     |
//        --D--
// =============================================================================

module seven_seg (
    output wire seg_a, seg_b, seg_c, seg_d,
    output wire seg_e, seg_f, seg_g,
    output wire dig0,           // Digit 1 (tens) enable
    output wire dig1            // Digit 2 (ones) enable
);

    // -------------------------------------------------------------------------
    //  Internal 12 MHz oscillator
    // -------------------------------------------------------------------------
    wire clk;
    SB_HFOSC #(
        .CLKHF_DIV("0b10")
    ) osc (
        .CLKHFPU(1'b1),
        .CLKHFEN(1'b1),
        .CLKHF(clk)
    );

    // -------------------------------------------------------------------------
    //  0.5 s counter — increments a 00–99 value
    // -------------------------------------------------------------------------
    reg [22:0] half_sec = 0;
    reg [3:0]  ones     = 0;    // 0–9
    reg [3:0]  tens     = 0;    // 0–9

    always @(posedge clk) begin
        if (half_sec == 23'd5_999_999) begin
            half_sec <= 0;
            if (ones == 4'd9) begin
                ones <= 0;
                if (tens == 4'd9)
                    tens <= 0;
                else
                    tens <= tens + 1'b1;
            end else begin
                ones <= ones + 1'b1;
            end
        end else begin
            half_sec <= half_sec + 1'b1;
        end
    end

    // -------------------------------------------------------------------------
    //  Digit multiplexer — swap between tens/ones at ~100 Hz
    //  12 MHz / 120_000 = 100 Hz → 10 ms per digit
    // -------------------------------------------------------------------------
    reg [16:0] mux_cnt  = 0;
    reg        sel      = 0;    // 0 = tens digit, 1 = ones digit

    always @(posedge clk) begin
        if (mux_cnt == 17'd119_999) begin
            mux_cnt <= 0;
            sel     <= ~sel;
        end else begin
            mux_cnt <= mux_cnt + 1'b1;
        end
    end

    // -------------------------------------------------------------------------
    //  BCD to 7-segment decoder
    //  Active-low segments: 0 = segment ON
    //  Pattern: {a, b, c, d, e, f, g}
    // -------------------------------------------------------------------------
    wire [3:0] digit = sel ? ones : tens;
    reg  [6:0] seg;             // {a, b, c, d, e, f, g}

    always @(*) begin
        case (digit)
            4'd0: seg = ~7'b1111110;    //  0: A B C D E F
            4'd1: seg = ~7'b0110000;    //  1:   B C
            4'd2: seg = ~7'b1101101;    //  2: A B   D E   G
            4'd3: seg = ~7'b1111001;    //  3: A B C D     G
            4'd4: seg = ~7'b0110011;    //  4:   B C     F G
            4'd5: seg = ~7'b1011011;    //  5: A   C D   F G
            4'd6: seg = ~7'b1011111;    //  6: A   C D E F G
            4'd7: seg = ~7'b1110000;    //  7: A B C
            4'd8: seg = ~7'b1111111;    //  8: A B C D E F G
            4'd9: seg = ~7'b1111011;    //  9: A B C D   F G
            default: seg = 7'b1111111;  // all off
        endcase
    end

    // -------------------------------------------------------------------------
    //  Output assignments
    // -------------------------------------------------------------------------
    assign seg_a = seg[6];
    assign seg_b = seg[5];
    assign seg_c = seg[4];
    assign seg_d = seg[3];
    assign seg_e = seg[2];
    assign seg_f = seg[1];
    assign seg_g = seg[0];

    // Digit enables — active-low: 0 = digit ON
    assign dig0 =  sel;         // tens  (sel=0 → dig0=0 → active)
    assign dig1 = ~sel;         // ones  (sel=1 → dig1=0 → active)

endmodule
