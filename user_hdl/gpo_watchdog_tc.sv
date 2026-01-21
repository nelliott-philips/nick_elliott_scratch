
`timescale 1 ns / 1 ps

module gpo_watchdog_tc();

  `define TB  gpo_watchdog_tb
  `define GPO gpo_register
  `define WD  gpo_watchdog

   localparam time T_CLK         = 10ns;
   localparam int  BASE2_CNT_IDX = 28;
   
   typedef logic [31:0] uint32_t;
   typedef enum int 
   {
     WD_START_STOP_IDX           = 0,
     APPEASE_IDX                 = 1,
     DISABLE_INTERRUPT_IDX       = 2,
     CLEAR_EARLY_WARN_INTRPT_IDX = 3,
     HAS_TIMED_OUT_IDX           = 4,
     WD_CNT_MSB                  = BASE2_CNT_IDX-1,
     WD_CNT_LSB                  = BASE2_CNT_IDX-4
   } wd_ctl_bits_t;
    
  
  // Register Write Masks 
  localparam	uint32_t START_WD                 = (32'd1        << WD_START_STOP_IDX);
  localparam	uint32_t APPEASE_WD               = (32'd1        << APPEASE_IDX);
  localparam	uint32_t CLEAR_EARLY_WARN_INTRPT  = (32'd1        << CLEAR_EARLY_WARN_INTRPT_IDX);
  localparam	uint32_t DISABLE_WD_INTRPT        = (32'd1        << DISABLE_INTERRUPT_IDX);
  localparam	uint32_t RD_TIMEOUT_CNT_MSK       = (32'h000_000F << WD_CNT_MSB);
  localparam	uint32_t RD_HAS_TIMED_OUT_MSK     = (32'h000_000F << HAS_TIMED_OUT_IDX);

  localparam	uint32_t TIMEOUT_INTV_3000ms      = {16'd3000, 16'd0};
  localparam	uint32_t TIMEOUT_INTV_2ms         = {   16'd2, 16'd0};

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

  task tINIT();
     @(posedge `TB.clk);
     `TB.clr_bit_mask = CLEAR_EARLY_WARN_INTRPT | APPEASE_WD;
  endtask

  task tSHORT_TIMEOUT_TEST();
    
    repeat(5) begin
      @(posedge `TB.clk);
    end 

    //tWR_GPO(START_WD | TIMEOUT_INTV_3000ms);
    tWR_GPO(START_WD | TIMEOUT_INTV_2ms);     
    //tWR_GPO(START_WD | DISABLE_WD_INTRPT);     
     
  endtask 

  task tRD_GPO();
  endtask // tRD_GPO

  initial begin

    @(negedge `TB.rst);

    tINIT();
    
    tSHORT_TIMEOUT_TEST();
     
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
     
    #(10us);
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
