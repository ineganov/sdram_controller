onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /sdram_tb/CLK
add wave -noupdate /sdram_tb/RESET
add wave -noupdate /sdram_tb/BUSY
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned /sdram_tb/uut/refresh_cnt
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned /sdram_tb/uut/op_cnt
add wave -noupdate -radix unsigned /sdram_tb/uut/iter_cnt
add wave -noupdate /sdram_tb/uut/sdram_fsm/state
add wave -noupdate /sdram_tb/uut/i_done
add wave -noupdate /sdram_tb/uut/t_done
add wave -noupdate -divider <NULL>
add wave -noupdate /sdram_tb/CSn
add wave -noupdate /sdram_tb/RASn
add wave -noupdate /sdram_tb/CASn
add wave -noupdate /sdram_tb/WEn
add wave -noupdate /sdram_tb/DQMH
add wave -noupdate /sdram_tb/DQML
add wave -noupdate -radix hexadecimal /sdram_tb/DQ
add wave -noupdate -radix hexadecimal /sdram_tb/A
add wave -noupdate -radix unsigned /sdram_tb/MAX_LEN
add wave -noupdate -divider <NULL>
add wave -noupdate /sdram_tb/RD_ADV
add wave -noupdate /sdram_tb/WR_ADV
add wave -noupdate -divider <NULL>
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1191302 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {1107491 ps} {2131491 ps}
