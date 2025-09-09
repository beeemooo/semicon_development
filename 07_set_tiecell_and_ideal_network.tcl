#set TIE cell
#A tie cell is a special type of standard cell that provides a constant high or low signal to the input of any logic gate

set_lib_cell_purpose -include optimization [get_lib_cells */TIE*] ;# set TIE cell used in optimizaiton
set_dont_touch [get_lib_cells */TIE*] false ;# set TIE cells "dont_touch" value false


#remove_propagated clocks before placement
#set ideal network for all clock
#we can analyze only ideal network in placement stage (because you didn't run CTS not yet)

set mode "func scan_shift scan_capture"

foreach MODE $mode {
current_mode $MODE

echo "current mode is $MODE"
	switch $MODE {
		func {
			remove_propagated_clocks [all_clocks]
			set clock_sink [get_pins -hier -filter "is_clock_pin == true || full_name == I_CLOCK_GEN/I_*/CLK_*X"]
			remove_ideal_network $clock_sink
			set_ideal_network [get_pins $clock_sink]
			set_ideal_network [get_nets buf_sdram_clk]
		}
		scan_shift {
			remove_propagated_clocks [all_clocks]
			set clock_sink [get_pins -hier -filter "is_clock_pin == true || full_name == I_CLOCK_GEN/I_*/CLK_*X"]
			remove_ideal_network $clock_sink
			set_ideal_network [get_pins $clock_sink]
			set_ideal_network [get_nets buf_sdram_clk]
		}
		scan_capture {
			remove_propagated_clocks [all_clocks]
			set clock_sink [get_pins -hier -filter "is_clock_pin == true || full_name == I_CLOCK_GEN/I_*/CLK_*X"]
			remove_ideal_network $clock_sink
			set_ideal_network [get_pins $clock_sink]
			set_ideal_network [get_nets buf_sdram_clk]
		}
	}
}



