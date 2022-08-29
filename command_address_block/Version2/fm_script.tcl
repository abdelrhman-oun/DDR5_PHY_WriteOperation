
########################## Define Top module #################################
  
set top_module COMMAND_ADDRESS
                                                   
################## Design Compiler Library Files #setup ######################

puts "###########################################"
puts "#      setting Design Libraries & RTLS    #"
puts "###########################################"

#Add the path of the libraries to the search_path variable
set lib_file /home/IC/tsmc_fb_cl013g_sc/aci/sc-m/synopsys/scmetro_tsmc_cl013g_rvt_ss_1p08v_125c.db

# add here the path of RTL and premapped files
set rtl_file /home/IC/oun_folder/CA_project_version2_new/code/RTL/COMMAND_ADDRESS.sv

# add here the path of RTL and mapped files result from synthesis
set rtl_synth_file /home/IC/oun_folder/CA_project_version2_new/synthesis/work/COMMAND_ADDRESS.v




######################## Reading RTL Files #################################

puts "###########################################"
puts "#       Reading RTL Files & libraries     #"
puts "###########################################"


read_sverilog -container r -libname WORK -12 ${rtl_file} 

set_top r:/WORK/$top_module 

read_db -container i ${lib_file} 


read_verilog -container i -libname WORK -01 ${rtl_synth_file}

set_top i:/WORK/$top_module



puts "###############################################"
puts "######### verify all the design parts #########"
puts "###############################################"


match

puts "###############################################"
puts "######### verify all the design parts #########"
puts "###############################################"

verify 

############################### Reporting ##################################

# Report unmatched points
report_unmatched_points > ./report_unmatched_points.rpt

# Report passing points
report_passing_points > ./passing_points.rpt 

# Report failing points
report_failing_points > ./failing_points.rpt 



#exit
