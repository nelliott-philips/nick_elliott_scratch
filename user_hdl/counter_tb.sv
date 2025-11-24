

`timescale 1 ns / 1 ps
`default_nettype none

module counter_tb();

   logic clk;
   logic rst;
   logic [15:0] count;

   counter c0(
     .clk      (clk),
     .rst      (rst),
     .count_o  (count)
   );

   initial begin
     clk = 0;
      
     forever begin
       #5ns clk = ~clk;
     end
   end
   
   initial begin
     rst = 1;
     #50ns;
     rst = 0;
   end
   
endmodule   
