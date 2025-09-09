#refine_opt
#By running refine_opt command, you can optimize the place_opt completed db once again

set_app_options -list {refine_opt.place.congestion_effort {high}} ;#Specifies the effort level for the congestion alleviation in refine_opt.
set_app_options -list {refine_opt.place.effort {high}} ;#Specifies the CPU effort level for coarse placements invoked in refine_opt
set_app_options -list {place_opt.final_place.effort {high}} ;#Specifies the CPU effort level for the final coarse placement invoked in place_opt

sec_StartTimer refine_opt

refine_opt ;#By running refine_opt command, you can optimize the place_opt completed db once again

sec_ReportResourceUtil refine_opt


