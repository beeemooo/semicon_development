#set a false path constraint from the ScanEnable port (top-level)

#set current mode func
current_mode "func"

#set false path
set_false_path -from scan_en -to [get_clocks "PCI* SD* SYS*"] ;#Identifies paths in a design to mark as false, so that they are not considered during timing analysis

#report high fanout
report_net_fanout -high_fanout

#set false path about buf_sdram_clk
current_mode "func"
set_false_path  -through [get_pins DFTC_70/Y]

#source set_disable_timing.tcl

source -e ./user_script/set_disable_timing.tcl ;#Disables timing through the specified cells, pins, ports, or timing arcs in the current_mode, if library cells or pins are specified, it disables the timing arcs for all modes that utilize the library 

#set_app_options for placement

set_app_options -list {opt.tie_cell.max_fanout {8}} ;#Specifies the maximum fanout a tie-cell can drive
set_app_options -list {cts.common.max_fanout {16}} ;#Fanout constraint for clock tree synthesis
set_app_options -list {opt.common.max_fanout {16}} ;#Fanout constraint for data path optimization
set_app_options -list {place.coarse.congestion_layer_aware {true}} ;#Controls whether the tool considers the congestion of each layer separately during coarse placement
set_app_options -list {place.coarse.continue_on_missing_scandef {true}} ;#When this option is true scandef checking prior to coarse placement is disabled
set_app_options -list {opt.common.drc_mode_buffering {true}} ;#Buffering mode for drc stages of place_opt and clock_opt
set_app_options -list {place_opt.initial_drc.global_route_based {1}} ;#Run global route based buffering (GRopto flow) during the initial_drc place_opt stage
set_app_options -list {place_opt.initial_place.buffering_aware {true}} ;#Runs buffering-aware timing-driven placement for the initial placement step inside the place_opt command

set_app_options -list {place.coarse.pin_density_aware {true}} ;#Enables pin density-aware coarse placement
set_app_options -list {place_opt.congestion.effort {high}} ;#set congestion effort during placement
set_app_options -list {place_opt.final_place.effort {high}} ;#Specifies the CPU effort level for the final coarse placement invoked in place_opt

