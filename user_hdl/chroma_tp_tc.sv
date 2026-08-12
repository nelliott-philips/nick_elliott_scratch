


module chroma_tp_tc;

  `define DUT chroma_tp_tb.ch_tp0
  `define TB  chroma_tp_tb

   typedef enum logic [1:0] {
     IDLE     = 2'd0,
     BM_FRAME = 2'd1,
     CF_FRAME = 2'd2	       
   } frame_state;

   typedef enum logic [1:0] {
     ACQUIRE_OFF = 2'd0,
     ACQUIRE_ON  = 2'd1
   } acquire_state;

   frame_state fm_state    = IDLE;
   acquire_state acq_state = ACQUIRE_OFF;

   localparam integer USE_SMALL_SCALE_SIM = 0;
   
   
   localparam integer PRDGY_BM_PRF_NS = 18_600; // 18.6 us
   localparam integer PRDGY_CF_PRF_NS = 14_600; // 14.6 us
   localparam integer TST_BM_PRF_NS = 10; // 18.6 us
   localparam integer TST_CF_PRF_NS = 4; // 14.6 us
   localparam integer PRDGY_BM_PRF_N_CLKS = PRDGY_BM_PRF_NS/10; // 18.6 us
   localparam integer PRDGY_CF_PRF_N_CLKS = PRDGY_CF_PRF_NS/10; // 14.6 us

   initial begin
      @(negedge `TB.rst);
      $display("TIME: %p, COMING OUT OF RESET!", $time);
   end

   integer rnd_start_interval = $urandom_range(200, 600);
   
   initial begin
     #(rnd_start_interval*1ns);
     @(posedge `TB.clk);
     $display("TIME: %p, FRAME SEQUENCE STARTING!", $time);

     forever begin
       if (!USE_SMALL_SCALE_SIM) begin
         fm_state = BM_FRAME;
         repeat(PRDGY_BM_PRF_N_CLKS) @(posedge `TB.clk);
         fm_state = CF_FRAME;
         repeat(PRDGY_CF_PRF_N_CLKS) @(posedge `TB.clk);
       end else begin
         fm_state = BM_FRAME;
         repeat(TST_BM_PRF_NS) @(posedge `TB.clk);
         fm_state = CF_FRAME;
         repeat(TST_CF_PRF_NS) @(posedge `TB.clk);
       end
     end
     
   end // initial begin

   logic STRAN_fe;
   logic framesync;
   frame_state prev_fm_state = IDLE;
   
   always @(posedge `TB.clk) begin
      
     prev_fm_state <= fm_state;
     framesync     <= 1'b0;
     
     if(prev_fm_state != fm_state) begin
        framesync <= 1'b1;
     end
      
   end

   localparam integer ACQ_OFFSET                 = 20;
   localparam integer ACQ_GATE_INTERVAL_PRDGY_BM = 1320;
   localparam integer ACQ_GATE_INTERVAL_PRDGY_CF = 920;
   logic	      acq_gate                   = 1'b0;
   

   initial begin
     
     forever begin
	
       @(posedge framesync);
	
       if (fm_state == BM_FRAME) begin
	 `TB.frame_a = 1'b1;	  
	 #(ACQ_OFFSET*10ns);
         `TB.acq_gate  = 1'b1;

         $display("TIME: %p, BM ACQUISITION!", $time);	  
	 #(ACQ_GATE_INTERVAL_PRDGY_BM*10ns);
         `TB.acq_gate = 1'b0;	  
       end else if (fm_state == CF_FRAME) begin
	 `TB.frame_a = 1'b0;	  	  
	 #(ACQ_OFFSET*10ns);
         `TB.acq_gate = 1'b1;
         $display("TIME: %p, CM ACQUISITION!", $time);	  	  
	 #(ACQ_GATE_INTERVAL_PRDGY_CF*10ns);
         `TB.acq_gate = 1'b0;	  
       end
	  
     end   
     
   end // initial begin

   

   
  

endmodule
