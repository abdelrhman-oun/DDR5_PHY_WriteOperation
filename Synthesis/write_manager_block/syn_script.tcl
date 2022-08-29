
########################## Define Some Variables ############################
  
set top_module write_manager
                                                   
################## Design Compiler Library Files #setup ######################

puts "###########################################"
puts "#      #setting Design Libraries           #"
puts "###########################################"

#Add the path of the libraries to the search_path variable
lappend search_path /home/IC/tsmc_fb_cl013g_sc/aci/sc-m/synopsys

# append here the path of RTL and premapped files
lappend search_path /home/IC/write_data/RTL 

set SSLIB "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c.db"
set TTLIB "scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.db"
set FFLIB "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c.db"

## Standard Cell libraries 
set target_library [list $SSLIB $TTLIB $FFLIB]

## Standard Cell & Hard Macros libraries 
set link_library [list * $SSLIB $TTLIB $FFLIB]  

######################## Reading RTL Files #################################

puts "###########################################"
puts "#             Reading RTL Files           #"
puts "###########################################"

set file_format sverilog

read_file -format $file_format write_counter.sv
read_file -format $file_format write_fsm.sv
read_file -format $file_format write_shift.sv
read_file -format $file_format write_top.sv


#read here the RTL files and read system_top.v the last one

#read_file -format $file_format UP_DN_Counter.v




###################### Defining toplevel ###################################

###################### Defining toplevel ###################################

current_design $top_module

#################### Liniking All The Design Parts #########################
puts "###############################################"
puts "######## Liniking All The Design Parts ########"
puts "###############################################"

link 

#################### Liniking All The Design Parts #########################
puts "###############################################"
puts "######## checking design consistency ##########"
puts "###############################################"

check_design

###################### Design constraints ############################
puts "###############################################"
puts "############# Design Constraints ##############"
puts "###############################################"

# Constraints
# ----------------------------------------------------------------------------
#
# 1. Master Clock Definitions
#
# 2. Generated Clock Definitions
#
# 3. Clock Uncertainties
#
# 4. Clock Latencies 
#
# 5. Clock Relationships
#
# 6. #set input/output delay on ports
#
# 7. Driving cells
#
# 8. Output load

####################################################################################
           #########################################################
                  #### Section 1 : Clock Definition ####
           #########################################################
#################################################################################### 
# 1. Master Clock Definitions 
# 2. Generated Clock Definitions
# 3. Clock Latencies
# 4. Clock Uncertainties
# 4. Clock Transitions
####################################################################################

set CLK_NAME i_clk
set CLK_PER 5.0
set CLK_SETUP_SKEW 0.2
set CLK_HOLD_SKEW 0.1
set CLK_LAT 0.0
set CLK_RISE 0.05
set CLK_FALL 0.05

create_clock -name $CLK_NAME -period $CLK_PER -waveform "0 [expr $CLK_PER/2]" [get_ports $CLK_NAME]
set_clock_uncertainty -setup $CLK_SETUP_SKEW [get_clocks $CLK_NAME]
set_clock_uncertainty -hold $CLK_HOLD_SKEW  [get_clocks $CLK_NAME]
set_clock_transition -rise $CLK_RISE  [get_clocks $CLK_NAME]
set_clock_transition -fall $CLK_FALL  [get_clocks $CLK_NAME]
set_clock_latency $CLK_LAT [get_clocks $CLK_NAME]

####################################################################################
           #########################################################
                  #### Section 2 : Clocks Relationships ####
           #########################################################
####################################################################################



####################################################################################
           #########################################################
             #### Section 3 : #set input/output delay on ports ####
           #########################################################
####################################################################################

#set in_delay  [expr 0.2*$CLK_PER]
#set out_delay [expr 0.2*$CLK_PER]

#Constrain Input Paths
#set_input_delay $in_delay -clock $CLK_NAME [get_port i_reset]
#set_input_delay $in_delay -clock $CLK_NAME [get_port i_enable]
#set_input_delay $in_delay -clock $CLK_NAME [get_port dfi_address]
#set_input_delay $in_delay -clock $CLK_NAME [get_port dfi_cs_n]

#Constrain Output Paths
#set_output_delay $out_delay -clock $CLK_NAME [get_port CS_n]
#set_output_delay $out_delay -clock $CLK_NAME [get_port CA]
#set_output_delay $out_delay -clock $CLK_NAME [get_port burst_length]
#set_output_delay $out_delay -clock $CLK_NAME [get_port pre_pattern]
#set_output_delay $out_delay -clock $CLK_NAME [get_port pre_cycle]
#set_output_delay $out_delay -clock $CLK_NAME [get_port post_pattern]
#set_output_delay $out_delay -clock $CLK_NAME [get_port post_cycle]
#set_output_delay $out_delay -clock $CLK_NAME [get_port DRAM_CRC_en]

####################################################################################
           #########################################################
                  #### Section 4 : Driving cells ####
           #########################################################
####################################################################################

#set_driving_cell -library scmetro_tsmc_cl013g_rvt_ss_1p08v_125c -lib_cell BUFX2M -pin Y [get_port i_reset]
#set_driving_cell -library scmetro_tsmc_cl013g_rvt_ss_1p08v_125c -lib_cell BUFX2M -pin Y [get_port i_enable]
#set_driving_cell -library scmetro_tsmc_cl013g_rvt_ss_1p08v_125c -lib_cell BUFX2M -pin Y [get_port dfi_address]
#set_driving_cell -library scmetro_tsmc_cl013g_rvt_ss_1p08v_125c -lib_cell BUFX2M -pin Y [get_port dfi_cs_n]

####################################################################################
           #########################################################
                  #### Section 5 : Output load ####
           #########################################################
####################################################################################

#set_load 75 [get_port CS_n]
#set_load 75 [get_port CA]
#set_load 75 [get_port burst_length]
#set_load 75 [get_port pre_pattern]
#set_load 75 [get_port pre_cycle]
#set_load 75 [get_port post_pattern]
#set_load 75 [get_port post_cycle]
#set_load 75 [get_port DRAM_CRC_en]

####################################################################################
           #########################################################
                 #### Section 6 : Operating Condition ####
           #########################################################
####################################################################################

# Define the Worst Library for Max(#setup) analysis
# Define the Best Library for Min(hold) analysis

set_operating_conditions -min_library "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c" -min "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c" -max_library "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c" -max "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c"

set compile_seqmap_propagate_constants false

####################################################################################
           #########################################################
                  #### Section 7 : wireload Model ####
           #########################################################
####################################################################################

set_wire_load_model -name tsmc13_wl30 -library scmetro_tsmc_cl013g_rvt_ss_1p08v_125c

####################################################################################
           #########################################################
                #### Section 8 : Area  ####
           #########################################################
####################################################################################

#set_max_area 0

####################################################################################
           #########################################################
                #### Section 9 : power  ####
           #########################################################
####################################################################################


###################### Mapping and optimization ########################
puts "###############################################"
puts "########## Mapping & Optimization #############"
puts "###############################################"

compile

################## Save SDC file After compilation ########################

write_sdc -nosplit ./${top_module}.sdc

puts "########## checks the design after compilation to ensure that all ##########"
puts "########## the cells in the design is mapped to Tech library cells #########"
puts "####### and these kind of check is meaningless before compilation step #####"

check_design  -unmapped > ./check_mapped_design_post_compile.rpt

##################### Check Timing Constraints ############################

puts "###### To check for constraint problems such as undefined clocking, ######"  
puts "#### undefined input arrival times, and undefined output constraints #####"

check_timing -multiple_clock > ./check_timing.rpt

#############################################################################
# Write out Design after initial compile
#############################################################################

write_file -format ddc -hierarchy -output ./${top_module}.ddc
write_file -format verilog -hierarchy -output ./${top_module}.v

############################### Reporting ##################################

#  reports dynamic and static power for the design or instance.
report_power > ./power.rpt

# Displays information about all ports showing the drive capability of input and inout ports.
report_port -verbose > ./port_info.rpt

# Check clocks information
report_clock -attributes > ./clock_info.rpt

# Report constraints.
report_constraint -all_violators -nosplit > ./constraints.rpt

# Report worst #setup analysis paths 
# -net to include nets delays in the report
# -max_paths Specifies the number of paths to report per path group 
report_timing -max_paths 20 -delay_type max -nosplit > ./timing_max.rpt
report_timing -max_paths 20 -delay_type min -nosplit > ./timing_min.rpt

# Report hierarchy
report_hierarchy -nosplit -full > ./hierarchy.rpt

# Report area
report_area > ./area.rpt


################# starting graphical user interface #######################

gui_start

#exit
