#!/bin/bash

# vlib -c
# vlib work
# vmap work work

function cmp_ext()
{
  xvlog  gpo_watchdog_v2.v
  vlog   gpo_watchdog_v2.v  
}


function cmp_wd()
{
  xvlog     gpo_watchdog.v
  xvlog     gpo_watchdog_v2.v
  xvlog     gpo_register.v  
  xvlog -sv gpo_watchdog_tb.sv
  xvlog -sv gpo_watchdog_tc.sv

  vlog     gpo_watchdog.v  
  vlog     gpo_watchdog_v2.v
  vlog     gpo_register.v    
  vlog -sv gpo_watchdog_tb.sv
  vlog -sv gpo_watchdog_tc.sv

  # xvlog -sv gpo_watchdog.sv
  # xvlog -sv gpo_watchdog_tb.sv
  # xvlog -sv gpo_watchdog_tc.sv
    
  # vlog -sv gpo_watchdog.sv
  # vlog -sv gpo_watchdog_tb.sv
  # vlog -sv gpo_watchdog_tc.sv
  
}

function elab_wd()
{
  xelab --debug typical --timescale 1ns/1ps work.gpo_watchdog_tb work.gpo_watchdog_tc
}

function sim_wd()
{
  xsim -gui work.gpo_watchdog_tb#work.gpo_watchdog_tc &
  #vsim work.gpo_watchdog &
}

function wd()
{
  #cmp_simple && elab_simple && sim_simple
  cmp_wd && elab_wd && sim_wd &
}

function wd_m()
{
  #cmp_simple && elab_simple && sim_simple
  cmp_wd && vsim work.gpo_watchdog_tb work.gpo_watchdog_tc -do wave_simple.do &
  #cmp_wd && vsim work.gpo_watchdog_tb work.gpo_watchdog_tc -do wave.do &    
}


function cmp_simple()
{
  #xvlog -sv counter.sv
  #xvlog -sv counter_tb.sv

  vlog counter.sv
  vlog counter_tb.sv
  
}

function elab_simple()
{
  #xelab --debug typical --timescale 1ns/1ps work.counter_tb
  xelab --debug typical --timescale 1ns/1ps work.counter_tb
    
}

function sim_simple()
{
  # xsim -gui work.counter_tb &
  vsim work.counter_tb &
}

function simple()
{
  #cmp_simple && elab_simple && sim_simple
  cmp_simple && sim_simple
}

function vcmp_beam()
{

  # vlog \
  # $XILINX_VIVADO/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv \
  # -L xpm
  # 
  # vlog \
  # $XILINX_VIVADO/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv \
  # -L xpm
  # 
  # vlog \
  # $XILINX_VIVADO/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv \
  # -L xpm
  # 
  # vlog \
  # $XILINX_VIVADO/data/verilog/src/glbl.v \
  # -L xpm
  #   
  # Vlog ../Beamformer_base.gen/sources_1/bd/design_1/ip/design_1_dds_compiler_0_1/design_1_dds_compiler_0_1_sim_netlist.v
  # 
  # vlog ../beamformer_base.gen/sources_1/bd/design_1/ip/design_1_c_addsub_0_0/design_1_c_addsub_0_0_sim_netlist.v
  # 
  # vlog ../beamformer_base.gen/sources_1/bd/design_1/ip/design_1_dds_compiler_0_2/design_1_dds_compiler_0_2_sim_netlist.v
  # 
  # vlog ../beamformer_base.gen/sources_1/bd/design_1/sim/design_1.v
  # 
  # vlog ../beamformer_base.srcs/sources_1/imports/hdl/design_1_wrapper.v
  # 
  # vlog tx_top.sv
  # 
  # vlog tx_top_tb.sv

  vsim work.tx_top_tb

  #vsim -c work.tx_top_tb -do "log -r /*"; run 200us; quit -f | tee sim_transcript.txt

}

function cmp_beam()
{

  xvlog -sv \
  $XILINX_VIVADO/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv \
  -L xpm
 
  xvlog -sv \
  $XILINX_VIVADO/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv \
  -L xpm
 
  xvlog -sv \
  $XILINX_VIVADO/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv \
  -L xpm
 
  xvlog -sv \
  $XILINX_VIVADO/data/verilog/src/glbl.v \
  -L xpm
    
  xvlog ../beamformer_base.gen/sources_1/bd/design_1/ip/design_1_dds_compiler_0_1/design_1_dds_compiler_0_1_sim_netlist.v
  
  xvlog ../beamformer_base.gen/sources_1/bd/design_1/ip/design_1_c_addsub_0_0/design_1_c_addsub_0_0_sim_netlist.v
  
  xvlog ../beamformer_base.gen/sources_1/bd/design_1/ip/design_1_dds_compiler_0_2/design_1_dds_compiler_0_2_sim_netlist.v

  xvlog ../beamformer_base.gen/sources_1/bd/design_1/sim/design_1.v
  
  xvlog ../beamformer_base.srcs/sources_1/imports/hdl/design_1_wrapper.v
  
  xvlog -sv tx_top.sv
  
  xvlog -sv tx_top_tb.sv
    
}

function elab_beam()
{
  xelab --debug typical --timescale 1ns/1ps tx_top_tb glbl -L xpm -L unisims_ver
}

function sim_beam()
{
  xsim -gui work.tx_top_tb#work.glbl &    
}

function beam()
{
  cmp_beam && elab_beam && sim_beam
}

# function elab_ext()
# {
#   xelab --debug typical --timescale 1ns/1ps  tx_top_tb glbl -L xpm -L unisims_ver 
#   # xelab --debug typical --timescale 1ns/1ps sim_frontend_tb frontend_sim_tc glbl -L xpm -L unisims_ver
#   # xelab --debug typical --timescale 1ns/1ps sim_frontend_tb frontend_sim_tc glbl -L xpm -L unisims_ver    
# }
# 
# function elab_fend()
# {
#   # xelab --debug typical --timescale 1ns/1ps sim_frontend_tb frontend_sim_tc glbl -L xpm -L unisims_ver
#   # xelab --debug typical --timescale 1ns/1ps sim_frontend_tb frontend_sim_tc glbl -L xpm -L unisims_ver    
# }
# 
# function sim_fend()
# {
#   # xsim -gui work.abc_if_tb#work.abc_if_tc &
#   # xsim -gui --view *wcfg work.sim_frontend_tb#work.frontend_sim_tc#work.glbl &
#   # xsim -gui --view work.abc_frontend_tb.work.abc_if_tc.wcfg work.abc_if_tb#work.abc_if_tc &
# }
# 
# function fend()
# {
#   #cmp_ext && cmp_fend && elab_fend && sim_fend
#   #cmp_fend && elab_fend && sim_fend    
# }


case $1 in
    cmp_ext)
      echo "Running cmp_ext"
      cmp_ext
      exit
    ;;
    cmp_wd)
      echo "Running cmp"
      cmp_wd
      exit
    ;;
    elab_wd)
      echo "Running cmp"
      elab_wd
      exit
    ;;
    sim_wd)
      echo "Running cmp"
      sim_wd
      exit
    ;;
    wd)
      echo "Running cmp"
      wd
      exit
    ;;
    wd_m)
      echo "Running cmp"
      wd_m
      exit
    ;;
    cmp_simple)
      echo "Running cmp"
      cmp_simple
      exit
    ;;
    elab_simple)
      echo "Running cmp"
      elab_simple
      exit
    ;;
    sim_simple)
      echo "Running cmp"
      sim_simple
      exit
    ;;
    simple)
      echo "Running cmp"
      simple
      exit
    ;;
    cmp_ext)
      echo "Running cmp"
      cmp_ext
      exit
    ;;
    vcmp_beam)
      echo "Running cmp"
      vcmp_beam
      exit
    ;;
    cmp_beam)
      echo "Running cmp"
      cmp_beam
      exit
    ;;
    elab_beam)
      echo "running elab"
      elab_beam
      exit
    ;;
    sim_beam)
      echo "running sim"
      sim_beam
      exit
    ;;      
    beam)
      echo "running all"
      beam
      exit

esac 
