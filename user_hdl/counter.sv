
`timescale 1 ns / 1 ps
//`default_nettype none

module counter(
  input logic clk,
  input logic rst,
  output logic [15:0] count_o
);

  always @(posedge clk) begin
    if(rst) begin
      count_o <= 'd0;
    
    end else begin
      count_o <= count_o + 1'b1;
    end
  end

endmodule
