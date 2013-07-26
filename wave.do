onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /sdram_mac_tb/CLK
add wave -noupdate /sdram_mac_tb/RESET
add wave -noupdate /sdram_mac_tb/uut/sdram/BUSY
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /sdram_mac_tb/A
add wave -noupdate -radix hexadecimal /sdram_mac_tb/DQ
add wave -noupdate -divider <NULL>
add wave -noupdate /sdram_mac_tb/RASn
add wave -noupdate /sdram_mac_tb/CASn
add wave -noupdate /sdram_mac_tb/WEn
add wave -noupdate /sdram_mac_tb/DQMH
add wave -noupdate /sdram_mac_tb/DQML
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned /sdram_mac_tb/ADDR
add wave -noupdate /sdram_mac_tb/WE
add wave -noupdate /sdram_mac_tb/WE_A
add wave -noupdate /sdram_mac_tb/WE_LEN
add wave -noupdate -radix hexadecimal /sdram_mac_tb/WD
add wave -noupdate -radix hexadecimal /sdram_mac_tb/RD
add wave -noupdate -divider <NULL>
add wave -noupdate /sdram_mac_tb/uut/st_idle
add wave -noupdate /sdram_mac_tb/uut/st_armed
add wave -noupdate /sdram_mac_tb/uut/st_running
add wave -noupdate -divider <NULL>
add wave -noupdate /sdram_mac_tb/uut/wr_adv
add wave -noupdate -radix unsigned /sdram_mac_tb/uut/mem_wa
add wave -noupdate -radix hexadecimal /sdram_mac_tb/uut/mem_wd
add wave -noupdate -divider <NULL>
add wave -noupdate /sdram_mac_tb/uut/rd_adv
add wave -noupdate -radix unsigned /sdram_mac_tb/uut/mem_ra
add wave -noupdate -radix hexadecimal /sdram_mac_tb/uut/mem_rd
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned /sdram_mac_tb/uut/req_len
add wave -noupdate -radix unsigned /sdram_mac_tb/uut/max_len
add wave -noupdate /sdram_mac_tb/uut/len_ok
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal {/sdram_mac_tb/uut/bram_16to32/ram[0]}
add wave -noupdate -radix hexadecimal {/sdram_mac_tb/uut/bram_16to32/ram[1]}
add wave -noupdate -radix hexadecimal {/sdram_mac_tb/uut/bram_16to32/ram[2]}
add wave -noupdate -radix hexadecimal {/sdram_mac_tb/uut/bram_16to32/ram[3]}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {9504813 ps} 0}
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
WaveRestoreZoom {8208371 ps} {10522059 ps}
