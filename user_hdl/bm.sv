
`timescale 1ns / 1ps
module bm #()();

  function automatic integer round_real(real x);
    if (x >= 0.0)
      return $rtoi(x + 0.5);
    else
      return $rtoi(x - 0.5);
  endfunction  

  localparam integer USE_COMPILE_TIME_SIM = 1;
   
  generate
    if (USE_COMPILE_TIME_SIM) begin

      logic [15:0] u1;
      logic [15:0] u2;
      real	   r;
      real	   u1_re;
      real	   u2_re;
      real	   a;
      real	   b;

      real	   z1;
      real	   z2;

      localparam U1_WIDTH  = 8;
      localparam U2_WIDTH  = 8;
 
      //localparam N_ENTRIES = $clog2(U1_WIDTH-1);
      localparam N_ENTRIES = 2**U1_WIDTH;

      logic signed [U1_WIDTH-1:0] sqrt_ln_rom [N_ENTRIES-1] = '{default: '0};
      logic signed [U1_WIDTH-1:0] cos_rom     [N_ENTRIES-1] = '{default: '0};
      localparam real		  PI                        = 3.14159265358979;

      real			  sqrt_ln_fp[$];
      real			  cos_fp[$];
      real			  t[$];

      initial begin : init_sqrt_ln_rom
	 
	real delta = 1.0/N_ENTRIES;
	int ii;
	 
        for(ii = 0; ii < N_ENTRIES; ii++) begin
          if (ii == 0) begin
	    t.push_back(0.5/N_ENTRIES);
	    sqrt_ln_fp.push_back($sqrt(-2.0*$ln(t[ii])));	     
	    //sqrt_ln_fp.push_back(-1.0*(2.0**(U1_WIDTH-1)));
	    cos_fp.push_back($cos(2.0*PI*t[ii]));
	    //sqrt_ln_rom[ii] = $signed($round(sqrt_ln_rom[ii]*(2.0**(U1_WIDTH-1))));
	    //cos_rom[ii]     = $signed($round(cos_fp[ii]*(2.0**(U1_WIDTH-1))));
	    sqrt_ln_rom[ii] = $signed(round_real(sqrt_ln_fp[ii]*(2.0**(U1_WIDTH-1))));
            cos_rom[ii]     = $signed(round_real(cos_fp[ii]*(2.0**(U1_WIDTH-1))));
	     
	  end else begin
	    t.push_back(t[$] + delta);
	    sqrt_ln_fp.push_back($sqrt(-2.0*$ln(t[ii])));
	    cos_fp.push_back($cos(2.0*PI*t[ii]));
	    // sqrt_ln_rom[ii] = $signed($round(sqrt_ln_rom[ii]*(2.0**(U1_WIDTH-1))));
	    // cos_rom[ii]     = $signed($round(cos_fp[ii]*(2.0**(U1_WIDTH-1))));
	    sqrt_ln_rom[ii] = $signed(round_real(sqrt_ln_fp[ii]*(2.0**(U1_WIDTH-1))));
            cos_rom[ii]     = $signed(round_real(cos_fp[ii]*(2.0**(U1_WIDTH-1))));
	     
	  end

	  $display("ITER: %d, T: %f, SQRT_LN: %f, COS: %f", ii, t[ii], sqrt_ln_fp[ii], cos_fp[ii]);
	   
	end
      end

      initial begin : init_cos_rom
      end

       
      localparam integer N_ROM_ENTRIES = $clog2(2**16);
      logic [15:0] lhs_rom[N_ROM_ENTRIES];
      logic [15:0] rhs_rom[N_ROM_ENTRIES];
       
      initial begin
	int ii;
	 
        for(ii = 0; ii < 4096; ii++) begin
	  u1_re = real'($urandom_range(0, 2**16))/(2.0**16);
	  u2_re = real'($urandom_range(0, 2**16))/(2.0**16);	   
          //$display("u0: %f,  u1: %f", u1_re, u2_re);

	  z1 = $sqrt(-2.0*$ln(u1_re))*$cos(2.0*3.14159265358979*u2_re);
	  z2 = $sqrt(-2.0*$ln(u1_re))*$sin(2.0*3.14159265358979*u2_re);

	  //$display("ii: %d, z1: %f,  z2: %f", ii, z1, z2); 
	   
	end
      end
    end
  endgenerate
  // Generate random 16 bit values between in intervale [0.0, 1.0]

  //

  
endmodule   
  
