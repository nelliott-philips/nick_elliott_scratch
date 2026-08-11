module mult_round_away_s12_uq12 (
    input  logic               clk,
    input  logic               rst,

    input  logic               in_valid,
    input  logic signed [11:0] sample_in,
    input  logic        [11:0] coeff_in,   // UQ0.12

    output logic               out_valid,
    output logic signed [11:0] sample_out
);

    // ----------------------------------------------------------------
    // Stage 1: registered DSP inputs
    // ----------------------------------------------------------------

    logic signed [11:0] sample_s1;
    logic signed [12:0] coeff_s1;

    logic valid_s1;

    always_ff @(posedge clk) begin
        if (rst) begin
            sample_s1 <= '0;
            coeff_s1  <= '0;
            valid_s1  <= 1'b0;
        end
        else begin
            sample_s1 <= sample_in;

            // Preserve the unsigned coefficient range 0 through 4095
            // while presenting it to the multiplier as a positive
            // signed 13-bit operand.
            coeff_s1 <= $signed({1'b0, coeff_in});

            valid_s1 <= in_valid;
        end
    end

    // ----------------------------------------------------------------
    // Stage 2: registered multiplier output
    //
    // 12-bit signed sample:
    //     -2048 through +2047
    //
    // 12-bit unsigned coefficient:
    //     0 through 4095
    //
    // The true product range fits in signed 24 bits.
    // ----------------------------------------------------------------

    (* use_dsp = "yes" *)
    logic signed [23:0] product_s2;

    logic valid_s2;

    always_ff @(posedge clk) begin
        if (rst) begin
            product_s2 <= '0;
            valid_s2   <= 1'b0;
        end
        else begin
            product_s2 <= sample_s1 * coeff_s1;
            valid_s2   <= valid_s1;
        end
    end

    // ----------------------------------------------------------------
    // Stage 3: magnitude and discarded-fraction detection
    //
    // Product format:
    //     signed 24-bit value with 12 fractional bits
    // ----------------------------------------------------------------

    logic        [23:0] magnitude_s3;
    logic        [11:0] integer_mag_s3;
    logic               has_fraction_s3;
    logic               negative_s3;
    logic               valid_s3;

    always_ff @(posedge clk) begin
        if (rst) begin
            magnitude_s3    <= '0;
            integer_mag_s3  <= '0;
            has_fraction_s3 <= 1'b0;
            negative_s3     <= 1'b0;
            valid_s3        <= 1'b0;
        end
        else begin
            negative_s3 <= product_s2[23];

            if (product_s2[23])
                magnitude_s3 <= $unsigned(-product_s2);
            else
                magnitude_s3 <= $unsigned(product_s2);

            /*
             * These use product_s2 directly rather than magnitude_s3
             * because nonblocking assignments update magnitude_s3 after
             * the clock edge.
             */
            if (product_s2[23]) begin
                integer_mag_s3  <= $unsigned(-product_s2) >> 12;
                has_fraction_s3 <= |$unsigned(-product_s2)[11:0];
            end
            else begin
                integer_mag_s3  <= $unsigned(product_s2) >> 12;
                has_fraction_s3 <= |$unsigned(product_s2)[11:0];
            end

            valid_s3 <= valid_s2;
        end
    end

    // ----------------------------------------------------------------
    // Stage 4: round magnitude upward and restore sign
    //
    // Away-from-zero rounding:
    //
    //     rounded magnitude =
    //         truncated magnitude + 1 when fraction != 0
    // ----------------------------------------------------------------

    logic        [12:0] rounded_mag_s4;
    logic signed [13:0] rounded_signed_s4;
    logic               valid_s4;

    always_ff @(posedge clk) begin
        if (rst) begin
            rounded_mag_s4    <= '0;
            rounded_signed_s4 <= '0;
            valid_s4          <= 1'b0;
        end
        else begin
            rounded_mag_s4 <=
                {1'b0, integer_mag_s3} + has_fraction_s3;

            if (negative_s3) begin
                rounded_signed_s4 <=
                    -$signed({
                        1'b0,
                        ({1'b0, integer_mag_s3} + has_fraction_s3)
                    });
            end
            else begin
                rounded_signed_s4 <=
                    $signed({
                        1'b0,
                        ({1'b0, integer_mag_s3} + has_fraction_s3)
                    });
            end

            valid_s4 <= valid_s3;
        end
    end

    // ----------------------------------------------------------------
    // Stage 5: saturate to signed 12-bit output
    // ----------------------------------------------------------------

    always_ff @(posedge clk) begin
        if (rst) begin
            sample_out <= '0;
            out_valid  <= 1'b0;
        end
        else begin
            if (rounded_signed_s4 > 14'sd2047)
                sample_out <= 12'sd2047;
            else if (rounded_signed_s4 < -14'sd2048)
                sample_out <= -12'sd2048;
            else
                sample_out <= rounded_signed_s4[11:0];

            out_valid <= valid_s4;
        end
    end

endmodule
