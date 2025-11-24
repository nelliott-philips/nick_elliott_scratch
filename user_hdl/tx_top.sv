


`timescale 1 ps / 1 ps
`default_nettype none

module tx_top(
    output logic         clk_100_o,
    output  logic [8:0]  mixed_tone_o,
    //input   logic        sys_clk_i,
    input   wire         sys_clk_i,
    output  logic [7:0]  tone_a_o,
    output  logic [7:0]  tone_b_o
  );
   
  // logic       clk_100_out;
  // logic [8:0] mixed_tone;
  // logic       sys_clk;
  // logic [7:0] tone_a;
  // logic [7:0] tone_b;

  design_1_wrapper dsp_bd(
    .clk_100_out    (clk_100_o),
    .mixed_tone     (mixed_tone_o),
    .sys_clk        (sys_clk_i),
    .tone_a         (tone_a_o),
    .tone_b         (tone_b_o)
  );
	      
endmodule // tx_top

`default_nettype wire
   

