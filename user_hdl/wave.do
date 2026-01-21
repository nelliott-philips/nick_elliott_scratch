onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group basic_top /gpo_watchdog_tb/clk
add wave -noupdate -expand -group basic_top /gpo_watchdog_tb/rst
add wave -noupdate -expand -group basic_top /gpo_watchdog_tb/clr_bit_mask
add wave -noupdate -expand -group basic_top /gpo_watchdog_tb/clr_bit_mask_wire
add wave -noupdate -expand -group basic_top /gpo_watchdog_tb/wr_strobe
add wave -noupdate -expand -group basic_top /gpo_watchdog_tb/datain
add wave -noupdate -expand -group basic_top /gpo_watchdog_tb/dataout
add wave -noupdate -expand -group basic_top /gpo_watchdog_tb/strbout
add wave -noupdate -expand -group basic_top /gpo_watchdog_tb/gpo_reg_data_out
add wave -noupdate -expand -group basic_top /gpo_watchdog_tb/early_warn_intrpt
add wave -noupdate -expand -group basic_top /gpo_watchdog_tb/shutdown
add wave -noupdate -expand -group clk_en /gpo_watchdog_tb/gpo_wd_dut/clk
add wave -noupdate -expand -group clk_en /gpo_watchdog_tb/gpo_wd_dut/rst
add wave -noupdate -expand -group clk_en /gpo_watchdog_tb/gpo_wd_dut/clk_en
add wave -noupdate -expand -group clk_en /gpo_watchdog_tb/gpo_wd_dut/clk_en_cnt
add wave -noupdate -expand -group clk_en -format Analog-Step -height 74 -max 99999.0 -radix unsigned /gpo_watchdog_tb/gpo_wd_dut/clk_en_cnt
add wave -noupdate -group all /gpo_watchdog_tb/gpo_wd_dut/MS_TIMEBASE_MAX_PARAM
add wave -noupdate -group all /gpo_watchdog_tb/gpo_wd_dut/MS_TIMEBASE_MAX
add wave -noupdate -group all /gpo_watchdog_tb/gpo_wd_dut/MS_TIMEBASE_MSB
add wave -noupdate -group all /gpo_watchdog_tb/gpo_wd_dut/WD_START_STOP_IDX
add wave -noupdate -group all /gpo_watchdog_tb/gpo_wd_dut/APPEASE_IDX
add wave -noupdate -group all /gpo_watchdog_tb/gpo_wd_dut/ENABLE_INTERRUPT_IDX
add wave -noupdate -group all /gpo_watchdog_tb/gpo_wd_dut/CLEAR_EARLY_WARN_INT_IDX
add wave -noupdate -group all /gpo_watchdog_tb/gpo_wd_dut/HAS_TIMED_OUT_IDX
add wave -noupdate -group all /gpo_watchdog_tb/gpo_wd_dut/IS_IN_SHUTDOWN_IDX
add wave -noupdate -group all /gpo_watchdog_tb/gpo_wd_dut/FORCE_SHUTDOWN_IDX
add wave -noupdate -group all /gpo_watchdog_tb/gpo_wd_dut/EARLY_WARN_POLL_IDX
add wave -noupdate -group all /gpo_watchdog_tb/gpo_wd_dut/WATCHDOG_STOPPED_S0
add wave -noupdate -group all /gpo_watchdog_tb/gpo_wd_dut/WATCHDOG_RUNNING_S1
add wave -noupdate -group all /gpo_watchdog_tb/gpo_wd_dut/GPO_CLEAR_MSK
add wave -noupdate -group all /gpo_watchdog_tb/clk
add wave -noupdate -group all /gpo_watchdog_tb/rst
add wave -noupdate -group all /gpo_watchdog_tb/clr_bit_mask
add wave -noupdate -group all /gpo_watchdog_tb/wr_strobe
add wave -noupdate -group all /gpo_watchdog_tb/datain
add wave -noupdate -group all /gpo_watchdog_tb/dataout
add wave -noupdate -group all /gpo_watchdog_tb/strbout
add wave -noupdate -group all /gpo_watchdog_tb/gpo_reg_data_out
add wave -noupdate -group all /gpo_watchdog_tc/tmp_reg
add wave -noupdate -group all /gpo_watchdog_tb/early_warn_intrpt
add wave -noupdate -group all /gpo_watchdog_tb/shutdown
add wave -noupdate -group all /gpo_watchdog_tb/gpo_wd_dut/timeout_cnt_ms
add wave -noupdate -group all /gpo_watchdog_tb/gpo_wd_dut/clk_en
add wave -noupdate -group all /gpo_watchdog_tb/gpo_wd_dut/clk_en_cnt
add wave -noupdate -group all /gpo_watchdog_tb/gpo_wd_dut/clk
add wave -noupdate -group all /gpo_watchdog_tb/gpo_wd_dut/rst
add wave -noupdate -group all /gpo_watchdog_tb/gpo_wd_dut/gpo_reg_data_i
add wave -noupdate -group all /gpo_watchdog_tb/gpo_wd_dut/gpo_reg_data_o
add wave -noupdate -group all /gpo_watchdog_tb/gpo_wd_dut/early_warn_intrpt_o
add wave -noupdate -group all /gpo_watchdog_tb/gpo_wd_dut/shutdown_o
add wave -noupdate -group all /gpo_watchdog_tb/gpo_wd_dut/wd_state
add wave -noupdate -group all /gpo_watchdog_tb/gpo_wd_dut/has_timed_out
add wave -noupdate -group all /gpo_watchdog_tb/gpo_wd_dut/shutdown
add wave -noupdate -group all /gpo_watchdog_tb/gpo_wd_dut/early_warn_intrpt
add wave -noupdate -expand -group wd_features /gpo_watchdog_tb/gpo_wd_dut/gpo_reg_data_i
add wave -noupdate -expand -group wd_features /gpo_watchdog_tb/gpo_wd_dut/gpo_reg_data_stb_i
add wave -noupdate -expand -group wd_features /gpo_watchdog_tb/gpo_wd_dut/gpo_reg_data_o
add wave -noupdate -expand -group wd_features /gpo_watchdog_tb/gpo_wd_dut/gpo_clear_msk_o
add wave -noupdate -expand -group wd_features /gpo_watchdog_tb/gpo_wd_dut/early_warn_intrpt_o
add wave -noupdate -expand -group wd_features /gpo_watchdog_tb/gpo_wd_dut/shutdown_o
add wave -noupdate -expand -group wd_features /gpo_watchdog_tb/gpo_wd_dut/wd_state
add wave -noupdate -expand -group wd_features /gpo_watchdog_tb/gpo_wd_dut/appease_clk_en_latch
add wave -noupdate -expand -group wd_features -radix unsigned /gpo_watchdog_tb/gpo_wd_dut/timeout_cnt_ms
add wave -noupdate -expand -group wd_features -format Analog-Step -height 74 -max 22.0 -radix unsigned /gpo_watchdog_tb/gpo_wd_dut/timeout_cnt_ms
add wave -noupdate -expand -group wd_features /gpo_watchdog_tb/gpo_wd_dut/has_timed_out
add wave -noupdate -expand -group wd_features /gpo_watchdog_tb/gpo_wd_dut/shutdown
add wave -noupdate -expand -group wd_features /gpo_watchdog_tb/gpo_wd_dut/early_warn_intrpt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {224882813 ps} 0} {{Cursor 2} {117275822928 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 342
configure wave -valuecolwidth 223
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {315 ms}
