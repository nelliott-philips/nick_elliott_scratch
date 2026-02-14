onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group gpo_dut /gpo_watchdog_tb/gpo_reg_dut/clk
add wave -noupdate -group gpo_dut /gpo_watchdog_tb/gpo_reg_dut/reset
add wave -noupdate -group gpo_dut /gpo_watchdog_tb/gpo_reg_dut/clr_bit_mask
add wave -noupdate -group gpo_dut /gpo_watchdog_tb/gpo_reg_dut/wr_strobe
add wave -noupdate -group gpo_dut /gpo_watchdog_tb/gpo_reg_dut/datain
add wave -noupdate -group gpo_dut /gpo_watchdog_tb/gpo_reg_dut/dataout
add wave -noupdate -group gpo_dut /gpo_watchdog_tb/gpo_reg_dut/strbout
add wave -noupdate -group wd_simple_dut /gpo_watchdog_tb/gpo_wd_dut/clk
add wave -noupdate -group wd_simple_dut /gpo_watchdog_tb/gpo_wd_dut/rst
add wave -noupdate -group wd_simple_dut /gpo_watchdog_tb/gpo_wd_dut/gpo_reg_data_i
add wave -noupdate -group wd_simple_dut /gpo_watchdog_tb/gpo_wd_dut/gpo_reg_data_o
add wave -noupdate -group wd_simple_dut /gpo_watchdog_tb/gpo_wd_dut/gpo_clear_msk_o
add wave -noupdate -group wd_simple_dut /gpo_watchdog_tb/gpo_wd_dut/early_warn_intrpt_o
add wave -noupdate -group wd_simple_dut /gpo_watchdog_tb/gpo_wd_dut/shutdown_o
add wave -noupdate -group wd_simple_dut /gpo_watchdog_tb/gpo_wd_dut/wd_state
add wave -noupdate -group wd_simple_dut /gpo_watchdog_tb/gpo_wd_dut/timeout_cnt
add wave -noupdate -group wd_simple_dut -format Analog-Step -height 74 -max 524288.0 -radix unsigned /gpo_watchdog_tb/gpo_wd_dut/timeout_cnt
add wave -noupdate -group wd_simple_dut /gpo_watchdog_tb/gpo_wd_dut/timed_out
add wave -noupdate -group wd_simple_dut /gpo_watchdog_tb/gpo_wd_dut/has_timed_out
add wave -noupdate -group wd_simple_dut /gpo_watchdog_tb/gpo_wd_dut/shutdown
add wave -noupdate -group wd_simple_dut /gpo_watchdog_tb/gpo_wd_dut/early_warn_intrpt
add wave -noupdate -expand -group chroma /gpo_watchdog_tb/genblk1/gpo_reg_chroma_path_dut/clk
add wave -noupdate -expand -group chroma /gpo_watchdog_tb/genblk1/gpo_reg_chroma_path_dut/reset
add wave -noupdate -expand -group chroma /gpo_watchdog_tb/genblk1/gpo_reg_chroma_path_dut/clr_bit_mask
add wave -noupdate -expand -group chroma /gpo_watchdog_tb/genblk1/gpo_reg_chroma_path_dut/wr_strobe
add wave -noupdate -expand -group chroma /gpo_watchdog_tb/genblk1/gpo_reg_chroma_path_dut/datain
add wave -noupdate -expand -group chroma /gpo_watchdog_tb/genblk1/gpo_reg_chroma_path_dut/dataout
add wave -noupdate -expand -group chroma /gpo_watchdog_tb/genblk1/gpo_reg_chroma_path_dut/strbout
add wave -noupdate -expand -group chroma /gpo_watchdog_tb/genblk1/chroma_dut/clk
add wave -noupdate -expand -group chroma /gpo_watchdog_tb/genblk1/chroma_dut/rst
add wave -noupdate -expand -group chroma /gpo_watchdog_tb/genblk1/chroma_dut/gpo_data_i
add wave -noupdate -expand -group chroma -radix decimal /gpo_watchdog_tb/genblk1/chroma_dut/motion_filter_data
add wave -noupdate -expand -group chroma -radix decimal /gpo_watchdog_tb/genblk1/chroma_dut/band_pass_filter_data
add wave -noupdate -expand -group chroma -format Analog-Step -height 74 -max 32087.000000000004 -min -32387.0 -radix decimal /gpo_watchdog_tb/genblk1/chroma_dut/motion_filter_data
add wave -noupdate -expand -group chroma -format Analog-Step -height 74 -max 2011.0000000000002 -min -1850.0 -radix decimal /gpo_watchdog_tb/genblk1/chroma_dut/band_pass_filter_data
add wave -noupdate -expand -group chroma /gpo_watchdog_tc/tmp_chroma_reg
add wave -noupdate -expand -group chroma /gpo_watchdog_tc/tmp_chroma_reg
add wave -noupdate -expand -group chroma -expand /gpo_watchdog_tb/genblk1/chroma_dut/gpo_data_o
add wave -noupdate -expand -group chroma /gpo_watchdog_tb/genblk1/chroma_dut/activity_monitor
add wave -noupdate /gpo_watchdog_tc/filter_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {263231719 ps} 0} {{Cursor 2} {189244727670 ps} 0} {{Cursor 3} {199796410000 ps} 0}
quietly wave cursor active 1
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
WaveRestoreZoom {0 ps} {1156155 ns}
