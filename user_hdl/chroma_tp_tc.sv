


module chroma_tp_tc;

  `define DUT chroma_tp_tb.ch_tp0
  `define TB  chroma_tp_tb

   localparam integer PRDGY_BM_PRF_NS = 18_600; // 18.6 us
   localparam integer PRDGY_CF_PRF_NS = 14_600; // 14.6 us
   
   initial begin
      @(negedge `TB.rst);
      $display("TIME: %p, COMING OUT OF RESET!", $time);
   end

   initial begin
     
   end

endmodule
