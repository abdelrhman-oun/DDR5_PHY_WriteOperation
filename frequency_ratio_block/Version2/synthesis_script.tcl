######################## Define Top module ########################

set top_module FREQUENCY_RATIO

################ Design Compiler Library Files setup #####################

puts "#####################################" 
puts "#		setting design libraries      #"
puts "#####################################"

#Add the path of the libraries to the search_path variable
lappend search_path /home/IC/tsmc_fb_cl013g_sc/aci/sc-m/synopsys

#Adding the path of the RTL to the search_path variable
lappend search_path /home/IC/Projects/FREQUENCY_RATIO/RTL

set SSLIB "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c.db"
set TTLIB "scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.db"
set FFLIB "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c.db"

## Standard cell libraries
set target_library [list $SSLIB $TTLIB $FFLIB]

## Standard cell & Hard Macros libraries
set link_library [list * $SSLIB $TTLIB $FFLIB]

######################## Reading RTL Files ########################

puts "#####################################" 
puts "#		    Reading RTL Files         #"
puts "#####################################"

set file_format sverilog

read_file -format $file_format FREQUENCY_RATIO_RTL.sv






#################### Defining toplevel ######################

current_design $top_module

######################## Linking All the Design parts ########################
puts "##############################################" 
puts "#       Linking All the Design parts         #"
puts "##############################################"

link


######################## Checking the Design Consistency ########################
puts "##############################################" 
puts "#      Checking the Design Consistency       #"
puts "##############################################"

check_design



######################## Design Constraints ########################
puts "##############################################" 
puts "#            Design Constraints              #"
puts "##############################################"


#Clock_Definition

set CLK_NAME i_clock
set CLK_PER 2.1
set CLK_SETUP_SKEW 0.2
set CLK_HOLD_SKEW 0.1
set CLK_LAT 0.0
set CLK_RISE 0.05
set CLK_FALL 0.05

create_clock -name $CLK_NAME -period $CLK_PER -waveform "0 [expr $CLK_PER/2]" [get_ports $CLK_NAME]
set_clock_uncertainty -setup $CLK_SETUP_SKEW [get_clocks $CLK_NAME]
set_clock_uncertainty -hold $CLK_HOLD_SKEW [get_clocks $CLK_NAME]
set_clock_transition -rise $CLK_RISE [get_clocks $CLK_NAME]
set_clock_transition -fall $CLK_FALL [get_clocks $CLK_NAME]
set_clock_latency $CLK_LAT [get_clocks $CLK_NAME]


#Operating_Condition

#Define the worst library for Max(setup) analysis
#Define the best library for Min(hold) analysis

set_operating_conditions -min_library "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c" -min "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c" -max_library "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c" -max "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c"

set compile_seqmap_propagate_constants false


#Wieload Model

set_wire_load_model -name tsmc13_wl30 -library scmetro_tsmc_cl013g_rvt_ss_1p08v_125c



######################## Mapping & Optimization ########################
puts "##############################################" 
puts "#          Mapping & Optimization            #"
puts "##############################################"

compile

######################## sace SDC file after compilation ########################

write_sdc -nosplit ./${top_module}.sdc


puts "############################################################################" 
puts "#          checking that all the cells in the design are mapped            #"
puts "############################################################################"


check_design -unmapped > ./check_mapped_design_post_compile.rpt


######################## Check Timing Constraints ########################

check_timing -multiple_clock > ./check_timing.rpt



#write out design after initial compile

write_file -format ddc -hierarchy -output ./${top_module}.ddc
write_file -format verilog -hierarchy -output ./${top_module}.v


######################## REPORTS ########################


#report dynamic and static power
report_power > ./power.rpt


report_port -verbose > ./port_info.rpt

report_clock -attributes > ./clock_info.rpt

report_constraint -all_violators -nosplit > ./constraints.rpt

report_timing -max_paths 20 -delay_type max -nosplit > ./timing_max.rpt
report_timing -max_paths 20 -delay_type min -nosplit > ./timing_min.rpt

report_hierarchy -nosplit -full > ./hierarchy.rpt

report_area > ./area.rpt


######################## starting graphical user interface ########################


gui_start


