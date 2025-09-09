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


