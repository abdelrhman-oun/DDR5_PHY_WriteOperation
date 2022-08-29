/*********************************************************************************
** Company: Si-Vision & FOE ASU
** Author: AHMED MOSTAFA KAMAL and ADHAM HAZEM ALGENDI
**
** Create Date:     24/3/2022
** Module Name: COUNTER MODULE
** Description: this file contains the COUNTER RTL, the design implementation
** is based on IEEE standard (Std 802.15.4-2011)
**
**
*********************************************************************************/


// Defining the module external interface (NAME ,input ports and output ports).
module asu_ddr5_write_manager
     # (parameter pDRAM_SIZE =4 ) //DRAM size 
(
				//////input signals ////// 

			input wire						clk_i ,
  			input wire						rst_i ,
			input wire						enable_i ,
			input wire						wr_en_i,
			input wire    					phy_crc_mode_i ,
			input wire                      dram_crc_en_i ,
			input wire		[1:0]           burstlength_i,
			input wire     	[2:0]           precycle_i,
			input wire     	[1:0]           postcycle_i,
			input wire 		[2*pDRAM_SIZE  -1: 0]		wr_data_i ,
			input wire		[(pDRAM_SIZE /4-1):0]		wr_datamask_i ,
			input wire 		[7:0]			pre_pattern_i ,
			input wire 		[2*pDRAM_SIZE  -1: 0]    	crc_code_i ,
			 
			 
			 
				//////output signals //////
			output reg		[2*pDRAM_SIZE  -1:0] 	    dq_o ,
			output reg 						dq_valid_o ,
			output reg    	[(pDRAM_SIZE /4-1):0]   	dm_o ,			 
			output reg		[1:0]			dqs_o ,
			output reg    			    	dqs_valid_o ,
			output reg  	[2*pDRAM_SIZE -1:0]			crc_data_o,
			output reg    			    	crc_enable_o  
);


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// internal signals and registers
reg			preamble_valid   ;
reg			preamble_done    ;				  
reg			postamble_done   ;			 
reg			interamble_done  ;			   
reg			wrdata_crc_done  ;			   
reg			wrdata_done ;			 
reg			data_burst_done  ;			 
reg			wrmask_done ;					   
reg			crc_generate ; 			  
reg			interamble ;			   
reg	[1:0] 	preamble_bits ;			 
reg	[1:0] 	interamble_bits  ;			 
reg	[3:0] 	gap ; 
reg			interamble_valid ;
reg	[2:0] 	interamble_shift ; 
reg 		preamble_load ;
reg 		preamble_state  ;
reg 		data_state ; 
reg 		gap_burst_eight ; 

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
asu_ddr5_write_fsm #( .pDRAM_SIZE(pDRAM_SIZE)

)write_fsm_U (
 
			//////input signals ////// 
.clk_i  			(clk_i),				  
.rst_i 				(rst_i),				  
.enable_i 			(enable_i) ,					
.wr_en_i 			(wr_en_i),					
.preamble_valid_i 	(preamble_valid),				 
.preamble_done_i 	(preamble_done),				  
.postamble_done_i  	(postamble_done) ,			 
.interamble_done_i  (interamble_done) ,		   
.wrdata_crc_done_i  (wrdata_crc_done),			   
.wrdata_done_i   	(wrdata_done) ,			 
.data_burst_done_i  (data_burst_done) ,			 
.wrmask_done_i  	(wrmask_done) ,					   
.crc_generate_i  	(crc_generate) , 			  
.interamble_i 		(interamble),			   
.preamble_bits_i 	(preamble_bits)  ,			 
.interamble_bits_i 	(interamble_bits) ,			 
.gap_i   			(gap) , 			  
.wr_data_i 			(wr_data_i) ,			 
.wr_datamask_i 		(wr_datamask_i),			 
.crc_code_i 		(crc_code_i)  , 
.burstlength_i 		(burstlength_i),

			//////output signals //////
.data_state_o  		(data_state) ,
.preamble_state_o	(preamble_state )        ,
.crc_data_o 		(crc_data_o),			 
.crc_enable_o 		(crc_enable_o),			 
.dqs_o 				(dqs_o),			 
.dq_o 				(dq_o),			 
.dqs_valid_o 		(dqs_valid_o) ,			 
.dq_valid_o 		(dq_valid_o),			 
.dm_o  				(dm_o),			 
.interamble_valid_o (interamble_valid)	 			 

);

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
asu_ddr5_write_counters wirte_counters_U (

			//////input signals ////// 
.clk_i 				(clk_i),
.rst_i  			(rst_i),
.wr_en_i   			(wr_en_i)      ,
.phy_crc_mode_i 	(phy_crc_mode_i) ,
.dram_crc_en_i   	(dram_crc_en_i),
.precycle_i    		(precycle_i)  ,
.postcycle_i    	(postcycle_i) ,
.gap_i      		(gap)     ,
.burstlength_i   	(burstlength_i),
.data_state_i  		(data_state)   ,
.preamble_state_i   (preamble_state )  ,
.interamble_valid_i (interamble_valid)  ,

			//////output signals //////
.preamble_load_o 	(preamble_load),	
.preamble_valid_o	(preamble_valid) ,	
.preamble_done_o  	(preamble_done) ,	
.postamble_done_o 	(postamble_done) ,
.interamble_done_o 	(interamble_done) ,
.data_burst_done_o 	(data_burst_done) ,
.wrdata_done_o    	(wrdata_done) ,
.wrmask_done_o    	(wrmask_done) ,
.interamble_o     	(interamble) ,
.gap_burst_eight_o	(gap_burst_eight) ,
.crc_generate_o   	(crc_generate) ,
.interamble_shift_o (interamble_shift) ,
.wrdata_crc_done_o 	(wrdata_crc_done)
  	

);


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
asu_ddr5_write_shift write_shift_U (

			//////input signals ////// 
.clk_i 				(clk_i) ,
.rst_i  			(rst_i),
.wr_en_i 			(wr_en_i),
.pre_pattern_i 		(pre_pattern_i),
.interamble_valid_i (interamble_valid)  ,
.interamble_shift_i (interamble_shift) ,
.preamble_valid_i  	(preamble_valid) ,
.preamble_load_i 	(preamble_load),
.gap_burst_eight_i 	(gap_burst_eight),

			//////output signals //////
.interamble_bits_o  (interamble_bits) ,
.preamble_bits_o 	(preamble_bits) ,
.gap_o 				(gap)


);

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
endmodule













