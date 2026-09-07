

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


  // localparam integer A_WIDTH = 4;
  // localparam integer B_WIDTH = 5;
  // 
  // localparam logic [3:0] CONST_POLY_A = 4'h9;
  // localparam logic [4:0] CONST_POLY_B = 5'h12;
  //  
  // // unique seed pairs per output bit
  // // seed_A and seed_B must be non-zero
  // // spread across state space for decorrelation
  // localparam logic [3:0] SEEDS_A [16] = '{
  //     4'h1, 4'h2, 4'h3, 4'h4,
  //     4'h5, 4'h6, 4'h7, 4'h8,
  //     4'h9, 4'hA, 4'hB, 4'hC,
  //     4'hD, 4'hE, 4'hF, 4'h1  // wrap — only 15 non-zero states
  // };
  // 
  // localparam logic [4:0] SEEDS_B [16] = '{
  //     5'h01, 5'h02, 5'h04, 5'h08,
  //     5'h10, 5'h03, 5'h06, 5'h0C,
  //     5'h18, 5'h11, 5'h05, 5'h0A,
  //     5'h14, 5'h09, 5'h12, 5'h07
  // };

  localparam integer A_WIDTH = 15;
  localparam integer B_WIDTH = 16;
  // localparam logic [14:0] CONST_POLY_A = 15'h6000;  // x¹⁵+x¹⁴+1
  // localparam logic [15:0] CONST_POLY_B = 16'hD008;  // x¹⁶+x¹⁵+x¹³+x⁴+1

  localparam logic [LFSR_WIDTH-1:0] CONST_POLY_A [16] = '{
      16'hD008, 16'hD008, 16'hD008, 16'hD008,
      16'hD008, 16'hD008, 16'hD008, 16'hD008,
      16'hD008, 16'hD008, 16'hD008, 16'hD008,
      16'hD008, 16'hD008, 16'hD008, 16'hD008
  };
  
  localparam logic [LFSR_WIDTH-1:0] CONST_POLY_B [16] = '{
      16'hB400, 16'hB400, 16'hB400, 16'hB400,
      16'hB400, 16'hB400, 16'hB400, 16'hB400,
      16'hB400, 16'hB400, 16'hB400, 16'hB400,
      16'hB400, 16'hB400, 16'hB400, 16'hB400
  };   

  localparam logic [LFSR_WIDTH-1:0] SEEDS_A [16] = '{
      16'h0001, 16'h0002, 16'h0004, 16'h0008,
      16'h0010, 16'h0020, 16'h0040, 16'h0080,
      16'h0100, 16'h0200, 16'h0400, 16'h0800,
      16'h1000, 16'h2000, 16'h4000, 16'h0003
  };
   
  localparam logic [15:0] SEEDS_B [16] = '{
      16'h0001, 16'h0002, 16'h0004, 16'h0008,
      16'h0010, 16'h0020, 16'h0040, 16'h0080,
      16'h0100, 16'h0200, 16'h0400, 16'h0800,
      16'h1000, 16'h2000, 16'h4000, 16'h8000
  };   

  generate
    if (USE_COMPILE_TIME_LOGGER && !IS_RX) begin
 
      logic [LFSR_WIDTH-1:0] taps_a[16];
      logic [LFSR_WIDTH-1:0] poly_a[16];
       
      logic [LFSR_WIDTH-1:0] taps_b[16];
      logic [LFSR_WIDTH-1:0] poly_b[16];

      logic [LFSR_WIDTH-1:0] taps_comb;

      localparam integer     LOCK_THRESH_WIDTH = 256;
       
      logic [LOCK_THRESH_WIDTH-1:0]	     match_detect_init[16];
      logic [LOCK_THRESH_WIDTH-1:0]	     match_detect_final[16];
       
      logic		                     prbs_lock[16] = '{default: '0};
      integer		                     prbs_lock_cnt = 0;
      int		                     ii            = 0;
      localparam integer		     N_LFSRS       = 16;
      int				     idx           = 0;

      initial begin
	 
	 taps_a = SEEDS_A;
	 poly_a = CONST_POLY_A;
	 
	 taps_b = SEEDS_B;
	 poly_b = CONST_POLY_B;

	 for(ii = 0; ii < (2**16)*10; ii++) begin
	   for (idx = 0; idx < N_LFSRS; idx++) begin
	     taps_a[idx]    = taps_a[idx][0] ? (taps_a[idx] >> 1) ^ poly_a[idx] : (taps_a[idx] >> 1);
	     taps_b[idx]    = taps_b[idx][0] ? (taps_b[idx] >> 1) ^ poly_b[idx] : (taps_b[idx] >> 1);
             taps_comb[idx] = taps_a[idx][0] ^ taps_b[idx][0];
	     
	     if ( ii < LOCK_THRESH_WIDTH) begin
	       match_detect_init[idx]  = {taps_comb[idx], match_detect_init[idx][LOCK_THRESH_WIDTH-1:1]};
	     end else if (ii >= LOCK_THRESH_WIDTH) begin
	       match_detect_final[idx] = {taps_comb[idx], match_detect_final[idx][LOCK_THRESH_WIDTH-1:1]};
	       prbs_lock[idx]          = match_detect_init[idx] ==  match_detect_final[idx];
	     end
	     
	     if (prbs_lock[idx]) begin
	       $display("Lock!!! %d, LOCK COUNT %d, idx: %d", ii, prbs_lock_cnt, idx);
	       prbs_lock_cnt++;
		
	     
	       if(prbs_lock_cnt > 4*16) begin
		 $display("PASS!!! :)");		  
	         $finish;
	       end
	        
	     end
	      
	     //$display("COUNT: %d", ii);
	   end
	 end

	 $display("PRBS LOCK FAILED: %d", ii);	 
	 
      end // initial begin

      initial begin
          taps_a  = SEEDS_A;
          poly_a  = CONST_POLY_A;
          taps_b  = SEEDS_B;
          poly_b  = CONST_POLY_B;
      
          // first verify LFSR 0 returns to seed
          for (ii = 0; ii < (2**16); ii++) begin
              taps_a[0] = taps_a[0][0] ? (taps_a[0] >> 1) ^ poly_a[0] : (taps_a[0] >> 1);
              if (taps_a[0] == SEEDS_A[0]) begin
                  $display("LFSR_A[0] period = %0d", ii+1);
                  break;
              end
          end
      
          taps_b[0] = SEEDS_B[0];
          for (ii = 0; ii < (2**16); ii++) begin
              taps_b[0] = taps_b[0][0] ? (taps_b[0] >> 1) ^ poly_b[0] : (taps_b[0] >> 1);
              if (taps_b[0] == SEEDS_B[0]) begin
                  $display("LFSR_B[0] period = %0d", ii+1);
                  break;
              end
          end
      
          $finish;
      end       

    end
  endgenerate
   
endmodule   
