// xc7a200tfbg484-1
//
// DDS-free alternative to chroma_tp.sv.
// 20 MHz at 100 MS/s => exactly 5 samples/cycle.
// 32 phase variants => 11.25 degree phase spacing.
//
// The original external interface, gain table, and 12x12 signed multiply/
// symmetric-away-from-zero rounding structure are retained.  The DDS-specific
// AXI-stream phase interface and 8-cycle DDS pipeline are removed.

`timescale 1ns / 1ps

module chroma_tp_simple #(
    parameter integer SIM_DEBUG_ON = 1,
    parameter integer HW_DEBUG_ON  = 0
  )(
    input  wire         clk,
    input  wire         rst,
    input  wire         framesync,
    input  wire         acq_gate,
    input  wire         frame_a,
    input  wire         cf_enable,
    input  wire         test_pattern_en,
    input  wire [31:0]  gpo_reg_in,
    output logic [31:0]  gpo_reg_out,
    output logic         sine_tvalid,
    output logic         cosine_tvalid,
    output logic [15:0]  sine_tdata,
    output logic [15:0]  cosine_tdata,
    output logic         sine_tlast,
    output logic         cosine_tlast
  );

  localparam real CLOCK_FREQ   = 100.0e6;
  localparam real DESIRED_FREQ = 20.0e6;

  localparam integer N_PHASES          = 32;
  localparam integer N_CARRIER_SAMPLES = 5;
  localparam integer LUT_DEPTH         = N_PHASES * N_CARRIER_SAMPLES;
  localparam integer PHASE_IDX_WIDTH   = $clog2(N_PHASES);
  localparam integer SAMPLE_IDX_WIDTH  = $clog2(N_CARRIER_SAMPLES);

  localparam integer N_GAIN_CNT        = 184;
  localparam integer TP_GAIN_CNT_WIDTH = $clog2(N_GAIN_CNT);

  // Two acquisition registers retain the original edge-alignment structure.
  localparam integer ACQ_PIPE = 2;
  logic [ACQ_PIPE-1:0] acq_gate_pipe = '0;

  // The LUT itself is a single registered source stage.
  logic lut_tvalid_s0 = 1'b0;
  logic lut_tlast_s0  = 1'b0;

  // Multiply + rounding path retained from chroma_tp.sv.
  localparam integer MULT_PIPE = 3;
  logic [MULT_PIPE-1:0] mult_pipe_tvalid = '0;
  logic [MULT_PIPE-1:0] mult_pipe_tlast  = '0;

  logic [TP_GAIN_CNT_WIDTH-1:0] tp_gain_cnt;

  // 1874 Max and shift down by 7 instead of 12, limits output below 30k   
  // logic [11:0] tp_arr [0:N_GAIN_CNT-1] = '{
  //   12'h752,12'h752,12'h752,12'h752,
  //   12'h739,12'h739,12'h739,12'h739,12'h739,
  //   12'h71F,12'h71F,12'h71F,12'h71F,12'h71F,
  //   12'h706,12'h706,12'h706,12'h706,12'h706,
  //   12'h6EC,12'h6EC,12'h6EC,12'h6EC,12'h6EC,
  //   12'h6D1,12'h6D1,12'h6D1,12'h6D1,12'h6D1,
  //   12'h6B8,12'h6B8,12'h6B8,12'h6B8,12'h6B8,
  //   12'h69E,12'h69E,12'h69E,12'h69E,12'h69E,
  //   12'h685,12'h685,12'h685,12'h685,12'h685,
  //   12'h66C,12'h66C,12'h66C,12'h66C,12'h66C,
  //   12'h652,12'h652,12'h652,12'h652,12'h652,
  //   12'h637,12'h637,12'h637,12'h637,12'h637,
  //   12'h61E,12'h61E,12'h61E,12'h61E,12'h61E,
  //   12'h604,12'h604,12'h604,12'h604,12'h604,
  //   12'h5EA,12'h5EA,12'h5EA,12'h5EA,12'h5EA,
  //   12'h5D1,12'h5D1,12'h5D1,12'h5D1,12'h5D1,
  //   12'h5B6,12'h5B6,12'h5B6,12'h5B6,12'h5B6,
  //   12'h59C,12'h59C,12'h59C,12'h59C,12'h59C,
  //   12'h583,12'h583,12'h583,12'h583,12'h583,
  //   12'h569,12'h569,12'h569,12'h569,12'h569,
  //   12'h54E,12'h54E,12'h54E,12'h54E,12'h54E,
  //   12'h536,12'h536,12'h536,12'h536,12'h536,
  //   12'h51C,12'h51C,12'h51C,12'h51C,12'h51C,
  //   12'h502,12'h502,12'h502,12'h502,12'h502,
  //   12'h4E9,12'h4E9,12'h4E9,12'h4E9,12'h4E9,
  //   12'h4CF,12'h4CF,12'h4CF,12'h4CF,12'h4CF,
  //   12'h4B6,12'h4B6,12'h4B6,12'h4B6,12'h4B6,
  //   12'h49C,12'h49C,12'h49C,12'h49C,12'h49C,
  //   12'h481,12'h481,12'h481,12'h481,12'h481,
  //   12'h468,12'h468,12'h468,12'h468,12'h468,
  //   12'h44E,12'h44E,12'h44E,12'h44E,12'h44E,
  //   12'h434,12'h434,12'h434,12'h434,12'h434,
  //   12'h41B,12'h41B,12'h41B,12'h41B,12'h41B,
  //   12'h401,12'h401,12'h401,12'h401,12'h401,
  //   12'h3E7,12'h3E7,12'h3E7,12'h3E7,12'h3E7,
  //   12'h3CE,12'h3CE,12'h3CE,12'h3CE,12'h3CE,
  //   12'h3B4,12'h3B4,12'h3B4,12'h3B4,12'h3B4
  // };  

  // Gain coefficients from the original chroma_tp.sv.
  logic [11:0] tp_arr [0:N_GAIN_CNT-1] = '{ 
    12'h7E9,12'h7E9,12'h7E9,12'h7E9,
    12'h7CE,12'h7CE,12'h7CE,12'h7CE,12'h7CE,
    12'h7B2,12'h7B2,12'h7B2,12'h7B2,12'h7B2,
    12'h797,12'h797,12'h797,12'h797,12'h797,
    12'h77B,12'h77B,12'h77B,12'h77B,12'h77B,
    12'h75E,12'h75E,12'h75E,12'h75E,12'h75E,
    12'h743,12'h743,12'h743,12'h743,12'h743,
    12'h727,12'h727,12'h727,12'h727,12'h727,
    12'h70B,12'h70B,12'h70B,12'h70B,12'h70B,
    12'h6F0,12'h6F0,12'h6F0,12'h6F0,12'h6F0,
    12'h6D4,12'h6D4,12'h6D4,12'h6D4,12'h6D4,
    12'h6B7,12'h6B7,12'h6B7,12'h6B7,12'h6B7,
    12'h69C,12'h69C,12'h69C,12'h69C,12'h69C,
    12'h680,12'h680,12'h680,12'h680,12'h680,
    12'h664,12'h664,12'h664,12'h664,12'h664,
    12'h649,12'h649,12'h649,12'h649,12'h649,
    12'h62C,12'h62C,12'h62C,12'h62C,12'h62C,
    12'h610,12'h610,12'h610,12'h610,12'h610,
    12'h5F5,12'h5F5,12'h5F5,12'h5F5,12'h5F5,
    12'h5D9,12'h5D9,12'h5D9,12'h5D9,12'h5D9,
    12'h5BD,12'h5BD,12'h5BD,12'h5BD,12'h5BD,
    12'h5A2,12'h5A2,12'h5A2,12'h5A2,12'h5A2,
    12'h585,12'h585,12'h585,12'h585,12'h585,
    12'h569,12'h569,12'h569,12'h569,12'h569,
    12'h54E,12'h54E,12'h54E,12'h54E,12'h54E,
    12'h532,12'h532,12'h532,12'h532,12'h532,
    12'h517,12'h517,12'h517,12'h517,12'h517,
    12'h4FB,12'h4FB,12'h4FB,12'h4FB,12'h4FB,
    12'h4DE,12'h4DE,12'h4DE,12'h4DE,12'h4DE,
    12'h4C3,12'h4C3,12'h4C3,12'h4C3,12'h4C3,
    12'h4A7,12'h4A7,12'h4A7,12'h4A7,12'h4A7,
    12'h48B,12'h48B,12'h48B,12'h48B,12'h48B,
    12'h470,12'h470,12'h470,12'h470,12'h470,
    12'h454,12'h454,12'h454,12'h454,12'h454,
    12'h437,12'h437,12'h437,12'h437,12'h437,
    12'h41C,12'h41C,12'h41C,12'h41C,12'h41C,
    12'h400,12'h400,12'h400,12'h400,12'h400
  };

  // Flattened 32-phase x 5-sample ROMs.  Each phase advances by 11.25 deg.
  // Values are signed 12-bit samples scaled to +/-2047.
  (* rom_style = "distributed" *)
  logic signed [11:0] cosine_lut [0:LUT_DEPTH-1] = '{
    // phase  0:   0.00 deg
    12'sd2047, 12'sd633, -12'sd1656, -12'sd1656, 12'sd633,
    // phase  1:  11.25 deg
    12'sd2008, 12'sd241, -12'sd1859, -12'sd1390, 12'sd1000,
    // phase  2:  22.50 deg
    12'sd1891, -12'sd161, -12'sd1990, -12'sd1070, 12'sd1329,
    // phase  3:  33.75 deg
    12'sd1702, -12'sd556, -12'sd2045, -12'sd709, 12'sd1608,
    // phase  4:  45.00 deg
    12'sd1447, -12'sd929, -12'sd2022, -12'sd320, 12'sd1824,
    // phase  5:  56.25 deg
    12'sd1137, -12'sd1267, -12'sd1920, 12'sd80, 12'sd1970,
    // phase  6:  67.50 deg
    12'sd783, -12'sd1557, -12'sd1745, 12'sd478, 12'sd2041,
    // phase  7:  78.75 deg
    12'sd399, -12'sd1786, -12'sd1503, 12'sd857, 12'sd2033,
    // phase  8:  90.00 deg
    12'sd0, -12'sd1947, -12'sd1203, 12'sd1203, 12'sd1947,
    // phase  9: 101.25 deg
    -12'sd399, -12'sd2033, -12'sd857, 12'sd1503, 12'sd1786,
    // phase 10: 112.50 deg
    -12'sd783, -12'sd2041, -12'sd478, 12'sd1745, 12'sd1557,
    // phase 11: 123.75 deg
    -12'sd1137, -12'sd1970, -12'sd80, 12'sd1920, 12'sd1267,
    // phase 12: 135.00 deg
    -12'sd1447, -12'sd1824, 12'sd320, 12'sd2022, 12'sd929,
    // phase 13: 146.25 deg
    -12'sd1702, -12'sd1608, 12'sd709, 12'sd2045, 12'sd556,
    // phase 14: 157.50 deg
    -12'sd1891, -12'sd1329, 12'sd1070, 12'sd1990, 12'sd161,
    // phase 15: 168.75 deg
    -12'sd2008, -12'sd1000, 12'sd1390, 12'sd1859, -12'sd241,
    // phase 16: 180.00 deg
    -12'sd2047, -12'sd633, 12'sd1656, 12'sd1656, -12'sd633,
    // phase 17: 191.25 deg
    -12'sd2008, -12'sd241, 12'sd1859, 12'sd1390, -12'sd1000,
    // phase 18: 202.50 deg
    -12'sd1891, 12'sd161, 12'sd1990, 12'sd1070, -12'sd1329,
    // phase 19: 213.75 deg
    -12'sd1702, 12'sd556, 12'sd2045, 12'sd709, -12'sd1608,
    // phase 20: 225.00 deg
    -12'sd1447, 12'sd929, 12'sd2022, 12'sd320, -12'sd1824,
    // phase 21: 236.25 deg
    -12'sd1137, 12'sd1267, 12'sd1920, -12'sd80, -12'sd1970,
    // phase 22: 247.50 deg
    -12'sd783, 12'sd1557, 12'sd1745, -12'sd478, -12'sd2041,
    // phase 23: 258.75 deg
    -12'sd399, 12'sd1786, 12'sd1503, -12'sd857, -12'sd2033,
    // phase 24: 270.00 deg
    12'sd0, 12'sd1947, 12'sd1203, -12'sd1203, -12'sd1947,
    // phase 25: 281.25 deg
    12'sd399, 12'sd2033, 12'sd857, -12'sd1503, -12'sd1786,
    // phase 26: 292.50 deg
    12'sd783, 12'sd2041, 12'sd478, -12'sd1745, -12'sd1557,
    // phase 27: 303.75 deg
    12'sd1137, 12'sd1970, 12'sd80, -12'sd1920, -12'sd1267,
    // phase 28: 315.00 deg
    12'sd1447, 12'sd1824, -12'sd320, -12'sd2022, -12'sd929,
    // phase 29: 326.25 deg
    12'sd1702, 12'sd1608, -12'sd709, -12'sd2045, -12'sd556,
    // phase 30: 337.50 deg
    12'sd1891, 12'sd1329, -12'sd1070, -12'sd1990, -12'sd161,
    // phase 31: 348.75 deg
    12'sd2008, 12'sd1000, -12'sd1390, -12'sd1859, 12'sd241
  };

  // The sine output is generated from the same cosine phase table using a
  // -90 degree phase offset (8 of the 32 phase steps), so only one waveform
  // table is maintained in source.


  logic [PHASE_IDX_WIDTH-1:0]  phase_idx  = '0;
  logic [SAMPLE_IDX_WIDTH-1:0] sample_idx = '0;
  logic [PHASE_IDX_WIDTH-1:0]  sine_phase_idx;
  logic [7:0]                  cosine_lut_addr;
  logic [7:0]                  sine_lut_addr;

  logic signed [11:0] sine   = '0;
  logic signed [11:0] cosine = '0;
  logic signed [11:0] a_scale = 12'sd516;

  // Preserve the original "every other B-mode frame boundary" phase-update intent.
  logic accum_2x_aline_sync = 1'b0;

  // At 5 samples/carrier period, this also matches the original gain coefficient
  // repetition: 184 coefficients x 5 samples = 920 CF acquisition samples.
  localparam integer CE_REPEAT_CNT   = 5;
  localparam integer CE_REP_CNT_WIDTH = $clog2(CE_REPEAT_CNT);
  logic [CE_REP_CNT_WIDTH-1:0] ce_repeat_cnt = CE_REPEAT_CNT-1;
  logic ce_repeat = 1'b0;

  // Product / rounding signals retained from the original implementation.
  logic signed [23:0] sine_prod_s0;
  logic signed [23:0] cosine_prod_s0;

  logic [11:0] sin_mag_s1;
  logic [11:0] cos_mag_s1;
  logic        sin_has_frac_s1;
  logic        cos_has_frac_s1;
  logic        sin_is_neg_s1;
  logic        cos_is_neg_s1;
  logic signed [13:0] sin_round_s2;
  logic signed [13:0] cos_round_s2;

  // Unused original control/status ports are intentionally retained so the module
  // remains a drop-in structural alternative for the existing TB/TC environment.
  always_comb begin
    gpo_reg_out = 32'd0;
  end

  // sin(theta) = cos(theta - 90 deg).  With 32 phase variants, 90 deg is
  // exactly 8 phase indices.  Five times the phase index plus sample index
  // addresses the flattened 32 x 5 table.
  always_comb begin
    sine_phase_idx  = phase_idx - 5'd8;
    cosine_lut_addr = (phase_idx       << 2) + phase_idx       + sample_idx;
    sine_lut_addr   = (sine_phase_idx  << 2) + sine_phase_idx  + sample_idx;
  end

  // Acquisition delay and output-valid/TLAST pipeline.
  always_ff @(posedge clk) begin
    if (rst) begin
      acq_gate_pipe    <= '0;
      mult_pipe_tvalid <= '0;
      mult_pipe_tlast  <= '0;
    end else begin
      acq_gate_pipe <= {acq_gate_pipe[ACQ_PIPE-2:0], acq_gate};

      mult_pipe_tvalid <= {mult_pipe_tvalid[MULT_PIPE-2:0], lut_tvalid_s0};
      mult_pipe_tlast  <= {mult_pipe_tlast[MULT_PIPE-2:0],  lut_tlast_s0};
    end
  end

  // Advance to the next of 32 phase variants once on every other B-mode
  // frame boundary, matching the intent of the original POFF control block.
  // The selected phase is then held constant through the entire acquisition.
  always_ff @(posedge clk) begin
    if (rst) begin
      accum_2x_aline_sync <= 1'b0;
      phase_idx           <= '0;
    end else if (frame_a) begin
      accum_2x_aline_sync <= 1'b0;
      phase_idx           <= 'd0;
    end else if (!frame_a && cosine_tlast) begin
      accum_2x_aline_sync <= ~accum_2x_aline_sync;
				
      if (accum_2x_aline_sync) begin
        phase_idx <= phase_idx + 1'b1;
      end
       
    end
  end

  // Registered LUT source.  The rising edge of the pipelined acquisition gate
  // resets the 5-sample carrier index to zero.  Once active, sample_idx cycles
  // 0,1,2,3,4,0,... exactly once per 100 MHz clock.
  always_ff @(posedge clk) begin
    if (rst) begin
      sample_idx    <= '0;
      sine          <= '0;
      cosine        <= '0;
      lut_tvalid_s0 <= 1'b0;
      lut_tlast_s0  <= 1'b0;
    end else begin
      lut_tvalid_s0 <= acq_gate_pipe[ACQ_PIPE-1];

      // Last valid LUT sample is identified from the two registered copies of
      // acq_gate, so TLAST is registered and aligned with the LUT sample.
      lut_tlast_s0 <= acq_gate_pipe[1] && !acq_gate_pipe[0];

      // Detect the acquisition rising edge before the delayed valid goes active.
      if (!acq_gate_pipe[ACQ_PIPE-1] && acq_gate_pipe[ACQ_PIPE-2]) begin
        sample_idx <= '0;
      end else if (acq_gate_pipe[ACQ_PIPE-1]) begin
        sine   <= cosine_lut[sine_lut_addr];
        cosine <= cosine_lut[cosine_lut_addr];

        if (sample_idx == N_CARRIER_SAMPLES-1) begin
          sample_idx <= '0;
        end else begin
          sample_idx <= sample_idx + 1'b1;
        end
      end
    end
  end

  // Original 5-cycle coefficient-repeat generator.
  always_ff @(posedge clk) begin
    if (rst) begin
      ce_repeat     <= 1'b0;
      ce_repeat_cnt <= CE_REPEAT_CNT-1;
    end else begin
      ce_repeat     <= (CE_REPEAT_CNT-1 == ce_repeat_cnt);
      ce_repeat_cnt <= ce_repeat_cnt - 1'b1;

      if (ce_repeat_cnt == '0) begin
        ce_repeat_cnt <= CE_REPEAT_CNT-1;
      end
    end
  end

  // Original gain coefficient indexing behavior, now keyed from LUT-valid rather
  // than the former DDS-valid pipeline.
  always_ff @(posedge clk) begin
    if (rst) begin
      a_scale     <= tp_arr[N_GAIN_CNT-1];
      tp_gain_cnt <= N_GAIN_CNT-1;
    end else if (ce_repeat) begin
      a_scale <= '0;

      // Apply non-zero gain only in ChromaFlo acquisition.
      if (!frame_a && lut_tvalid_s0) begin
        a_scale <= $signed(tp_arr[tp_gain_cnt]);
      end

      // Default to starting index while inactive.
      tp_gain_cnt <= N_GAIN_CNT-1;

      if (lut_tvalid_s0) begin
        tp_gain_cnt <= tp_gain_cnt - 1'b1;
      end

      // Restart count when count is down to zero or if end of acquisition window packet
      if (tp_gain_cnt == 'd0 || cosine_tlast) begin
        tp_gain_cnt <= N_GAIN_CNT-1;
      end
       
    end
  end

  // 12-bit signed LUT sample x 12-bit signed gain coefficient -> 24-bit product.
  always_ff @(posedge clk) begin
    if (rst) begin
      sine_prod_s0   <= '0;
      cosine_prod_s0 <= '0;
    end else begin
      sine_prod_s0   <= a_scale * sine;
      cosine_prod_s0 <= a_scale * cosine;
    end
  end

  // Pipelined symmetric rounding away from zero.  This is intentionally retained
  // from chroma_tp.sv: upper 12 product bits are retained and lower 12 bits decide
  // whether the magnitude is incremented.
  always_ff @(posedge clk) begin
    if (rst) begin
      sin_mag_s1       <= '0;
      cos_mag_s1       <= '0;
      sin_has_frac_s1  <= 1'b0;
      cos_has_frac_s1  <= 1'b0;
      sin_is_neg_s1    <= 1'b0;
      cos_is_neg_s1    <= 1'b0;
      sin_round_s2     <= '0;
      cos_round_s2     <= '0;
    end else begin
      if (sine_prod_s0[23]) begin
        sin_has_frac_s1 <= |sine_prod_s0[11:0];
        sin_mag_s1      <= $unsigned(-sine_prod_s0) >> 12;
      end else begin
        sin_has_frac_s1 <= |sine_prod_s0[11:0];
        sin_mag_s1      <= $unsigned(sine_prod_s0) >> 12;
      end

      if (cosine_prod_s0[23]) begin
        cos_has_frac_s1 <= |cosine_prod_s0[11:0];
        cos_mag_s1      <= $unsigned(-cosine_prod_s0) >> 12;
      end else begin
        cos_has_frac_s1 <= |cosine_prod_s0[11:0];
        cos_mag_s1      <= $unsigned(cosine_prod_s0) >> 12;
      end

      sin_is_neg_s1 <= sine_prod_s0[23];
      cos_is_neg_s1 <= cosine_prod_s0[23];

      if (sin_is_neg_s1) begin
        sin_round_s2 <= -$signed({1'b0, ({1'b0, sin_mag_s1} + sin_has_frac_s1)});
      end else begin
        sin_round_s2 <=  $signed({1'b0, ({1'b0, sin_mag_s1} + sin_has_frac_s1)});
      end

      if (cos_is_neg_s1) begin
        cos_round_s2 <= -$signed({1'b0, ({1'b0, cos_mag_s1} + cos_has_frac_s1)});
      end else begin
        cos_round_s2 <=  $signed({1'b0, ({1'b0, cos_mag_s1} + cos_has_frac_s1)});
      end
    end
  end

  // Sign extend the 14-bit rounded values to the existing 16-bit interface.
  // assign sine_tdata   = {{2{sin_round_s2[13]}}, sin_round_s2};
  // assign cosine_tdata = {{2{cos_round_s2[13]}}, cos_round_s2};
  assign sine_tdata   = {sin_round_s2, 2'b00};
  assign cosine_tdata = {cos_round_s2, 2'b00};

  assign sine_tvalid   = mult_pipe_tvalid[MULT_PIPE-1];
  assign cosine_tvalid = mult_pipe_tvalid[MULT_PIPE-1];
  assign sine_tlast    = mult_pipe_tlast[MULT_PIPE-1];
  assign cosine_tlast  = mult_pipe_tlast[MULT_PIPE-1];

  generate
    if (HW_DEBUG_ON) begin: gen_hw_debug

       localparam integer MAX_ALINE_FRAME_SIZE = 20_000; // Don't know actual figure, TODO
       localparam integer MAX_ACQ_WINDOW_SIZE  = 6000;   // I believe largest window is 4000, TODO

       localparam integer N_ALINE_FRM   = 128;
       localparam integer N_ALINE_WIDTH = $clog2(N_ALINE_FRM);
       
       (*mark_debug = "true"*) logic [N_ALINE_WIDTH-1:0]                aline_frm_cnt   = 'd0;
       (*mark_debug = "true"*) logic [$clog2(MAX_ALINE_FRAME_SIZE)-1:0]	aline_width_cnt = 'd0;
       (*mark_debug = "true"*) logic [$clog2(MAX_ACQ_WINDOW_SIZE)-1:0]	acq_width_cnt   = 'd0;

       (*mark_debug = "true"*) logic tlast_920_flag;
       (*mark_debug = "true"*) logic rst_mon;
       (*mark_debug = "true"*) logic framesync_mon;
       (*mark_debug = "true"*) logic accum_2x_aline_sync_mon;
       (*mark_debug = "true"*) logic frame_a_mon;
       
       (*mark_debug = "true"*) logic [15:0]                 cosine_tdata_mon;
       (*mark_debug = "true"*) logic                        cosine_tlast_mon;
       (*mark_debug = "true"*) logic                        cosine_tvalid_mon;
       (*mark_debug = "true"*) logic                        acq_gate_mon;
       (*mark_debug = "true"*) logic                        test_pattern_en_mon;
       (*mark_debug = "true"*) logic                        cf_enable_mon;
       (*mark_debug = "true"*) logic [PHASE_IDX_WIDTH-1:0]  phase_idx_mon;
       (*mark_debug = "true"*) logic [SAMPLE_IDX_WIDTH-1:0] sample_idx_mon;
       (*mark_debug = "true"*) logic [7:0]                  cosine_lut_addr_mon;       
       

       assign cosine_tdata_mon        = cosine_tdata;
       assign cosine_tlast_mon        = cosine_tlast;
       assign cosine_tvalid_mon       = cosine_tvalid;
       assign acq_gate_mon            = acq_gate;
       assign test_pattern_en_mon     = test_pattern_en;
       
       assign rst_mon                 = rst;
       assign framesync_mon           = framesync;
       assign accum_2x_aline_sync_mon = accum_2x_aline_sync;
       assign frame_a_mon             = frame_a;
       assign cf_enable_mon           = cf_enable;
       assign phase_idx_mon           = phase_idx;
       assign sample_idx_mon          = sample_idx;
       assign cosine_lut_addr_mon     = cosine_lut_addr;

       always_ff @(posedge clk) begin
         if (rst) begin
	    
           tlast_920_flag    <= 'd0;
           aline_width_cnt   <= 'd0;
	   acq_width_cnt     <= 'd0;
	   aline_frm_cnt     <= 'd0;
	    
 
	 end else begin

	   if (framesync) begin
	     aline_width_cnt <= 'd0;
	     aline_frm_cnt   <=  aline_frm_cnt + 1'b1;
	     
	   end else begin
	     aline_width_cnt <= aline_width_cnt + 1'b1;	      
	   end

	   if (cosine_tvalid) begin
	     acq_width_cnt   <= acq_width_cnt + 1'b1;
	   end
	    
           if (cosine_tlast) begin
	     acq_width_cnt   <= 'd0;
	   end

	   //if (cosine_tlast = 1'b1 && (acq_width_cnt != 919 || acq_width_cnt != 1319)) begin
	   //  tlast_920_flag <= 1'b1;
	   //end

	 end // else: !if(rst)
       end // always_ff @ (posedge clk)
    end // block: gen_hw_debug
  endgenerate

  initial begin : compile_time_check_initial
    $display("chroma_tp_simple CLOCK_FREQ: %f", CLOCK_FREQ);
    $display("chroma_tp_simple DESIRED_FREQ: %f", DESIRED_FREQ);
    $display("chroma_tp_simple LUT: %0d phases x %0d samples = %0d samples", N_PHASES, N_CARRIER_SAMPLES, LUT_DEPTH);
  end

endmodule

