


`timescale 1 ps / 1 ps
`default_nettype none

module tx_top_tb();
   
  logic       clk_100_o;
  logic [8:0] mixed_tone_o;
  logic       sys_clk_i;
  logic [7:0] tone_a_o;
  logic [7:0] tone_b_o;

  tx_top tx_inst(
    .clk_100_o    (clk_100_o),
    .mixed_tone_o (mixed_tone_o),
    .sys_clk_i    (sys_clk_i),
    .tone_a_o     (tone_a_o),
    .tone_b_o     (tone_b_o)
  );


  initial begin
    sys_clk_i = 0;
    forever begin
      #5ns
      sys_clk_i = ~sys_clk_i;
       
    end
  end
   
	      
endmodule // tx_top

`default_nettype wire
   

