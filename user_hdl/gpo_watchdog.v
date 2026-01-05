//----------------------------------------------------------------------------
// Module name: gpo_watchdog
// Author: Nicholas Elliott
// Description: general purpose output register driven watchdog
// ---------------------------------------------------------------------------

`timescale 1 ns / 1 ps

module gpo_watchdog #
(
  parameter integer  BASE2_CNT_IDX = 28
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
  localparam integer DISABLE_INTERRUPT_IDX    = 2;
  localparam integer CLEAR_EARLY_WARN_INT_IDX = 3;
  localparam integer HAS_TIMED_OUT_IDX        = 4;
  localparam integer ENABLE_VISIBLE_CNT_IDX   = 5;
   
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
       
      timeout_cnt       <= 1'b0;
      early_warn_intrpt <= 1'b0;
      has_timed_out     <= 1'b0;
      shutdown          <= 1'b0;

    end else begin
      
      case(wd_state)
	 
        WATCHDOG_STOPPED_S0: begin

          shutdown    <= 1'b0;
	  
	end

	WATCHDOG_RUNNING_S1: begin

          // Set default behavior
          shutdown    <= 1'b0;
          timeout_cnt <= timeout_cnt + 1'b1;


	  // Shutdown as timebase interval has lapsed
	  // This is a base2 counter for simplicity
          if (timeout_cnt[BASE2_CNT_IDX] == 1'b1) begin
          	 
            timeout_cnt   <= 32'd0;
            shutdown      <= 1'b1;
            has_timed_out <= 1'b1;
          	 
          end

          // Use the uppermost 4 bits minus 1 index to count to half of the interval
          // then hold the interrupt until cleared, this feature
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
  assign early_warn_intrpt_o = early_warn_intrpt && !gpo_reg_data_i[DISABLE_INTERRUPT_IDX];
  assign shutdown_o          = shutdown;

  // write whether watchdog has EVER timed out
  assign gpo_reg_data_o[HAS_TIMED_OUT_IDX] = has_timed_out;

  // A coarse count
  // assign gpo_reg_data_o[31:28]             = timeout_cnt[BASE2_CNT_IDX-1:BASE2_CNT_IDX-4];
  assign gpo_reg_data_o[31:28]             = 4'd0;

  // // Reserved register bits OR write registers bits
  // assign gpo_reg_data_o[27:3]              = gpo_reg_data_i[27:3];
  // assign gpo_reg_data_o[1:0]               = gpo_reg_data_i[1:0];

  // Reserved register bits OR write registers bits
  assign gpo_reg_data_o[27:0]              = gpo_reg_data_i[27:0];
  
   
endmodule

// typedef struct {
// } ctrl_reg;
   
   
  
// 31 - 4 TBR Read 0
// Timebase Register (Most significant 28 bits):
// This read-only field contains the most significant
// 28 bits of the timebase register. The timebase
// register is mirrored here so that a single read can
// be used to obtain the count value and the
// watchdog timer state if the upper 28 bits of the
// timebase provide sufficient timing resolution.
// 3 WRS Read/Write ’0’
// Watchdog Reset Status:
// Indicates the WDT reset signal was asserted. This
// bit is not cleared by a system reset so that it can
// be read after a system reset to determine if the
// reset was caused by a watchdog timeout.
// Writing a ’1’ to this bit clears the watchdog reset
// status bit. Writing a ’0’ to this bit has no effect.
// ’0’ = WDT reset has not occurred
// ’1’ = WDT reset has occurred
// 2 WDS Read/Write ’0’
// Watchdog Timer State:
// Indicates the WDT period has expired. The
// WDT_Reset signal will be asserted if the WDT
// period expires again before this bit is cleared by
// software.
// Writing a ’1’ to this bit clears the watchdog timer
// state.
// Writing a ’0’ to this bit has no effect.
// ’0’ = WDT period has not expired
// ’1’ = WDT period has expired, reset will occur on
// next expiration
// 1 EWDT1 Read/Write ’0’
// Enable Watchdog Timer (Enable 1):
// This bit must be used in conjunction with the
// EWDT2 bit in the TWCSR1 register. Both bits must
// be 0 to disable the WDT.
// ’0’ = Disable WDT function if EWDT2 also equals
// ’0’
// ’1’ = Enable WDT function
// 0 EWDT2 Read ’0’
// Enable Watchdog Timer (Enable 2):
// This bit is read only and is the only place to read
// back a value written to bit 31 of TWCSR1.
