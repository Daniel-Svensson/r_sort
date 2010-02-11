onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /workbench/test_input
add wave -noupdate -format Literal /workbench/sorter/data
add wave -noupdate -format Logic /workbench/data_ready
add wave -noupdate -format Logic /workbench/clk
add wave -noupdate -format Logic /workbench/rst
add wave -noupdate -divider B_0
add wave -noupdate -format Logic /workbench/sorter/b0_cs
add wave -noupdate -format Literal -radix unsigned /workbench/sorter/b0_idx_val
add wave -noupdate -format Literal /workbench/sorter/b0_ram/storage
add wave -noupdate -divider B_1
add wave -noupdate -format Logic /workbench/sorter/b1_cs
add wave -noupdate -format Literal -radix unsigned /workbench/sorter/b1_idx_val
add wave -noupdate -format Literal /workbench/sorter/b1_ram/storage
add wave -noupdate -divider Regs
add wave -noupdate -format Literal -radix unsigned /workbench/sorter/b_idx
add wave -noupdate -format Logic /workbench/sorter/b_ld
add wave -noupdate -format Logic /workbench/sorter/current_s_bit
add wave -noupdate -divider TMP
add wave -noupdate -format Literal -radix unsigned /workbench/sorter/tmp_idx
add wave -noupdate -format Logic /workbench/sorter/tmp_cs
add wave -noupdate -format Logic /workbench/sorter/tmp_max
add wave -noupdate -format Literal /workbench/sorter/tmp_ram/storage
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal -radix unsigned /workbench/sorter/reg_selected
add wave -noupdate -divider FSM
add wave -noupdate -format Literal /workbench/sorter/state_machine/current_state
add wave -noupdate -divider IO
add wave -noupdate -format Literal /workbench/sorter/in_reg_val
add wave -noupdate -format Logic /workbench/sorter/in_reg_oe
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {289 ns}
WaveRestoreZoom {0 ns} {368 ns}
configure wave -namecolwidth 255
configure wave -valuecolwidth 51
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
