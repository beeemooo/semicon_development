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


