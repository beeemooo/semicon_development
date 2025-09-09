#made by kjinsoo
# module load
#module load icc2/2021.06-SP5
# open icc2_shell
#icc2_shell -gui | tee -i ./04_placement.log

#set current step & before step
set step placement
set before_step powerplan

#source design_setup.tcl
source -e ./icc2_common_env/design_setup.tcl

#source timer.rpt script - report runtime for placement
source ./icc2_common_env/sec_runtime.tcl

sec_StartTimer copy_lib

#set_host_options -max_cores 16

#open lib
open_lib ../03_powerplan/nlib/ORCA_${before_step}.nlib
#copy lib
copy_lib -from ../03_powerplan/nlib/ORCA_${before_step}.nlib -to ./nlib/ORCA_${step}.nlib
#close & open current lib
close_lib -all
open_lib ./nlib/ORCA_${step}.nlib
#open block
open_block ./nlib/ORCA_${step}.nlib:ORCA.design
#link_block
link_block -rebind

sec_ReportResourceUtil copy_lib

#create routing blockages for all Macros & PLL 

source -e ./user_script/create_routing_blockage.tcl

#insert guide buffer (all Macros & PLL signal inout port)
#insert buffer (scan_en_iopad/DOUT) - purpose of high_fanout_synthesis

source -e ./user_script/insert_guide_buf.tcl

#remove scenarios modes corners before setting

remove_scenarios -all
remove_modes -all
remove_corners -all


# Read TLU+ files
# TLU+ file is given by Foundary Company
# This file contains Metal capacitance at different spacing and width in the form of a lookup -
# talbe which provides high accuracy and runtime (This file can be used to extract RC value from interconnects)

read_parasitic_tech -name {minTLU} -tlup $data(tech_tlupbc)
read_parasitic_tech -name {maxTLU} -tlup $data(tech_tlupwc)

# source mcmm(multi corners multi modes).tcl

source -e ./icc2_common_env/mcmm.tcl
#set scenario_status -- report 

# all about ss corner
set_scenario_status {*.ss*} -setup true -hold true \
			    -active true -max_transition true \
			    -max_capacitance true \
			    -min_capacitance false \
		            -leakage_power true \
		            -dynamic_power true 
# all about ff corner
set_scenario_status {*.ff*} -setup true -hold true \
                            -active true -max_transition true \
		            -max_capacitance true \
			    -min_capacitance false \
 			    -leakage_power true \
	                    -dynamic_power true

#report_modes after set_scenario_status
report_modes


#read_sdc(synopsys design constraints)
#SDC contain information such as clock definitions, input and output delays, false paths, and timing exeptions

#scan_shift mode
current_mode scan_shift
read_sdc $data(shift_sdc) ;# ${libdir}/SDC/ORCA_shift.sdc

#func mode
current_mode func
read_sdc $data(func_sdc) ;# ${libdir}/SDC/ORCA_func.sdc

#scan_capture mode
current_mode scan_capture
read_sdc $data(capture_sdc) ;# ${libdir}/SDC/ORCA_capture.sdc

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


#set a false path constraint from the ScanEnable port (top-level)

#set current mode func
current_mode "func"

#set false path
set_false_path -from scan_en -to [get_clocks "PCI* SD* SYS*"] ;#Identifies paths in a design to mark as false, so that they are not considered during timing analysis

#report high fanout
report_net_fanout -high_fanout

current_mode "func"
#set_false_path  -through [get_pins DFTC_70/Y]

#source set_disable_timing.tcl

source -e ./user_script/set_disable_timing.tcl

#set_app_options for placement

set_app_options -list {opt.tie_cell.max_fanout {8}}
set_app_options -list {cts.common.max_fanout {16}}
set_app_options -list {opt.common.max_fanout {16}}
set_app_options -list {place.coarse.congestion_layer_aware {true}}
set_app_options -list {place.coarse.continue_on_missing_scandef {true}}
set_app_options -list {opt.common.drc_mode_buffering {true}}
set_app_options -list {place_opt.initial_drc.global_route_based {1}}
set_app_options -list {place_opt.initial_place.buffering_aware {true}}

set_app_options -list {place.coarse.pin_density_aware {true}}
set_app_options -list {place_opt.place.congestion_effort {high}}
set_app_options -list {place_opt.final_place.effort {high}}

#place_opt - place and optimize the current design
#< 5 stages of place_opt >
#initial_place - initial_drc - initial_opto - final_place - final_opto

sec_StartTimer place_opt

#place_opt
place_opt

sec_ReportResourceUtil place_opt

#congestion
report_congestion -rerun_global_router ;#Reports the congestion statistics

#timing
report_timing -significant_digits 5 ;#Displays timing information about a design

#Qor summary
report_qor -summary ;#Displays QoR information and statistics for the current design

############################################################
#report Timing & constraints for placement after place_opt
############################################################

#update timing
update_timing -full ;#Updates timing information on the current design

sec_StartTimer report

#write "reports files" of placement at ${rundir}/reports/placement/* directory
source ./user_script/placement_rpt.tcl

sec_ReportResourceUtil report

#save_lib

save_lib -all



#refine_opt
#By running refine_opt command, you can optimize the place_opt completed db once again

set_app_options -list {refine_opt.place.congestion_effort {high}}
set_app_options -list {refine_opt.place.effort {high}}
set_app_options -list {place_opt.final_place.effort {high}}

sec_StartTimer refine_opt

refine_opt ;#By running refine_opt command, you can optimize the place_opt completed db once again

sec_ReportResourceUtil refine_opt


#source Insert_spare cell script
#Spare cells enable us to modify/improve the functionality of a chip with minimal changes in the mask

source -e ./user_script/spare_cell_insertion.tcl 

#####################
#check placement
#####################

#legality 
check_legality ;#Checks the legality of the current placement

#mv_design
check_mv_design ;#Checks for violations in a multi-voltage design

#utilization of core area (use -region option)
report_utilization -region {{{425.5430 425.8460} {1014.4590 1014.1520}}} ;#Reports utilization of the current block 

#congestion
report_congestion -rerun_global_router;#Reports the congestion statistics

#timing
report_timing -significant_digits 5 ;#Displays timing information about a design

#Qor summary
report_qor -summary ;#Displays QoR information and statistics for the current design

############################################################
#report Timing & constraints for placement after refine_opt
############################################################

#update timing
update_timing -full ;#Updates timing information on the current design

sec_StartTimer report

#write "reports files" of placement at ${rundir}/reports/placement/* directory
source ./user_script/refine_opt_rpt.tcl

sec_ReportResourceUtil report


#save_lib 
save_lib -as ./nlib/ORCA_refine_opt.nlib

#exit
exit

