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

