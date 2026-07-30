// xc7a200tfbg484-1


`timescale 1ns / 1ps

module chroma_tp(
    input  wire         clk,
    input  wire         rst,
    input  wire  [31:0] gpo_reg_in,
    output logic [31:0] gpo_reg_out,
    output logic        data_tvalid,
    output logic [31:0] data_tdata,
    output logic        data_tlast
  );

  localparam real CLOCK_FREQ          = 100.0e6;
  localparam real DESIRED_FREQ        = 20.0e6;
  //localparam real FTW_FP       = $floor((DESIRED_FREQ * 2.0**32)/CLOCK_FREQ);
  localparam real FTW_FP              = (DESIRED_FREQ/CLOCK_FREQ)*(2.0**32 + 0.5) ;
  localparam logic [31:0] FTW_LOGIC   = $rtoi(FTW_FP);
   

  initial begin: compile_time_check_initial
     $display("CLOCK_FREQ: %d",   CLOCK_FREQ);
     $display("DESIRED_FREQ: %d", DESIRED_FREQ);
     $display("FTW_FP: %d",       FTW_FP);
     $display("FTW_LOGIC: %d",    FTW_LOGIC);
     $display("FTW_LOGIC: %b",    FTW_LOGIC);
  end
   

  // Inputs
  logic        s_axis_phase_tvalid;
  logic [63:0] s_axis_phase_tdata;
  logic        s_axis_phase_tlast;

  // Outputs
  logic        m_axis_data_tvalid;
  logic [31:0] m_axis_data_tdata;
  logic        m_axis_data_tlast;
  
  logic        m_axis_phase_tvalid;
  logic [31:0] m_axis_phase_tdata;   
  logic        m_axis_phase_tlast;

  logic signed [11:0] sine;
  logic signed [11:0] cosine;
  logic signed [11:0] a_scale;
  logic signed [23:0] sine_scaled;
  logic signed [23:0] cosine_scaled;
  logic               sine_scaled_valid;
  logic               cosine_scaled_valid;
   
   
 

  assign data_tvalid = m_axis_phase_tvalid;
  assign data_tdata  = m_axis_phase_tdata; 
  assign data_tlast  = m_axis_phase_tlast;
  assign sine        = m_axis_data_tdata[11:0];
  assign cosine      = m_axis_data_tdata[27:16];
   

  always_ff @(posedge clk) begin
     if (rst == 1'b1) begin
	s_axis_phase_tlast  <= 1'b0;
	s_axis_phase_tdata  <= 'd0;
	s_axis_phase_tvalid <= 'd0;
	
     end else begin
	s_axis_phase_tlast  <= 1'b0;
	s_axis_phase_tdata  <= FTW_LOGIC;
	s_axis_phase_tvalid <= 1'b1;
     end
  end

  //----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
  dds_compiler_0 dds0 (
    .aclk                  (clk),                  // input wire aclk
    .s_axis_phase_tvalid   (s_axis_phase_tvalid),  // input wire s_axis_phase_tvalid
    .s_axis_phase_tdata    (s_axis_phase_tdata),   // input wire [63 : 0] s_axis_phase_tdata
    .s_axis_phase_tlast    (s_axis_phase_tlast),   // input wire s_axis_phase_tlast
    .m_axis_data_tvalid    (m_axis_data_tvalid),   // output wire m_axis_data_tvalid
    .m_axis_data_tdata     (m_axis_data_tdata),    // output wire [31 : 0] m_axis_data_tdata
    .m_axis_data_tlast     (m_axis_data_tlast),    // output wire m_axis_data_tlast
    .m_axis_phase_tvalid   (m_axis_phase_tvalid),  // output wire m_axis_phase_tvalid
    .m_axis_phase_tdata    (m_axis_phase_tdata),   // output wire [31 : 0] m_axis_phase_tdata
    .m_axis_phase_tlast    (m_axis_phase_tlast)    // output wire m_axis_phase_tlast
  );
  // INST_TAG_END ------ End INSTANTIATION Template ---------

  // Multiply block
  always @(posedge clk) begin
    sine_scaled         <= a_scale*sine;
    cosine_scaled       <= a_scale*cosine;
    sine_scaled_valid   <= m_axis_data_tvalid;
    cosine_scaled_valid <= m_axis_data_tvalid;
  end

  // !!! The message below is stale or 'misinformed' pathing
  // You must compile the wrapper file dds_compiler_0.v when simulating
  // the core, dds_compiler_0. When compiling the wrapper file, be sure to
  // reference the Verilog simulation library.


endmodule // chroma_tp


// ;# Filename: chroma_test_gain.coe  
// 100.0,                                 1 
// 100.0,				  2 
// 100.0,				  3 
// 100.0,				  4 
// 100.0,				  5 
// 102.7,				  6 
// 102.7,				  7 
// 102.7,				  8 
// 102.7,				  9 
// 102.7,				 10 
// 105.4,				 11 
// 105.4,				 12 
// 105.4,				 13 
// 105.4,				 14 
// 105.4,				 15 
// 108.2,				 16 
// 108.2,				 17 
// 108.2,				 18 
// 108.2,				 19 
// 108.2,				 20 
// 110.9,				 21 
// 110.9,				 22 
// 110.9,				 23 
// 110.9,				 24 
// 110.9,				 25 
// 113.6,				 26 
// 113.6,				 27 
// 113.6,				 28 
// 113.6,				 29 
// 113.6,				 30 
// 116.3,				 31 
// 116.3,				 32 
// 116.3,				 33 
// 116.3,				 34 
// 116.3,				 35 
// 119.0,				 36 
// 119.0,				 37 
// 119.0,				 38 
// 119.0,				 39 
// 119.0,				 40 
// 121.7,				 41 
// 121.7,				 42 
// 121.7,				 43 
// 121.7,				 44 
// 121.7,				 45 
// 124.5,				 46 
// 124.5,				 47 
// 124.5,				 48 
// 124.5,				 49 
// 124.5,				 50 
// 127.2,				 51 
// 127.2,				 52 
// 127.2,				 53 
// 127.2,				 54 
// 127.2,				 55 
// 129.9,				 56 
// 129.9,				 57 
// 129.9,				 58 
// 129.9,				 59 
// 129.9,				 60 
// 132.6,				 61 
// 132.6,				 62 
// 132.6,				 63 
// 132.6,				 64 
// 132.6,				 65 
// 135.3,				 66 
// 135.3,				 67 
// 135.3,				 68 
// 135.3,				 69 
// 135.3,				 70 
// 138.0,				 71 
// 138.0,				 72 
// 138.0,				 73 
// 138.0,				 74 
// 138.0,				 75 
// 140.8,				 76 
// 140.8,				 77 
// 140.8,				 78 
// 140.8,				 79 
// 140.8,				 80 
// 143.5,				 81 
// 143.5,				 82 
// 143.5,				 83 
// 143.5,				 84 
// 143.5,				 85 
// 146.2,				 86 
// 146.2,				 87 
// 146.2,				 88 
// 146.2,				 89 
// 146.2,				 90 
// 148.9,				 91 
// 148.9,				 92 
// 148.9,				 93 
// 148.9,				 94 
// 148.9,				 95 
// 151.6,				 96 
// 151.6,				 97 
// 151.6,				 98 
// 151.6,				 99 
// 151.6,				100 
// 154.3,				101 
// 154.3,				102 
// 154.3,				103 
// 154.3,				104 
// 154.3,				105 
// 157.1,				106 
// 157.1,				107 
// 157.1,				108 
// 157.1,				109 
// 157.1,				110 
// 159.8,				111 
// 159.8,				112 
// 159.8,				113 
// 159.8,				114 
// 159.8,				115 
// 162.5,				116 
// 162.5,				117 
// 162.5,				118 
// 162.5,				119 
// 162.5,				120 
// 165.2,				121 
// 165.2,				122 
// 165.2,				123 
// 165.2,				124 
// 165.2,				125 
// 167.9,				126 
// 167.9,				127 
// 167.9,				128 
// 167.9,				129 
// 167.9,				130 
// 170.7,				131 
// 170.7,				132 
// 170.7,				133 
// 170.7,				134 
// 170.7,				135 
// 173.4,				136 
// 173.4,				137 
// 173.4,				138 
// 173.4,				139 
// 173.4,				140 
// 176.1,				141 
// 176.1,				142 
// 176.1,				143 
// 176.1,				144 
// 176.1,				145 
// 178.8,				146 
// 178.8,				147 
// 178.8,				148 
// 178.8,				149 
// 178.8,				150 
// 181.5,				151 
// 181.5,				152 
// 181.5,				153 
// 181.5,				154 
// 181.5,				155 
// 184.2,				156 
// 184.2,				157 
// 184.2,				158 
// 184.2,				159 
// 184.2,				160 
// 187.0,				161 
// 187.0,				162 
// 187.0,				163 
// 187.0,				164 
// 187.0,				165 
// 189.7,				166 
// 189.7,				167 
// 189.7,				168 
// 189.7,				169 
// 189.7,				170 
// 192.4,				171 
// 192.4,				172 
// 192.4,				173 
// 192.4,				174 
// 192.4,				175 
// 195.1,				176 
// 195.1,				177 
// 195.1,				178 
// 195.1,				179 
// 195.1,				180 
// 197.8,				181 
// 197.8,				182 
// 197.8,				183 
// 197.8;                               184                         
