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

