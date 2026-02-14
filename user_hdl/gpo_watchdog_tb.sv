

`timescale 1 ns / 1 ps
`default_nettype none

module gpo_watchdog_tb();




   logic	clk;
   logic	rst;
   logic [31:0] clr_bit_mask;
   logic [31:0] clr_bit_mask_wire;   
   logic        wr_strobe;
   logic [31:0] datain;
   logic [31:0] dataout;
   logic [31:0] strbout;
   
   logic [31:0] gpo_reg_data_out;
   logic	early_warn_intrpt;
   logic	shutdown;


   

   typedef logic [31:0]	uint32_t;
   
   // 100e-9*(2^25) = 3.355sec
   localparam	uint32_t SIMPLE_TIMEOUT_3p355sec       = {32'd1 << 25};
   
    
   // 100e-9*(2^24) = 1.677sec
   localparam	uint32_t SIMPLE_TIMEOUT_1p677sec       = {32'd1 << 24};
   
   // 100e-9*(2^17) = 0.013sec = 13ms
   localparam	uint32_t SIMPLE_TIMEOUT_13ms           = {32'd1 << 17};
   
   localparam   integer SIMPLE_10p4ms                  = 20;
   localparam   integer USE_CHROMA_PATH                = 1;   
   
   // gpo_register gpo_reg_dut (
   //   .clk           (clk),
   //   .reset         (rst),
   //   .clr_bit_mask  (clr_bit_mask),
   //   .wr_strobe     (wr_strobe),
   //   .datain        (datain),
   //   .dataout       (dataout),
   //   .strbout       (strbout)
   // );
   // 
   // gpo_watchdog #(
   //   .BASE2_CNT_IDX         (8)
   // )gpo_wd_dut(
   //   .clk                   (clk),
   //   .rst                   (rst),
   //   .gpo_reg_data_i        (dataout),
   //   .gpo_reg_data_o        (gpo_reg_data_out), 
   //   .early_warn_intrpt_o   (early_warn_intrpt),
   //   .shutdown_o            (shutdown)
   // );

   gpo_register gpo_reg_dut (
     .clk           (clk),
     .reset         (rst),
     .clr_bit_mask  (clr_bit_mask_wire),
     .wr_strobe     (wr_strobe),
     .datain        (datain),
     .dataout       (dataout),
     .strbout       (strbout)
   );
   
   gpo_watchdog #(
     .BASE2_CNT_IDX         (SIMPLE_10p4ms)
   )gpo_wd_dut(
     .clk                   (clk),
     .rst                   (rst),
     .gpo_reg_data_i        (dataout),
     .gpo_reg_data_o        (gpo_reg_data_out),
     .gpo_clear_msk_o       (clr_bit_mask_wire),
     .early_warn_intrpt_o   (early_warn_intrpt),
     .shutdown_o            (shutdown)
   );


   logic        chroma_wr_strobe;
   logic [31:0]	chroma_gpo_in;
   logic [31:0]	chroma_gpo_out;
   logic [31:0]	chroma_gpo_data_readback;
   logic [11:0]	band_pass_filter_data;
   logic [15:0]	motion_filter_data;
   
   generate
     if(USE_CHROMA_PATH == 1) begin

       
       gpo_register gpo_reg_chroma_path_dut (
         .clk           (clk),
         .reset         (rst),
         .clr_bit_mask  ('d0),
         .wr_strobe     (chroma_wr_strobe),
         .datain        (chroma_gpo_in),
         .dataout       (chroma_gpo_out),
         .strbout       ()
       );

       gpo_chroma_data_ctl chroma_dut(
         .clk                    (clk),
         .rst                    (rst),
         .gpo_data_i             (chroma_gpo_out),
         .motion_filter_data     (motion_filter_data),
         .band_pass_filter_data  (band_pass_filter_data),
         .gpo_data_o             (chroma_gpo_data_readback)
       );
	
     end
   endgenerate

   // gpo_watchdog_v2 gpo_wd_dut(
   //   .clk                   (clk),
   //   .rst                   (rst),
   //   .gpo_reg_data_i        (dataout),
   //   //.gpo_reg_data_stb_i    (strbout), 			      
   //   .gpo_reg_data_o        (gpo_reg_data_out),
   //   .gpo_clear_msk_o       (clr_bit_mask_wire), 
   //   .early_warn_intrpt_o   (early_warn_intrpt),
   //   .shutdown_o            (shutdown)
   // );
   

endmodule
   
