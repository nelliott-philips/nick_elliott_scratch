`timescale 1ns / 1ps

module chroma_tp_tb();

  logic         clk;
  logic         rst;
  logic [31:0]  gpo_reg_in;
  logic [31:0]	gpo_reg_out;
  logic	        data_tvalid;
  logic	        acq_gate;
  logic	        cf_enable;
  logic         test_pattern_en;
  logic	        sine_tvalid;
  logic         cosine_tvalid;
  logic [15:0]  sine_tdata;
  logic [15:0]  cosine_tdata;
  logic         sine_tlast;
  logic         cosine_tlast;
  logic         framesync;
  logic         frame_a;

  //chroma_tp ch_tp0(   
  chroma_tp_simple ch_tp0(
    .clk             (clk),
    .rst             (rst),
    .framesync       (framesync),
    .acq_gate        (acq_gate),
    .frame_a         (frame_a),
    .cf_enable       (cf_enable),
    .test_pattern_en (test_pattern_en),
    .gpo_reg_in      (gpo_reg_in),
    .gpo_reg_out     (gpo_reg_out),
    .sine_tvalid     (sine_tvalid),
    .cosine_tvalid   (cosine_tvalid),
    .sine_tdata      (sine_tdata),
    .cosine_tdata    (cosine_tdata),
    .sine_tlast      (sine_tlast),
    .cosine_tlast    (cosine_tlast)
  );

  initial begin
     clk = 0;

     forever begin #5; clk = ~clk; end
     
  end


  initial begin
     rst = 0;

     #200;
     rst = 1;

     #200;
     rst = 0;
  end
     
   
endmodule
