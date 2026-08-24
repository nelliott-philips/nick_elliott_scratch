
`timescale 1 ns / 1 ps

module lfsr_tb;

  logic clk;
  logic rst;
  logic step_stb;
  logic clk_en;

  lfsr #(
    .USE_COMPILE_TIME_LOGGER  (1),
    .USE_HW_DEBUG             (0),
    .IS_RX                    (0),
    .LFSR_WIDTH               (16),
    .USE_GOLD_CODES           (0)
  ) l1(
    .clk                      (clk),
    .rst                      (rst),
    .step_stb                 (step_stb),
    .clk_en                   (clk_en)
  );
   
   
endmodule // lfsr_tb
