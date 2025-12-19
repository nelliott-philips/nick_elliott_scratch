//----------------------------------------------------------------------------
// Volcano Corp. Confidential
// Copyright, 2012, Volcano Corp.
//
// Module name: gpo_register
// Author: Sidney Rhodes, Blue Forest Labs LLC
// Description: general purpose output register module
// ---------------------------------------------------------------------------
`timescale 1 ns / 1 ps

module gpo_register
(
   clk,
   reset,
   clr_bit_mask,

   wr_strobe,

   datain,
   dataout,
   strbout
);

   parameter RESET_VALUE = 32'h0000_0000;   // default parameterized reset value of register


   // port declarations
   input clk;
   input reset;
   input [31:0] clr_bit_mask;

   input wr_strobe;

   input [31:0] datain;
   output [31:0] dataout;  // static output
   output [31:0] strbout;  // strobed output

   // wire and reg declarations
   wire clk;
   wire reset;

   wire wr_strobe;

   wire [31:0] datain;
   reg [31:0] dataout;
   reg [31:0] strbout;

   always @(posedge clk)
   begin
      if(reset)
      begin
	 dataout <= RESET_VALUE;
      end
      else if(wr_strobe)
      begin
	 dataout <= datain;
      end
      else
      begin
	 dataout <= dataout & ~clr_bit_mask;
      end
   end

   always @(posedge clk)
   begin
      if(reset)
      begin
	 strbout <= 32'b0;
      end
      else if(wr_strobe)
      begin
	 strbout <= datain;
      end
      else
      begin
	 strbout <= 32'b0;
      end
   end

endmodule

