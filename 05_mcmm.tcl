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

