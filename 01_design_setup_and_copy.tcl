

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


