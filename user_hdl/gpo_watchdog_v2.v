//----------------------------------------------------------------------------
// Module name: gpo_watchdog
// Author: Nicholas Elliott
// Description: general purpose output register driven watchdog
// ---------------------------------------------------------------------------

`timescale 1 ns / 1 ps

module gpo_watchdog_v2 #
(
  parameter integer  MS_TIMEBASE_MAX_PARAM = 100_000
)
(
  input wire	     clk,
  input wire	     rst,
  input wire [31:0]  gpo_reg_data_i,
  input wire  [31:0] gpo_reg_data_stb_i, 
  output wire [31:0] gpo_reg_data_o,
  output wire [31:0] gpo_clear_msk_o,
  output wire	     early_warn_intrpt_o,
  output wire	     shutdown_o
);

  // Construct millisecond timebase
  // 100_000 ticks of 10ns @100MHz to get 1ms
  localparam integer MS_TIMEBASE_MAX = MS_TIMEBASE_MAX_PARAM;   
  localparam integer MS_TIMEBASE_MSB = ($clog2(MS_TIMEBASE_MAX) - 1);
   
  // GPO Register bit indices, these can be changed to adjust which
  // bit gets set in the ctrl register for the watchdog
  localparam integer WD_START_STOP_IDX        = 0;
  localparam integer APPEASE_IDX              = 1;
  localparam integer ENABLE_INTERRUPT_IDX     = 2;
  localparam integer CLEAR_EARLY_WARN_INT_IDX = 3;
  localparam integer HAS_TIMED_OUT_IDX        = 4;
  localparam integer IS_IN_SHUTDOWN_IDX       = 5;
  localparam integer FORCE_SHUTDOWN_IDX       = 6;
  localparam integer EARLY_WARN_POLL_IDX      = 7; 
   
  localparam [0:0]     WATCHDOG_STOPPED_S0      = 1'b0;
  localparam [0:0]     WATCHDOG_RUNNING_S1      = 1'b1;

  // TODO, NE, Consider revising, not sure if this is a hack or a good implementation
  // but given that this module and the gpo reg are instantiated in schematic view, might be the best approach
  // This mask basically implements pulse registers using constant mask values, pulse interrupt clear adn appease

  // This self clearing strobe is kind of ugly, TODO NE, consider revising
  localparam [31:0] GPO_CLEAR_MSK           = ( (32'd1 << APPEASE_IDX) | (32'd1 << CLEAR_EARLY_WARN_INT_IDX) );
   
  // assign gpo_clear_msk_o[31:5]              = GPO_CLEAR_MSK[31:5];
  // assign gpo_clear_msk_o[HAS_TIMED_OUT_IDX] = gpo_reg_data_stb_i[HAS_TIMED_OUT_IDX];
  // assign gpo_clear_msk_o[3:0]               = GPO_CLEAR_MSK[3:0];

  assign gpo_clear_msk_o                       = GPO_CLEAR_MSK;
   
  // 2^X * Tclk timebase interval
  reg                     wd_state          = 1'b0;
  reg   [15:0]            timeout_cnt_ms    = 'd0;
  reg  		          has_timed_out     = 'd0;
  reg  		          shutdown          = 'd0;
  reg  		          early_warn_intrpt = 'd0;

  reg			  clk_en            = 1'b0;
  reg [MS_TIMEBASE_MSB:0] clk_en_cnt        = 'd0;
  reg			  appease_clk_en_latch = 1'b0;
   

   
  // Construct clk_en
  always @(posedge clk) begin
    if (rst) begin
       
      clk_en     <= 1'b0;
      clk_en_cnt <= 'd0;
       
    end else begin
       
      clk_en     <= 1'b0;
      clk_en_cnt <= clk_en_cnt + 1'b1;

      if (clk_en_cnt == MS_TIMEBASE_MAX-1) begin
	 
        clk_en_cnt <= 'd0;
	clk_en     <= 1'b1;
	 
      end
       
    end
  end

  //    
  always @(posedge clk) begin
    if (rst) begin
        wd_state <= WATCHDOG_STOPPED_S0;      
    end else begin
       
      if (gpo_reg_data_i[WD_START_STOP_IDX] == 1'b0) begin
        wd_state <= WATCHDOG_STOPPED_S0;
      end else begin
        wd_state <= WATCHDOG_RUNNING_S1;
      end
       
    end
  end // always @ (posedge clk)

   
  always @(posedge clk) begin
    if (rst) begin
       
      timeout_cnt_ms       <= 16'd0;
      early_warn_intrpt    <= 1'b0;
      has_timed_out        <= 1'b0;
      shutdown             <= 1'b0;
      appease_clk_en_latch <= 1'b0;

    end else begin
       
      // Hold appease until it is applied in the clk_en domain
      if (gpo_reg_data_i[APPEASE_IDX] == 1'b1) begin
        appease_clk_en_latch <= 1'b1;
      end
            
      // Write 1 to clear implementation, TODO, NE consider revising
      // if (gpo_reg_data_stb_i[HAS_TIMED_OUT_IDX] == 1'b1 && has_timed_out == 1'b1) begin
      //   has_timed_out <= 1'b0;
      // end
       
      // 1ms timebase
      if (clk_en) begin

        case(wd_state)
        	 
          WATCHDOG_STOPPED_S0: begin
        
            timeout_cnt_ms       <= 16'd0;
            early_warn_intrpt    <= 1'b0;
            has_timed_out        <= 1'b0;
            shutdown             <= 1'b0;
	    appease_clk_en_latch <= 1'b0;
        	  
          end
        
          WATCHDOG_RUNNING_S1: begin
        
            // Set default behavior
            timeout_cnt_ms <= timeout_cnt_ms + 1'b1;

	    // If target timeout interval is reached or exceeded, then shutdown and mark timeout
            if (timeout_cnt_ms >= gpo_reg_data_i[31:16] ) begin
              timeout_cnt_ms   <= timeout_cnt_ms;
              shutdown         <= 1'b1;
              has_timed_out    <= 1'b1;
            	 
            end

            // coarse half way comparison for early warning timeout, basically divide target count by 2
            if (timeout_cnt_ms == {1'b0, gpo_reg_data_i[31:17]} ) begin
	       
              early_warn_intrpt <= 1'b1;
	       
            end
        
            // Appease watchdog by clearing count
            //if (gpo_reg_data_i[APPEASE_IDX] == 1'b1) begin
            if (appease_clk_en_latch == 1'b1) begin	       
	       
              timeout_cnt_ms       <= 16'd0;
              early_warn_intrpt    <= 1'b0;
	      shutdown             <= 1'b0;
	      appease_clk_en_latch <= 1'b0;
	       
            end

	  end // case: WATCHDOG_RUNNING_S1

               
        endcase // case (wd_state)
      end // if (clk_en)
    end // else: !if(rst)
  end // always @ (posedge clk)
   

  // Only send out interrupt if it is NOT disabled by SW
  assign early_warn_intrpt_o                      = early_warn_intrpt && gpo_reg_data_i[ENABLE_INTERRUPT_IDX];
   
  // Drive Revo power low		                         
  assign shutdown_o                               = shutdown | gpo_reg_data_i[FORCE_SHUTDOWN_IDX];
   
  // Show written count value                    
  assign gpo_reg_data_o[31:16]                    = gpo_reg_data_i[31:16];

  // Reserved register bits OR write registers bits
  assign gpo_reg_data_o[31:16]                    = gpo_reg_data_i[31:16];

  // Unused/reserved bits
  assign gpo_reg_data_o[15:8]                     = 'd0;

  // WD running status
  assign gpo_reg_data_o[WD_START_STOP_IDX]        = gpo_reg_data_i[WD_START_STOP_IDX];

  // Write only, self clearing using fed back 'GPO_CLEAR_MSK'
  assign gpo_reg_data_o[APPEASE_IDX]              = 'd0;

  // pass through interrupt enable status
  assign gpo_reg_data_o[ENABLE_INTERRUPT_IDX]     = gpo_reg_data_i[ENABLE_INTERRUPT_IDX];

  // write only
  assign gpo_reg_data_o[CLEAR_EARLY_WARN_INT_IDX] = 'd0;
   
  // write 1 to clear implementation, see logic above
  assign gpo_reg_data_o[HAS_TIMED_OUT_IDX]        = has_timed_out;

  // Make 'is_in_shutdown' a readable status bit
  assign gpo_reg_data_o[IS_IN_SHUTDOWN_IDX]       = shutdown;

  assign gpo_reg_data_o[FORCE_SHUTDOWN_IDX]       = gpo_reg_data_i[FORCE_SHUTDOWN_IDX];
   
  // pass through early warn interrupt for polling   
  assign gpo_reg_data_o[EARLY_WARN_POLL_IDX]      = early_warn_intrpt && gpo_reg_data_i[ENABLE_INTERRUPT_IDX];
   
   
endmodule

