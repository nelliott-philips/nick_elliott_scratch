



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
   logic frame_a_d1;
   
   always @(posedge `TB.clk) begin
      
     prev_fm_state <= fm_state;
     `TB.framesync    <= 1'b0;
     
     if(prev_fm_state != fm_state) begin
       `TB.framesync <= 1'b1;
     end
      
   end

   localparam integer ACQ_OFFSET                 = 20;
   localparam integer ACQ_GATE_INTERVAL_PRDGY_BM = 1320;
   localparam integer ACQ_GATE_INTERVAL_PRDGY_CF = 920;
   logic	      acq_gate                   = 1'b0;
   

   initial begin
     
     forever begin
	
       @(posedge `TB.framesync);
	
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

   integer fd;
   integer cosine_sample_cnt = 0;

   // Number of acquisition events to observe before ending the simulation.
   // Change this value to control the capture length, preserving the original
   // repeat-loop test model.
   localparam integer N_ACQ_TO_CAPTURE = 128;
   integer captured_cf_acq_cnt = 0;
   logic capture_done = 1'b0;
   
   initial begin

     //fd = $fopen("samples.csv", "w");
     fd = $fopen("c:/Users/320304357/dev/nick_elliott_new/nick_elliott_scratch/user_hdl/samples.csv", "w");      

     if (fd == 0) begin
       $error("Failed to open samples.csv");
       $finish;
     end

     // Preserve the original acquisition-oriented repeat-loop model.
     // The actual sample write occurs in the clocked process below so exactly
     // one sample is written for each asserted cosine_tvalid cycle.
     repeat(N_ACQ_TO_CAPTURE) begin
       @(posedge `TB.cosine_tvalid);

       if (!`TB.frame_a) begin
         // Wait for this complete CF acquisition before advancing the loop.
         @(posedge `TB.cosine_tlast);
         captured_cf_acq_cnt = captured_cf_acq_cnt + 1;
       end else begin
         // Preserve original behavior for B-mode acquisitions.
         @(posedge `TB.framesync);
       end
     end

     // Allow the final clocked logger event to complete before closing.
     @(negedge `TB.clk);
     capture_done = 1'b1;

     $display("Finished with file write!!! ************************* ");
     $display("Captured CF acquisitions: %0d", captured_cf_acq_cnt);

     $fclose(fd);
     $finish;

   end

   // Write exactly one sample per valid CF output clock.
   always @(posedge `TB.clk) begin
     if (`TB.cosine_tvalid && !`TB.frame_a) begin
       $fdisplay(fd, "%0d", $signed(`TB.cosine_tdata));

       cosine_sample_cnt = cosine_sample_cnt + 1;

       if (`TB.cosine_tlast) begin
         if (cosine_sample_cnt != ACQ_GATE_INTERVAL_PRDGY_CF) begin
           $error("TIME: %p, CF acquisition sample count = %0d, expected %0d",
                  $time, cosine_sample_cnt, ACQ_GATE_INTERVAL_PRDGY_CF);
         end

         $display("TIME: %p, CF acquisition samples = %0d",
                  $time, cosine_sample_cnt);

         cosine_sample_cnt = 0;
       end
     end
   end

   
  

endmodule


// module chroma_tp_tc;
// 
//   `define DUT chroma_tp_tb.ch_tp0
//   `define TB  chroma_tp_tb
// 
//    typedef enum logic [1:0] {
//      IDLE     = 2'd0,
//      BM_FRAME = 2'd1,
//      CF_FRAME = 2'd2	       
//    } frame_state;
// 
//    typedef enum logic [1:0] {
//      ACQUIRE_OFF = 2'd0,
//      ACQUIRE_ON  = 2'd1
//    } acquire_state;
// 
//    frame_state fm_state    = IDLE;
//    acquire_state acq_state = ACQUIRE_OFF;
// 
//    localparam integer USE_SMALL_SCALE_SIM = 0;
//    
//    
//    localparam integer PRDGY_BM_PRF_NS = 18_600; // 18.6 us
//    localparam integer PRDGY_CF_PRF_NS = 14_600; // 14.6 us
//    localparam integer TST_BM_PRF_NS = 10; // 18.6 us
//    localparam integer TST_CF_PRF_NS = 4; // 14.6 us
//    localparam integer PRDGY_BM_PRF_N_CLKS = PRDGY_BM_PRF_NS/10; // 18.6 us
//    localparam integer PRDGY_CF_PRF_N_CLKS = PRDGY_CF_PRF_NS/10; // 14.6 us
// 
//    initial begin
//       @(negedge `TB.rst);
//       $display("TIME: %p, COMING OUT OF RESET!", $time);
//    end
// 
//    integer rnd_start_interval = $urandom_range(200, 600);
//    
//    initial begin
//      #(rnd_start_interval*1ns);
//      @(posedge `TB.clk);
//      $display("TIME: %p, FRAME SEQUENCE STARTING!", $time);
// 
//      forever begin
//        if (!USE_SMALL_SCALE_SIM) begin
//          fm_state = BM_FRAME;
//          repeat(PRDGY_BM_PRF_N_CLKS) @(posedge `TB.clk);
//          fm_state = CF_FRAME;
//          repeat(PRDGY_CF_PRF_N_CLKS) @(posedge `TB.clk);
//        end else begin
//          fm_state = BM_FRAME;
//          repeat(TST_BM_PRF_NS) @(posedge `TB.clk);
//          fm_state = CF_FRAME;
//          repeat(TST_CF_PRF_NS) @(posedge `TB.clk);
//        end
//      end
//      
//    end // initial begin
// 
//    logic STRAN_fe;
//    logic framesync;
//    frame_state prev_fm_state = IDLE;
//    logic frame_a_d1;
//    
//    always @(posedge `TB.clk) begin
//       
//      prev_fm_state <= fm_state;
//      `TB.framesync    <= 1'b0;
//      
//      if(prev_fm_state != fm_state) begin
//        `TB.framesync <= 1'b1;
//      end
//       
//    end
// 
//    localparam integer ACQ_OFFSET                 = 20;
//    localparam integer ACQ_GATE_INTERVAL_PRDGY_BM = 1320;
//    localparam integer ACQ_GATE_INTERVAL_PRDGY_CF = 920;
//    logic	      acq_gate                   = 1'b0;
//    
// 
//    initial begin
//      
//      forever begin
// 	
//        @(posedge `TB.framesync);
// 	
//        if (fm_state == BM_FRAME) begin
// 	 `TB.frame_a = 1'b1;	  
// 	 #(ACQ_OFFSET*10ns);
//          `TB.acq_gate  = 1'b1;
// 
//          $display("TIME: %p, BM ACQUISITION!", $time);	  
// 	 #(ACQ_GATE_INTERVAL_PRDGY_BM*10ns);
//          `TB.acq_gate = 1'b0;	  
//        end else if (fm_state == CF_FRAME) begin
// 	 `TB.frame_a = 1'b0;	  	  
// 	 #(ACQ_OFFSET*10ns);
//          `TB.acq_gate = 1'b1;
//          $display("TIME: %p, CM ACQUISITION!", $time);	  	  
// 	 #(ACQ_GATE_INTERVAL_PRDGY_CF*10ns);
//          `TB.acq_gate = 1'b0;	  
//        end
// 	  
//      end   
//      
//    end // initial begin
// 
//    integer fd;
//    
//    initial begin
// 
//      //fd = $fopen("samples.csv", "w");
//      fd = $fopen("c:/Users/320304357/dev/nick_elliott_new/nick_elliott_scratch/user_hdl/samples.csv", "w");      
// 
//      if (fd == 0) begin
//        $error("Failed to open sample.csv");
//        $finish;
//      end
//      // iterate of 256 alines, where 128 () alines constitute a chromaflow frame
//      repeat(256*10) begin
//        @(posedge `TB.cosine_tvalid);
// 	
//        if (!`TB.frame_a) begin
// 	  
//          $fdisplay(fd, "%0d", $signed(`TB.cosine_tdata));
//          while(`TB.cosine_tvalid) begin
// 	   @(posedge `TB.clk);
//            $fdisplay(fd, "%0d", $signed(`TB.cosine_tdata));
//          end
// 	  
//        end else begin
//          @(posedge `TB.framesync);
//        end
// 	
//      end // repeat (10)
// 
//      $display("Finished with file write!!! ************************* ");
//      $display("Finished with file write!!! ************************* ");
//      $display("Finished with file write!!! ************************* ");
// 
//      $fclose(fd);
//      $finish;
// 
//    end
// 
//    
//   
// 
// endmodule
