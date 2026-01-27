//----------------------------------------------------------------------------
// Module name: gpo_watchdog
// Author: Nicholas Elliott
// Description: general purpose output register driven watchdog
// ---------------------------------------------------------------------------

`timescale 1 ns / 1 ps

module gpo_watchdog #
(
  parameter integer  BASE2_CNT_IDX = 28 // (2^28)*10ns (@100Mhz) = 2.684 sec
)
(
  input wire	     clk,
  input wire	     rst,
  input wire  [31:0] gpo_reg_data_i,
  output wire [31:0] gpo_reg_data_o,
  output wire [31:0] gpo_clear_msk_o,
  output wire	     early_warn_intrpt_o,
  output wire	     shutdown_o
);

  // GPO Register Bit indices, these can be changed to adjust which
  // bit gets set in the ctrl register for the watchdog
  localparam integer WD_START_STOP_IDX        = 0;
  localparam integer APPEASE_IDX              = 1;
  localparam integer ENABLE_INTERRUPT_IDX     = 2;
  localparam integer CLEAR_EARLY_WARN_INT_IDX = 3;
  localparam integer HAS_TIMED_OUT_IDX        = 4;
  localparam integer ENABLE_VISIBLE_CNT_IDX   = 5;
  localparam integer IS_IN_SHUTDOWN_IDX       = 5;
  localparam integer FORCE_SHUTDOWN_IDX       = 6;
  localparam integer EARLY_WARN_POLL_IDX      = 7; 
   
  localparam reg     WATCHDOG_STOPPED_S0      = 1'b0;
  localparam reg     WATCHDOG_RUNNING_S1      = 1'b1;

  // TODO, NE, Consider revising, not sure if this is a hack or a good implementation
  // but given that this module and the gpo reg are instantiated in schematic view, might be the best approach
  // This mask basically implements pulse registers using constant mask values, pulse interrupt clear adn appease
  localparam [31:0] GPO_CLEAR_MSK  = ( (32'd1 << APPEASE_IDX) | (32'd1 << CLEAR_EARLY_WARN_INT_IDX ) );
  assign gpo_clear_msk_o           = GPO_CLEAR_MSK;
   
  // 2^X * Tclk timebase interval
  reg                     wd_state          = 1'b0;
  reg   [BASE2_CNT_IDX:0] timeout_cnt       = 'd0;
  //reg              [31:0] timeout_cnt       = 'd0;   
  reg  		          timed_out         = 'd0;
  reg  		          has_timed_out     = 'd0;
  reg  		          shutdown          = 'd0;
  reg  		          early_warn_intrpt = 'd0;

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
  end
   
  always @(posedge clk) begin
    if (rst) begin
       
      timeout_cnt       <= 32'd0;
      early_warn_intrpt <= 1'b0;
      has_timed_out     <= 1'b0;
      shutdown          <= 1'b0;

    end else begin
      
      case(wd_state)
	 
        WATCHDOG_STOPPED_S0: begin

          timeout_cnt       <= 32'd0;
          early_warn_intrpt <= 1'b0;
          has_timed_out     <= 1'b0;
          shutdown          <= 1'b0;
	  
	end

	WATCHDOG_RUNNING_S1: begin

          // Set default behavior
          shutdown    <= 1'b0;
          timeout_cnt <= timeout_cnt + 1'b1;

	  // Shutdown as timebase interval has lapsed
	  // This is a base2 counter for simplicity
          if (timeout_cnt[BASE2_CNT_IDX] == 1'b1) begin

            // Freeze timeout count until reset, appease, or watchdog_stop          	 
            timeout_cnt   <= timeout_cnt;
            shutdown      <= 1'b1;
            has_timed_out <= 1'b1;
          	 
          end

          // Use the uppermost 4 bits minus 1 index to count to half of the interval
          // then hold the interrupt until cleared
          if (timeout_cnt[BASE2_CNT_IDX-1:BASE2_CNT_IDX-4] == 4'b1000) begin
	     
            early_warn_intrpt <= 1'b1;

          end

          // Appease watchdog by clearing count
	  if (gpo_reg_data_i[APPEASE_IDX] == 1'b1) begin
	    timeout_cnt       <= 32'd0;
	    early_warn_intrpt <= 1'b0;
	  end
	   
	end
	
      endcase

    end
  end 

  // Only send out interrupt if it is NOT disabled by SW
  assign early_warn_intrpt_o                        = early_warn_intrpt && gpo_reg_data_i[ENABLE_INTERRUPT_IDX];
					            
  // Drive Revo power low   		            
  assign shutdown_o                                 = shutdown;
					            
  assign gpo_reg_data_o[31:16]                      = gpo_reg_data_i[31:16];
					            
  // Unused/reserved bits		            			      
  assign gpo_reg_data_o[15:8]                       = 'd0;
					            
  // WD running status			            		      
  assign gpo_reg_data_o[WD_START_STOP_IDX]          = gpo_reg_data_i[WD_START_STOP_IDX];
					            
  // Write only, self clearing using fed back 'GPO_CLEAR_MSK'					      
  assign gpo_reg_data_o[APPEASE_IDX]                = 1'b0;
					            
  // pass through interrupt enable status           
  assign gpo_reg_data_o[ENABLE_INTERRUPT_IDX]       = gpo_reg_data_i[ENABLE_INTERRUPT_IDX];
  					            
  // write whether watchdog has EVER timed out      
  assign gpo_reg_data_o[HAS_TIMED_OUT_IDX]          = has_timed_out;
					            
  // Make 'is_in_shutdown' a readable status bit   
  assign gpo_reg_data_o[IS_IN_SHUTDOWN_IDX]         = shutdown | gpo_reg_data_i[FORCE_SHUTDOWN_IDX];
					            
  assign gpo_reg_data_o[FORCE_SHUTDOWN_IDX]         = gpo_reg_data_i[FORCE_SHUTDOWN_IDX];

  // pass through early warn interrupt for polling   
  assign gpo_reg_data_o[CLEAR_EARLY_WARN_INT_IDX]   = early_warn_intrpt && gpo_reg_data_i[ENABLE_INTERRUPT_IDX];
  
   
endmodule

