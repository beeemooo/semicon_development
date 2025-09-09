#report Timing & constraints for placement after refine_opt

#update timing
update_timing -full ;#Updates timing information on the current design

sec_StartTimer report

#write "reports files" of placement at ${rundir}/reports/placement/* directory
source ./user_script/refine_opt_rpt.tcl

sec_ReportResourceUtil report

