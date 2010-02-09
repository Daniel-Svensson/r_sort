onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /workbench/test_input
add wave -noupdate -format Literal -expand /workbench/output
add wave -noupdate -format Logic /workbench/data_ready
add wave -noupdate -format Logic /workbench/clk
add wave -noupdate -format Logic /workbench/rst
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {926 ns}
WaveRestoreZoom {100 ns} {1100 ns}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
