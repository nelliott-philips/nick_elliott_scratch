// xc7a200tfbg484-1


`timescale 1ns / 1ps

module chroma_tp #(
    parameter integer SIM_DEBUG_ON = 1,
    parameter integer HW_DEBUG_ON = 0		   
  )(
    input wire		clk,
    input wire		rst,
    input wire		framesync,
    input wire		acq_gate,
    input wire		frame_a,
    input wire		cf_enable,
    input wire          test_pattern_en,
    input wire [31:0]	gpo_reg_in,
    output logic [31:0]	gpo_reg_out,
    output logic	data_tvalid,
    output logic [31:0]	data_tdata,
    output logic	data_tlast
  );

  localparam real CLOCK_FREQ          = 100.0e6;
  localparam real DESIRED_FREQ        = 20.0e6;
  //localparam real FTW_FP       = $floor((DESIRED_FREQ * 2.0**32)/CLOCK_FREQ);
  localparam real FTW_FP              = (DESIRED_FREQ/CLOCK_FREQ)*(2.0**32 + 0.5);
  localparam logic [31:0] FTW_LOGIC   = $rtoi(FTW_FP);
   

  initial begin: compile_time_check_initial
     $display("CLOCK_FREQ: %d",   CLOCK_FREQ);
     $display("DESIRED_FREQ: %d", DESIRED_FREQ);
     $display("FTW_FP: %d",       FTW_FP);
     $display("FTW_LOGIC: %d",    FTW_LOGIC);
     $display("FTW_LOGIC: %b",    FTW_LOGIC);
  end

  localparam integer N_GAIN_CNT = 184;
  localparam integer TP_GAIN_CNT_WIDTH = $clog2(N_GAIN_CNT);
  logic [TP_GAIN_CNT_WIDTH-1:0] tp_gain_cnt;

  /*
  logic [11:0] tp_arr[N_GAIN_CNT] = {
    400,400,400,400,400,
    41C,41C,41C,41C,41C,
    437,437,437,437,437,
    454,454,454,454,454,
    470,470,470,470,470,
    48B,48B,48B,48B,48B,
    4A7,4A7,4A7,4A7,4A7,
    4C3,4C3,4C3,4C3,4C3,
    4DE,4DE,4DE,4DE,4DE,
    4FB,4FB,4FB,4FB,4FB,
    517,517,517,517,517,
    532,532,532,532,532,
    54E,54E,54E,54E,54E,
    569,569,569,569,569,
    585,585,585,585,585,
    5A2,5A2,5A2,5A2,5A2,
    5BD,5BD,5BD,5BD,5BD,
    5D9,5D9,5D9,5D9,5D9,
    5F5,5F5,5F5,5F5,5F5,
    610,610,610,610,610,
    62C,62C,62C,62C,62C,
    649,649,649,649,649,
    664,664,664,664,664,
    680,680,680,680,680,
    69C,69C,69C,69C,69C,
    6B7,6B7,6B7,6B7,6B7,
    6D4,6D4,6D4,6D4,6D4,
    6F0,6F0,6F0,6F0,6F0,
    70B,70B,70B,70B,70B,
    727,727,727,727,727,
    743,743,743,743,743,
    75E,75E,75E,75E,75E,
    77B,77B,77B,77B,77B,
    797,797,797,797,797,
    7B2,7B2,7B2,7B2,7B2,
    7CE,7CE,7CE,7CE,7CE,
    7E9,7E9,7E9,7E9
  };
  
  */
  
  logic [11:0] tp_arr[N_GAIN_CNT] = '{
    'h7E9,'h7E9,'h7E9,'h7E9,
    'h7CE,'h7CE,'h7CE,'h7CE,'h7CE,
    'h7B2,'h7B2,'h7B2,'h7B2,'h7B2,
    'h797,'h797,'h797,'h797,'h797,
    'h77B,'h77B,'h77B,'h77B,'h77B,
    'h75E,'h75E,'h75E,'h75E,'h75E,
    'h743,'h743,'h743,'h743,'h743,
    'h727,'h727,'h727,'h727,'h727,
    'h70B,'h70B,'h70B,'h70B,'h70B,
    'h6F0,'h6F0,'h6F0,'h6F0,'h6F0,
    'h6D4,'h6D4,'h6D4,'h6D4,'h6D4,
    'h6B7,'h6B7,'h6B7,'h6B7,'h6B7,
    'h69C,'h69C,'h69C,'h69C,'h69C,
    'h680,'h680,'h680,'h680,'h680,
    'h664,'h664,'h664,'h664,'h664,
    'h649,'h649,'h649,'h649,'h649,
    'h62C,'h62C,'h62C,'h62C,'h62C,
    'h610,'h610,'h610,'h610,'h610,
    'h5F5,'h5F5,'h5F5,'h5F5,'h5F5,
    'h5D9,'h5D9,'h5D9,'h5D9,'h5D9,
    'h5BD,'h5BD,'h5BD,'h5BD,'h5BD,
    'h5A2,'h5A2,'h5A2,'h5A2,'h5A2,
    'h585,'h585,'h585,'h585,'h585,
    'h569,'h569,'h569,'h569,'h569,
    'h54E,'h54E,'h54E,'h54E,'h54E,
    'h532,'h532,'h532,'h532,'h532,
    'h517,'h517,'h517,'h517,'h517,
    'h4FB,'h4FB,'h4FB,'h4FB,'h4FB,
    'h4DE,'h4DE,'h4DE,'h4DE,'h4DE,
    'h4C3,'h4C3,'h4C3,'h4C3,'h4C3,
    'h4A7,'h4A7,'h4A7,'h4A7,'h4A7,
    'h48B,'h48B,'h48B,'h48B,'h48B,
    'h470,'h470,'h470,'h470,'h470,
    'h454,'h454,'h454,'h454,'h454,
    'h437,'h437,'h437,'h437,'h437,
    'h41C,'h41C,'h41C,'h41C,'h41C,
    'h400,'h400,'h400,'h400,'h400
  };
   

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
  logic signed [11:0] a_scale = 12'd516;
  logic               sine_scaled_valid;
  logic               cosine_scaled_valid;

   
  assign data_tvalid = m_axis_phase_tvalid;
  assign data_tdata  = m_axis_phase_tdata; 
  assign data_tlast  = m_axis_phase_tlast;
  assign sine        = m_axis_data_tdata[11:0];
  assign cosine      = m_axis_data_tdata[27:16];


  localparam integer CE_REPEAT_CNT = 5;
  localparam integer CE_REP_CNT_WIDTH = $clog2(CE_REPEAT_CNT);
   
  logic [CE_REP_CNT_WIDTH-1:0]	ce_repeat_cnt = CE_REPEAT_CNT-1;
  logic			        ce_repeat     = 1'b0;


  // Use clock enable to repeat ROM/Distributed RAM values over multiple cycles
  // set CE_REPEAT_CNT to 1 to read out ROM values each cycle
  always_ff @(posedge clk) begin
    if (rst) begin
      ce_repeat <= 1'b0;
    end else begin
             
      ce_repeat     <= CE_REPEAT_CNT-1 == ce_repeat_cnt;
      ce_repeat_cnt <= ce_repeat_cnt - 1'b1;

      if (ce_repeat_cnt == 'd0) begin
         ce_repeat_cnt <= CE_REPEAT_CNT-1;
      end
      
    end
  end

  //  Gain coefficient indexing block, take a gain value from distributed RAM
  //  and use it to scale the NCO output
  //  Iterate through the gain coe, use downcounter for reduced comb load
  always_ff @(posedge clk) begin
     if (rst) begin
	
       a_scale     <= tp_arr[N_GAIN_CNT-1];
       tp_gain_cnt <= N_GAIN_CNT;
	
     end else begin
       if (ce_repeat) begin
         a_scale     <= tp_arr[tp_gain_cnt];
         tp_gain_cnt <= tp_gain_cnt - 1'b1;
         
         if(tp_gain_cnt == 'd0) begin
           tp_gain_cnt <= N_GAIN_CNT - 1'b1;
         end
       end
     end
  end
   
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

  // !!! The message below is stale or 'misinformed' pathing
  // You must compile the wrapper file dds_compiler_0.v when simulating
  // the core, dds_compiler_0. When compiling the wrapper file, be sure to
  // reference the Verilog simulation library.
   
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


   logic [11:0] sin_mag_s2;
   logic [11:0] cos_mag_s2;
   logic	sin_has_frac_s2;
   logic	cos_has_frac_s2;
   logic	sin_is_neg_s2;
   logic	cos_is_neg_s2;
   logic [12:0] sin_rnd_mag_s3;
   logic [12:0] cos_rnd_mag_s3;
   logic [13:0] sin_round_s3;
   logic [13:0] cos_round_s3;


   logic signed [23:0]	sine_prod_s1;
   logic signed [23:0]	cosine_prod_s1;
   logic		sine_prod_valid_s1;
   logic		cosine_prod_valid_s1;
   
  // Multiply block
  always @(posedge clk) begin
    if (rst) begin
      sine_prod_s1         <= 'd0;
      cosine_prod_s1       <= 'd0;
      sine_prod_valid_s1   <= 'd0;
      cosine_prod_valid_s1 <= 'd0;
    end else begin
        sine_prod_s1          <= a_scale*sine;
        cosine_prod_s1        <= a_scale*cosine;
        sine_prod_valid_s1    <= m_axis_data_tvalid;
        cosine_prod_valid_s1  <= m_axis_data_tvalid;
    end
  end // else: !if(rst)

  logic sin_s1_to_s2_valid;
  logic cos_s1_to_s2_valid;

  logic sin_s2_to_s3_valid;
  logic cos_s2_to_s3_valid;

  localparam integer N_PIPE = 3;
   
  logic [N_PIPE-1:0] pipe_valid = 'd0;
  logic [N_PIPE-1:0] pipe_tlast = 'd0;

  
  // Pipelined signed multiply drawing operands from input A: NCO (Numerically Controlled Oscillator
  // and input B: a_scale coefficient, each is 12 bit signed, output is the upper 12 bits
  always @(posedge clk) begin

    pipe_valid[N_PIPE-1:1] <= pipe_valid[N_PIPE-2:0];
    pipe_tlast[N_PIPE-1:1] <= pipe_tlast[N_PIPE-2:0];

    //////  Stage 1 S1 -> S2     
    // Capture magnitude and presence of fractional bits for rounding in next pipeline stage
    if (sine_prod_s1[23]) begin
      sin_has_frac_s2 <= |sine_prod_s1[11:0];
      sin_mag_s2   <= $unsigned(-sine_prod_s1) >> 12;
    end else begin
      sin_has_frac_s2 <= |sine_prod_s1[11:0];
      sin_mag_s2   <= $unsigned(sine_prod_s1)  >> 12;     
    end

    // Cosine product block
    if (cosine_prod_s1[23]) begin
      cos_has_frac_s2 <= |cosine_prod_s1[11:0];
      cos_mag_s2   <= $unsigned(-cosine_prod_s1) >> 12;
    end else begin    
      cos_has_frac_s2 <= |cosine_prod_s1[11:0];
      cos_mag_s2   <= $unsigned(cosine_prod_s1)  >> 12;
    end

    sin_is_neg_s2 <= sine_prod_s1[23];
    cos_is_neg_s2 <= cosine_prod_s1[23];

    //////  Stage 2 S2 -> S3     
    // Round based on presence of fractional bits in 12 LSBs, round symmetrically toward infinity
    // S2 -> S3
    if (sin_is_neg_s2) begin
      sin_round_s3 <= -$signed({1'b0, ({1'b0, sin_mag_s2} + sin_has_frac_s2)});
    end else begin
      sin_round_s3 <= $signed({1'b0, ({1'b0, sin_mag_s2} + sin_has_frac_s2)});       
    end

    if (cos_is_neg_s2) begin
      cos_round_s3 <= -$signed({1'b0, ({1'b0, cos_mag_s2} + cos_has_frac_s2)});
    end else begin
      cos_round_s3 <= $signed({1'b0, ({1'b0, cos_mag_s2} + cos_has_frac_s2)});       
    end
		     
  end // always @ (posedge clk)



endmodule // chroma_tp

/*

  400,400,400,400,400,
  41C,41C,41C,41C,41C,
  437,437,437,437,437,
  454,454,454,454,454,
  470,470,470,470,470,
  48B,48B,48B,48B,48B,
  4A7,4A7,4A7,4A7,4A7,
  4C3,4C3,4C3,4C3,4C3,
  4DE,4DE,4DE,4DE,4DE,
  4FB,4FB,4FB,4FB,4FB,
  517,517,517,517,517,
  532,532,532,532,532,
  54E,54E,54E,54E,54E,
  569,569,569,569,569,
  585,585,585,585,585,
  5A2,5A2,5A2,5A2,5A2,
  5BD,5BD,5BD,5BD,5BD,
  5D9,5D9,5D9,5D9,5D9,
  5F5,5F5,5F5,5F5,5F5,
  610,610,610,610,610,
  62C,62C,62C,62C,62C,
  649,649,649,649,649,
  664,664,664,664,664,
  680,680,680,680,680,
  69C,69C,69C,69C,69C,
  6B7,6B7,6B7,6B7,6B7,
  6D4,6D4,6D4,6D4,6D4,
  6F0,6F0,6F0,6F0,6F0,
  70B,70B,70B,70B,70B,
  727,727,727,727,727,
  743,743,743,743,743,
  75E,75E,75E,75E,75E,
  77B,77B,77B,77B,77B,
  797,797,797,797,797,
  7B2,7B2,7B2,7B2,7B2,
  7CE,7CE,7CE,7CE,7CE,
  7E9,7E9,7E9,7E9;

 
*/ 
 

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


  // Gain (%)   Q1.11       Decimal   Hex
  // 100.0      0.500000    1024      400
  // 102.7      0.513672    1052      41C
  // 105.4      0.526855    1079      437
  // 108.2      0.541016    1108      454
  // 110.9      0.554688    1136      470
  // 113.6      0.567871    1163      48B
  // 116.3      0.581543    1191      4A7
  // 119.0      0.595215    1219      4C3
  // 121.7      0.608398    1246      4DE
  // 124.5      0.622559    1275      4FB
  // 127.2      0.636230    1303      517
  // 129.9      0.649414    1330      532
  // 132.6      0.663086    1358      54E
  // 135.3      0.676270    1385      569
  // 138.0      0.689941    1413      585
  // 140.8      0.704102    1442      5A2
  // 143.5      0.717285    1469      5BD
  // 146.2      0.730957    1497      5D9
  // 148.9      0.744629    1525      5F5
  // 151.6      0.757812    1552      610
  // 154.3      0.771484    1580      62C
  // 157.1      0.785645    1609      649
  // 159.8      0.798828    1636      664
  // 162.5      0.812500    1664      680
  // 165.2      0.826172    1692      69C
  // 167.9      0.839355    1719      6B7
  // 170.7      0.853516    1748      6D4
  // 173.4      0.867188    1776      6F0
  // 176.1      0.880371    1803      70B
  // 178.8      0.894043    1831      727
  // 181.5      0.907715    1859      743
  // 184.2      0.920898    1886      75E
  // 187.0      0.935059    1915      77B
  // 189.7      0.948730    1943      797
  // 192.4      0.961914    1970      7B2
  // 195.1      0.975586    1998      7CE
  // 197.8      0.988770    2025      7E9
