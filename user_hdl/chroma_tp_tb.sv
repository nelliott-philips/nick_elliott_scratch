`timescale 1ns / 1ps

module chroma_tp_tb();

  logic         clk;
  logic         rst;
  logic [31:0]  gpo_reg_in;
  logic [31:0]	gpo_reg_out;
  logic	        data_tvalid;
  logic [31:0]	data_tdata;
  logic	        data_tlast;
   
   
  chroma_tp ch_tp0(
    .clk          (clk),
    .rst          (rst),
    .gpo_reg_in   (gpo_reg_in),
    .gpo_reg_out  (gpo_reg_out),
    .data_tvalid  (data_tvalid),
    .data_tdata   (data_tdata),
    .data_tlast	  (data_tlast)	   
  );


  initial begin
     clk = 0;

     forever begin #20; clk = ~clk; end
     
  end

  initial begin
     rst = 0;

     #200;
     rst = 1;

     #200;
     rst = 0;
  end
     
   
endmodule
