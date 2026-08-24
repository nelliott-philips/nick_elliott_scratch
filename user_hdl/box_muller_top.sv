
`timescale 1 ns / 1 ps

module box_muller_top #(
    parameter integer USE_FLOATING_POINT_SIM     = 0,
    parameter integer USE_COMPILE_TIME_FLOAT     = 1,
    parameter integer USE_COMPILE_TIME_FLOAT_LOG = 1,
    parameter integer USE_BEHAV_SIM              = 0,
    parameter integer USE_HW_DEBUG               = 0,
    parameter integer INPUT_WIDTH                = 0
  )(
    input  logic clk,
    input  logic rst,
    input  logic [INPUT_WIDTH-1:0] u1,
    input  logic [INPUT_WIDTH-1:0] u2,
    output logic [INPUT_WIDTH-1:0] z1,
    output logic [INPUT_WIDTH-1:0] z2
  );

  generate
    if (USE_COMPILE_TIME_FLOAT) begin

      // (sqrt(-2ln(u1)))*
      // Stage 0, input uniformly distributed decimals [0,1]
      real                    u1_lgr;
      real                    u2_lgr;
      logic [INPUT_WIDTH-1:0] u1_logic_lgr;
      logic [INPUT_WIDTH-1:0] u2_logic_lgr;

      assign u1_logic_lgr = rtoi(u1_lgr);
      assign u2_logic_lgr = rtoi(u2_lgr);

      real                    R;
      real		      Theta;
      logic [INPUT_WIDTH-1:0] R_logic;
      logic [INPUT_WIDTH-1:0] Theta_logic;

      
      
      initial begin
        
        
      end
       
    end
  endgenerate

   
endmodule
