

`timescale 1ns / 1ps

module gpo_chroma_data_ctl
(
  input  wire        clk,
  input  wire        rst,
  input  wire [31:0] gpo_data_i,
  input  wire [15:0] motion_filter_data,
  input  wire [11:0] band_pass_filter_data,
  output reg  [31:0] gpo_data_o
);

  localparam integer        EN_BPF_ACTIV_MON_IDX   = 17;
  localparam integer        EN_MOTION_FILT_MON_IDX = 16;

  // BP = Bandpass, MOT = Motion, 3 bits each for possible of 8 filters (fewer than 8 are currently implementd
  localparam integer        MOT_SEL_MSB            = 5;
  localparam integer        MOT_SEL_LSB            = 3;
  localparam integer        BP_SEL_MSB             = 2;
  localparam integer        BP_SEL_LSB             = 0;
   
  localparam reg     [2:0]  EEP_NORM_LUT_SEL       = 3'd0;
  localparam reg     [2:0]  PVO18_NORM_LUT_SEL     = 3'd1;
  localparam reg     [2:0]  PRODIGY_NORM_LUT_SEL   = 3'd2;

  // Consider using later for "one-shot" captures where EN's are self clearing (EN_BPF_ACTIV_MON_IDX, EN_MOTION_FILT_MON_IDX)
  localparam reg     [31:0] CLEAR_BIT_MASK         = (32'd1 << EN_MOTION_FILT_MON_IDX) | (32'd1 << EN_BPF_ACTIV_MON_IDX);
  
  reg 		    [15:0]  activity_monitor       = 16'd0;

  always @(posedge clk) begin
    if(rst) begin
       
      activity_monitor <= 16'hBEEF;
       
    end else if( gpo_data_i[EN_BPF_ACTIV_MON_IDX] ) begin
       
      activity_monitor <= activity_monitor ^ {4'b0000, band_pass_filter_data};
       
    end else if( gpo_data_i[EN_MOTION_FILT_MON_IDX] ) begin
       
      activity_monitor <= motion_filter_data;
      
    end else begin
       
      activity_monitor <= 16'hBEEF;
       
    end
  end

  assign gpo_data_o[31:16]                    = activity_monitor;
  assign gpo_data_o[MOT_SEL_MSB:MOT_SEL_LSB]  = gpo_data_i[MOT_SEL_MSB:MOT_SEL_LSB]; // Motion Filter Select
  assign gpo_data_o[BP_SEL_MSB:BP_SEL_LSB]    = gpo_data_i[BP_SEL_MSB:BP_SEL_LSB];   // BP Filter Select   
   
endmodule   

