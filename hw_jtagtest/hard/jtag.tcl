
proc jtag_open {} {
	set hw_name [lindex [get_hardware_names] 0]
	set dv_name [lindex [get_device_names -hardware_name $hw_name] 0]
	puts "Opening device <$hw_name>:<$dv_name>"
	open_device -device_name $dv_name -hardware_name $hw_name
	device_lock -timeout 1000
	}

proc jtag_close {} {
	device_unlock
	close_device
	}

proc jtag_cmd {c} {
	device_virtual_ir_shift -instance_index 0 -ir_value $c
	}

proc jtag_hex {d len} {
	device_virtual_dr_shift -instance_index 0 -dr_value $d -length $len -value_in_hex
	}

proc jtag_hex_32 {d} {
	device_virtual_dr_shift -instance_index 0 -dr_value $d -length 32 -value_in_hex -no_captured_dr_value
	}

proc jtag_bin {d len} {
	device_virtual_dr_shift -instance_index 0 -dr_value $d -length $len
	}

proc reseta {} {
	jtag_cmd 2
	jtag_hex 00 8
}

proc set_addr {w} {
	jtag_cmd 1
	jtag_bin 010 3
	jtag_cmd 3
	jtag_hex $w 32
	jtag_cmd 1
	jtag_bin 000 3
	format "Addr set to %s" $w
}


proc addw {w} {
	jtag_cmd 1
	jtag_bin 001 3
	jtag_cmd 3
	jtag_hex $w 32
	jtag_cmd 2
	set a [scan [jtag_hex 00 8] "%x"]
	set a [expr {$a + 1}]
	jtag_hex [format "%02X" $a] 8
	jtag_cmd 1
	jtag_bin 000 3
}

proc rdw {} {
	jtag_cmd 3
	set w [scan [jtag_hex 00000000 32] "%x"]
	jtag_cmd 2
	set a [scan [jtag_hex 00 8] "%x"]
	set a [expr {$a + 1}]
	jtag_hex [format "%02X" $a] 8
	format "%08X" $w
}

proc read {len} {
	jtag_cmd 1
	jtag_bin 100 3
	jtag_cmd 3
	set l [scan $len "%d"]
	jtag_hex [format "%08X" $l] 32
	jtag_cmd 0
	jtag_bin 000 3
	format "READ request of length %d is done." $l
}

proc write {len} {
	jtag_cmd 1
	jtag_bin 100 3
	jtag_cmd 3
	set orv [scan "80000000" "%x"]
	set l [scan $len "%d"]
	set ll [expr {$l | $orv}]
	jtag_hex [format "%08X" $l] 32
	jtag_cmd 0
	jtag_bin 000 3
	format "WRITE request of length %d is done." $ll
}
