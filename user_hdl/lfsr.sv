

module lfsr #(
    parameter integer USE_COMPILE_TIME_LOGGER = 1,
    parameter integer USE_HW_DEBUG            = 0,
    parameter integer IS_RX                   = 0,
    parameter integer LFSR_WIDTH              = 16, 	      
    parameter integer USE_GOLD_CODES          = 1 	      
  )(
    input logic clk,
    input logic rst,
    input logic step_stb,
    input logic clk_en
  );


  localparam integer A_WIDTH = 4;
  localparam integer B_WIDTH = 5;

  localparam logic [3:0] CONST_POLY_A = 4'h9;
  localparam logic [4:0] CONST_POLY_B = 5'h12;
   
  // unique seed pairs per output bit
  // seed_A and seed_B must be non-zero
  // spread across state space for decorrelation
  localparam logic [3:0] SEEDS_A [16] = '{
      4'h1, 4'h2, 4'h3, 4'h4,
      4'h5, 4'h6, 4'h7, 4'h8,
      4'h9, 4'hA, 4'hB, 4'hC,
      4'hD, 4'hE, 4'hF, 4'h1  // wrap — only 15 non-zero states
  };

  localparam logic [4:0] SEEDS_B [16] = '{
      5'h01, 5'h02, 5'h04, 5'h08,
      5'h10, 5'h03, 5'h06, 5'h0C,
      5'h18, 5'h11, 5'h05, 5'h0A,
      5'h14, 5'h09, 5'h12, 5'h07
  };			 

  generate
    if (USE_COMPILE_TIME_LOGGER && !IS_RX) begin
 
      logic [LFSR_WIDTH-1:0] taps_a;
      logic [LFSR_WIDTH-1:0] poly_a;
       
      logic [LFSR_WIDTH-1:0] taps_b;
      logic [LFSR_WIDTH-1:0] poly_b;

      logic [LFSR_WIDTH-1:0] taps_comb;

      logic [63:0]	     match_detect_init;
      logic [63:0]	     match_detect_final;
      logic		     prbs_lock = 1'b0;
      integer		     prbs_lock_cnt = 0;
       
      int		     ii = 0;
      

      initial begin
	 
	 taps_a = SEEDS_A[0];
	 poly_a = CONST_POLY_A;
	 
	 taps_b = SEEDS_B[0];
	 poly_b = CONST_POLY_B;

	 for(ii = 0; ii < 10_000; ii++) begin
	   taps_a       = taps_a[0] ? (taps_a >> 1) ^ poly_a : (taps_a >> 1);
	   taps_b       = taps_b[0] ? (taps_b >> 1) ^ poly_b : (taps_b >> 1);
           taps_comb[0] = taps_a[0] ^ taps_b[0];

	   if ( ii < 64) begin
	     match_detect_init = {taps_comb[0], match_detect_init[63:1]};
	   end else if (ii >= 64) begin
	     match_detect_final = {taps_comb[0], match_detect_final[63:1]};
	     prbs_lock =  match_detect_init ==  match_detect_final;
	   end

	   if (prbs_lock) begin
	     $display("Lock!!! %d, LOCK COUNT %d", ii, prbs_lock_cnt++);

	     if(prbs_lock_cnt > 4)
	       $finish;
	      
	   end
	    
	   $display("COUNT: %d", ii);
	    
	 end

	 
	 
      end
	
    end
  endgenerate 
endmodule   
