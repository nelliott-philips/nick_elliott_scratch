
`timescale 1 ns / 1 ps

module gpo_watchdog_tc();

  `define TB  gpo_watchdog_tb
  `define GPO gpo_register
  `define WD  gpo_watchdog

   localparam time T_CLK         = 10ns;
   localparam int  BASE2_CNT_IDX = 28;
   
   typedef logic [31:0] uint32_t;
   
   // typedef enum int 
   // {
   //   WD_START_STOP_IDX           = 0,
   //   APPEASE_IDX                 = 1,
   //   DISABLE_INTERRUPT_IDX       = 2,
   //   CLEAR_EARLY_WARN_INTRPT_IDX = 3,
   //   HAS_TIMED_OUT_IDX           = 4,
   //   WD_CNT_MSB                  = BASE2_CNT_IDX-1,
   //   WD_CNT_LSB                  = BASE2_CNT_IDX-4
   // } wd_ctl_bits_t; 
  typedef enum int {
    WD_START_STOP_IDX            = 0,
    APPEASE_IDX                  = 1,
    ENABLE_INTERRUPT_IDX         = 2,
    CLEAR_EARLY_WARN_INT_IDX     = 3,
    HAS_TIMED_OUT_IDX            = 4,
    IS_IN_SHUTDOWN_IDX           = 5,
    FORCE_SHUTDOWN_IDX           = 6,
    EARLY_WARN_POLL_IDX          = 7 
  } WD_CTL;
  
  // Register Write Masks 
  localparam	uint32_t START_WD                     = (32'd1 << WD_START_STOP_IDX);
  localparam	uint32_t APPEASE_WD                   = (32'd1 << APPEASE_IDX);
  localparam	uint32_t CLEAR_EARLY_WARN_INTRPT_WD   = (32'd1 << CLEAR_EARLY_WARN_INT_IDX);
  localparam	uint32_t ENABLE_WD_INTRPT             = (32'd1 << ENABLE_INTERRUPT_IDX);
  localparam	uint32_t IS_IN_SHUTDOWN_WD            = (32'd1 << IS_IN_SHUTDOWN_IDX);
  localparam	uint32_t FORCE_SHUTDOWN_WD            = (32'd1 << FORCE_SHUTDOWN_IDX);
  localparam	uint32_t EARLY_WARN_POLL_WD           = (32'd1 << EARLY_WARN_POLL_IDX);
 						      
						      
  localparam	uint32_t TIMEOUT_INTV_3000ms          = {16'd3000, 16'd0};
  localparam	uint32_t TIMEOUT_INTV_2ms             = {   16'd2, 16'd0};
  localparam	uint32_t TIMEOUT_INTV_20ms            = {  16'd20, 16'd0};   
  localparam	uint32_t TIMEOUT_INTV_100ms           = { 16'd100, 16'd0};

  // 10e-9*(2^17) = 0.013sec = 13ms
  localparam	uint32_t SIMPLE_TIMEOUT_10ms           = {  32'd1 << 20};

  // --------------------------------------------------------------------------------------------   
  // ----------  CHROMA DATAPATH GPO REGISTER                        ----------------------------
  // --------------------------------------------------------------------------------------------
  localparam integer        EN_BPF_ACTIV_MON_IDX   = 17;
  localparam integer        EN_MOTION_FILT_MON_IDX = 16;

  // BP = Bandpass, MOT = Motion, 3 bits each for possible of 8 filters (fewer than 8 are currently implementd
  localparam integer        MOT_SEL_MSB            = 5;
  localparam integer        MOT_SEL_LSB            = 3;
  localparam integer        BP_SEL_MSB             = 2;
  localparam integer        BP_SEL_LSB             = 0;
   
  localparam reg     [2:0]  EEP_NORM_LUT_SEL       = 3'd0;
  localparam reg     [2:0]  PVO18_NORM_LUT_SEL     = 3'd1;
  localparam reg     [2:0]  PRODIGY_NORM_LUT_SEL   = 3'd2;

  logic [31:0]		    filter_data            = 'd0;
   
  uint32_t tmp_chroma_reg = 32'd0;
   
  // --------------------------------------------------------------------------------------------   
   

  int ii = 0;
  int passing = 1;
  int rand_cnt = 0;
   
   
  uint32_t tmp_reg = 32'd0;

  //task tWR_GPO(input logic [31:0] data_in);
  task tWR_GPO(input uint32_t data_in);
     
     @(posedge `TB.clk);
     `TB.datain = data_in;
     
     @(posedge `TB.clk);
     @(posedge `TB.clk);
     `TB.wr_strobe = 1'b1;
     @(posedge `TB.clk);
     `TB.wr_strobe = 1'b0;
     @(posedge `TB.clk);
     
  endtask // tWR_GPO

  //task tWR_GPO(input logic [31:0] data_in);
  task tWR_GPO_CHROMA(input uint32_t data_in);
     
     @(posedge `TB.clk);
     `TB.chroma_gpo_in = data_in;
     
     @(posedge `TB.clk);
     @(posedge `TB.clk);
     `TB.chroma_wr_strobe = 1'b1;
     @(posedge `TB.clk);
     `TB.chroma_wr_strobe = 1'b0;
     @(posedge `TB.clk);
     
  endtask // tWR_GPO
   
  // task tINIT();
  //    @(posedge `TB.clk);
  //    `TB.clr_bit_mask = CLEAR_EARLY_WARN_INTRPT_WD | APPEASE_WD;
  // endtask

  logic [31:0] activity_mon = 'd0;

  
   
  task tDRIVE_CHROMA_GPO();


    $display("Beginning register writes: %t", $time);
     
    tmp_chroma_reg = 32'd0;
    tmp_chroma_reg = (32'd1 << EN_BPF_ACTIV_MON_IDX) | (32'd3 << 3) | (32'd1 << 0);
     
    tWR_GPO_CHROMA(tmp_chroma_reg);

    for(int ii = 0; ii < 100; ii++) begin
      @(posedge `TB.clk);

      activity_mon = `TB.chroma_gpo_out;
       
    end

    $display("Setting to motion filter monitor: %t", $time);
    tmp_chroma_reg = (32'd1 << EN_MOTION_FILT_MON_IDX) | (32'd3 << 3) | (32'd1 << 0);
     
    tWR_GPO_CHROMA(tmp_chroma_reg);

    
  endtask // tDRIVE_CHROMA_GPO

  initial begin

    @(negedge `TB.rst);
    $display("Coming out of reset %t", $time);
     
     
    repeat(5) begin
      @(posedge `TB.clk);
      $display("5 clocks %t", $time);       
    end

    tDRIVE_CHROMA_GPO();
     
  end

  // Random data stimulus
  initial begin
     @(negedge `TB.rst);
     
     forever begin

       @(posedge `TB.clk);


       filter_data = $urandom();
	
       `TB.motion_filter_data    = filter_data[15:0];
       `TB.band_pass_filter_data = filter_data[11:0];
				  
     end
  end
      

  task tSHORT_TIMEOUT_TEST_SIMPLE();
    
    repeat(5) begin
      @(posedge `TB.clk);
    end 

    // tWR_GPO(START_WD | TIMEOUT_INTV_3000ms);
    // tWR_GPO(START_WD | TIMEOUT_INTV_2ms);
    // tWR_GPO(START_WD | TIMEOUT_INTV_100ms );
    tWR_GPO(32'd0);
     
    @(posedge `TB.clk);
    tWR_GPO(START_WD);

    // Run loops to check a few successful appease intervals
    for(ii = 0; ii < 5; ii++) begin

      // Wait for less than a timeout interval
      #10ms; // Timeout is 13 ms

      // Check if shutdown has occured
      if (`TB.shutdown == 0) begin
         passing &= 1;
      end else begin
         passing = 0;	 
      end

      // Read-back-write equivalent of appease to appease watchdog before
      // timeout
      tWR_GPO(APPEASE_WD | `TB.gpo_reg_data_out);
       
    end
      
    if (passing == 1) begin
      $display("%t, Passed", $time);
    end else begin
      $display("%t, failed", $time);
    end

    passing = 1;

    // Run loops to check a few "late" appease intervals
    for(ii = 0; ii < 5; ii++) begin

      // Wait for more than a timeout interval
      #15ms;

      // Check if shutdown has occured
      if (`TB.shutdown == 1'b0) begin
         passing = 0;
      end else begin
         passing &= 1;	 
      end

      // Read-back-write equivalent of appease to appease watchdog before
      // timeout
      tWR_GPO( APPEASE_WD | `TB.gpo_reg_data_out );
       
    end // for (ii = 0; ii < 5; ii++)

    if (passing == 1) begin 
      $display("%t, Passed, Timed out as expected", $time);
    end else begin
      $display("%t, Failed, Did not timeout as expected", $time);       
    end

    passing = 1;

    for(ii = 0; ii < 10; ii++) begin
      if (`TB.shutdown == 1) begin
	$display("Watching timeout...");
        #3.3ms;
      end
    end
    $display("Done waiting, testing stop watchdog");

    tWR_GPO( `TB.gpo_reg_data_out & ~START_WD );

    $display("wait 61 ms"); // arbitrary odd time
    #61ms
      
    tWR_GPO( `TB.gpo_reg_data_out | START_WD );

    // Run loops to check a few successful appease intervals
    for(ii = 0; ii < 5; ii++) begin

      // Wait for less than a timeout interval
      #18ms;

      // Check if shutdown has occured
      if (`TB.shutdown == 0) begin
         passing &= 1;
      end else begin
         passing = 0;	 
      end

      // Read-back-write equivalent of appease to appease watchdog before
      // timeout
      tWR_GPO(APPEASE_WD | `TB.gpo_reg_data_out);
       
    end
      
    if (passing == 1) begin
      $display("%t, Passed", $time);
    end else begin
      $display("%t, failed", $time);
    end

    passing = 1;
     
     
  endtask // tSHORT_TIMEOUT_TEST

   
  task tSHORT_TIMEOUT_TEST();
    
    repeat(5) begin
      @(posedge `TB.clk);
    end 

    // tWR_GPO(START_WD | TIMEOUT_INTV_3000ms);
    // tWR_GPO(START_WD | TIMEOUT_INTV_2ms);
    // tWR_GPO(START_WD | TIMEOUT_INTV_100ms );
    tWR_GPO(32'd0);
     
    @(posedge `TB.clk);
    tWR_GPO(START_WD | TIMEOUT_INTV_20ms);


    // Run loops to check a few successful appease intervals
    for(ii = 0; ii < 5; ii++) begin

      // Wait for less than a timeout interval
      #18ms;

      // Check if shutdown has occured
      if (`TB.shutdown == 0) begin
         passing &= 1;
      end else begin
         passing = 0;	 
      end

      // Read-back-write equivalent of appease to appease watchdog before
      // timeout
      tWR_GPO(APPEASE_WD | `TB.gpo_reg_data_out);
       
    end
      
    if (passing == 1) begin
      $display("%t, Passed", $time);
    end else begin
      $display("%t, failed", $time);
    end

    passing = 1;

    // Run loops to check a few "late" appease intervals
    for(ii = 0; ii < 5; ii++) begin

      // Wait for more than a timeout interval
      #22ms;

      // Check if shutdown has occured
      if (`TB.shutdown == 1'b0) begin
         passing = 0;
      end else begin
         passing &= 1;	 
      end

      // Read-back-write equivalent of appease to appease watchdog before
      // timeout
      tWR_GPO( `TB.gpo_reg_data_out | APPEASE_WD );
       
    end // for (ii = 0; ii < 5; ii++)

    if (passing == 1) begin 
      $display("%t, Passed, Timed out as expected", $time);
    end else begin
      $display("%t, Failed, Did not timeout as expected", $time);       
    end

    passing = 1;

    for(ii = 0; ii < 10; ii++) begin
      if (`TB.shutdown == 1) begin
	$display("Watching timeout...");
        #3.3ms;
      end
    end
    $display("Done waiting, testing stop watchdog");

    tWR_GPO( `TB.gpo_reg_data_out & ~START_WD );

    $display("wait 61 ms"); // arbitrary odd time
    #61ms
      
    tWR_GPO( `TB.gpo_reg_data_out | START_WD );

    // Run loops to check a few successful appease intervals
    for(ii = 0; ii < 5; ii++) begin

      // Wait for less than a timeout interval
      #18ms;

      // Check if shutdown has occured
      if (`TB.shutdown == 0) begin
         passing &= 1;
      end else begin
         passing = 0;	 
      end

      // Read-back-write equivalent of appease to appease watchdog before
      // timeout
      tWR_GPO(APPEASE_WD | `TB.gpo_reg_data_out);
       
    end
      
    if (passing == 1) begin
      $display("%t, Passed", $time);
    end else begin
      $display("%t, failed", $time);
    end

    passing = 1;
     
     
  endtask // tSHORT_TIMEOUT_TEST

  

  task tRD_GPO();
  endtask // tRD_GPO

  initial begin

    @(negedge `TB.rst);

    //tINIT();
    
    //tSHORT_TIMEOUT_TEST();
    tSHORT_TIMEOUT_TEST_SIMPLE();     
     
  end

  task tV2_STIM();
    
  endtask 

  // initial begin
  //   forever begin
  //      // Wait for interrupt
  //      @(posedge `TB.early_warn_intrpt);
  //      $display("Caught early warn interrupt");
  // 
  //      // Wait a small random number of cycles
  //      repeat($urandom_range(5,50)) begin
  //         @(posedge `TB.clk);
  //      end
  //      
  //      tmp_reg = `TB.gpo_reg_data_out;       
  //      @(posedge `TB.clk);
  // 
  //      tWR_GPO(APPEASE_WD | tmp_reg);
  // 
  //      // Random reset occurences and durations
  //      if ($urandom_range(0, 1000) <  100) begin
  // 	  
  //      	 repeat($urandom_range(0, 10)) begin
  //      	   @(posedge `TB.clk);
  //      	 end
  //      	  
  //        `TB.rst = 1;
  //      
  //      	 repeat($urandom_range(0, 20)) begin
  //      	   @(posedge `TB.clk);
  //      	 end
  //      	  
  //        `TB.rst = 0;
  // 
  //      	 repeat($urandom_range(0, 20)) begin
  //      	   @(posedge `TB.clk);
  //      	 end
  // 
  //        tWR_GPO( START_WD | tmp_reg);
  // 	  
  //      end
  //      
  //   end
  // end
  
  initial begin
     
    `TB.clk = 0;
    
    forever begin
      `TB.clk = ~`TB.clk;
       #(T_CLK/2);
    end
     
  end

  initial begin
     
    `TB.rst = 1'b1;
     
    #(100ns);
    `TB.rst = 1'b0;
    
  end



  // // ================================================================
  // // AXI LITE WRITE 32 bit
  // // ================================================================
  // task automatic tAXI_LITE_W32(
  //     input logic [AXI_ADDR_W-1:0] addr,
  //     input logic [AXI_DATA_W-1:0] data,
  //     input logic [AXI_DATA_W/8-1:0] stb
  //   );
  // 
  //   int n_delay = 2;
  //   `TB.s00_axi_1_awaddr  <= addr;
  //   `TB.s00_axi_1_wdata   <= data;
  //   `TB.s00_axi_1_awvalid <= 1'b1;
  //   `TB.s00_axi_1_wvalid  <= 1'b1;
  // 
  //   `TB.s00_axi_1_wstrb   <= stb;    
  //   `TB.s00_axi_1_awprot  <= 'X;
  // 
  //   @(posedge `TB.aclk_0);
  //   while(!`TB.s00_axi_1_awready || !`TB.s00_axi_1_wready) @(posedge `TB.aclk_0);
  //   $display("%t, INFO: slave Address and wdata ready", $time);
  //   `TB.s00_axi_1_awvalid <= 1'b0;
  //   `TB.s00_axi_1_wvalid  <= 1'b0;    
  //   `TB.s00_axi_1_bready  <= 1'b1;
  //   
  //   while(!`TB.s00_axi_1_bvalid) @(posedge `TB.aclk_0);
  //   $display("%t, INFO: slave response valid", $time);
  //   `TB.s00_axi_1_bready <= 1'b0;
  //   
  // endtask  
  // 
  // // ================================================================
  // // AXI LITE READ 32 bit
  // // ================================================================
  // task automatic tAXI_LITE_R32(
  //    input  logic [AXI_ADDR_W-1:0] addr,
  //    output logic [AXI_ADDR_W-1:0] rdata
  //  );
  // 
  //   int n_delay = 2;
  //   `TB.s00_axi_1_araddr  <= addr;
  //   `TB.s00_axi_1_arvalid <= 1'b1;
  //   `TB.s00_axi_1_awprot  <= 'X;
  //   
  //   
  //   @(posedge `TB.aclk_0);
  //   while(!`TB.s00_axi_1_arready) @(posedge `TB.aclk_0);
  //   `TB.s00_axi_1_arvalid <= 1'b0;
  //   `TB.s00_axi_1_rready  <= 1'b1;
  //   
  //   while(!`TB.s00_axi_1_rvalid) @(posedge `TB.aclk_0);
  //   `TB.s00_axi_1_rready <= 1'b0;
  //   
  //   @(posedge `TB.aclk_0);
  //   rdata = `TB.s00_axi_1_rdata;    
  //   repeat(n_delay) @(posedge `TB.aclk_0);
  // 
  // endtask   
   
endmodule
