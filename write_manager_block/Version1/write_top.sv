module write_manager
     # (parameter N =4 ) //DRAM size 
(
			input logic 					i_clk ,
  			input logic 					i_rst ,
			input logic 					i_enable ,
			
  			
  
  			 
  			
			 input logic 					i_wr_en,
			 input logic     				i_phy_crc_mode ,
			 input logic     				i_DRAM_crc_en ,
			 input logic  [1:0]      i_burstlength,
			 input logic      [2:0]              i_precycle,
			 input logic      [1:0]              i_postcycle,
			 
			 input logic  	[2*N -1: 0]		i_Wr_data ,
			 input logic  		[(N/4-1):0]	i_Wr_datamask ,
			 
			 input logic  [7: 0]		i_pre_pattern ,
			 input logic  [3:0]       i_post_pattern ,
			 input logic  [2*N -1: 0]    i_crc_code ,
			 
			 output logic [2*N -1: 0] 			o_DQ ,

			 output logic  					o_DQ_valid ,
			 output logic     [(N/4-1):0]   			o_DM ,			 
			 output logic [1:0]		o_DQS ,
			 output logic     			    o_DQS_valid ,
			 output logic  [2*N-1: 0]			o_crc_data,
			 output logic     			    o_crc_enable  
);

logic	preamble_valid ;
logic	preamble_done  ;				  
logic	postamble_done ;			 
logic	interamble_done ;			   
logic	wrdata_crc_done ;			   
logic	wrdata_done ;			 
logic	data_burst_done ;			 
logic	wrmask_done ;					   
logic	crc_generate ; 			  
logic	interamble ;			   
logic	[1:0] preamble_bits ;			 
logic	[1:0] interamble_bits ;			 
logic	[2:0] gap ; 
logic	interamble_valid ;			 			 
logic	[2:0] fsm_state ;
logic	[2:0] interamble_shift ; 
logic preamble_load ;



 write_fsm U0 (
.i_clk  (i_clk),				  
.i_rst (i_rst),				  
.i_enable (i_enable) ,					
.i_wr_en (i_wr_en),					
.i_preamble_valid (preamble_valid),				 
.i_preamble_done (preamble_done),				  
.i_postamble_done  (postamble_done) ,			 
.i_interamble_done  (interamble_done) ,		   
.i_wrdata_crc_done   (wrdata_crc_done),			   
.i_wrdata_done   (wrdata_done) ,			 
.i_data_burst_done  (data_burst_done) ,			 
.i_wrmask_done  (wrmask_done) ,					   
.i_crc_generate  (crc_generate) , 			  
.i_interamble (interamble),			   
.i_preamble_bits (preamble_bits)  ,			 
.i_interamble_bits (interamble_bits) ,			 
.i_gap   (gap) , 			  
.i_Wr_data (i_Wr_data) ,			 
.i_Wr_datamask (i_Wr_datamask),			 
.i_crc_code (i_crc_code)  , 


	 
.i_burstlength (i_burstlength),
.o_crc_data (o_crc_data),			 
.o_crc_enable (o_crc_enable),			 
.o_DQS (o_DQS),			 
.o_DQ (o_DQ),			 
.o_DQS_valid (o_DQS_valid) ,			 
.o_DQ_valid (o_DQ_valid),			 
.o_DM  (o_DM),			 
.o_interamble_valid (interamble_valid),			 			 
.o_fsm_state (fsm_state)
);


write_counters U1 (


.i_clk (i_clk),
.i_rst  (i_rst),
.i_wr_en   (i_wr_en)      ,
.i_phy_crc_mode (i_phy_crc_mode) ,
.i_dram_crc_en   (i_DRAM_crc_en),
.i_precycle    (i_precycle)  ,
.i_postcycle    (i_postcycle) ,
.i_gap      (gap)     ,
.i_burstlength   (i_burstlength),
.i_fsm_state  (fsm_state)   ,

.o_preamble_load (preamble_load),	
.o_preamble_valid (preamble_valid) ,	
.o_preamble_done  (preamble_done) ,	
.o_postamble_done (postamble_done) ,
.o_interamble_done (interamble_done) ,
.o_data_burst_done (data_burst_done) ,
.o_wrdata_done    (wrdata_done) ,
.o_wrmask_done    (wrmask_done) ,
.o_interamble     (interamble) ,
.o_crc_generate   (crc_generate) ,
.o_interamble_shift  (interamble_shift) ,
.o_wrdata_crc_done (wrdata_crc_done)
  	

);

write_shift U2 (

.i_clk (i_clk) ,
.i_rst  (i_rst),
.i_wr_en (i_wr_en),
.i_pre_pattern (i_pre_pattern),
.i_interamble_valid (interamble_valid)  ,
.i_interamble_shift  (interamble_shift) ,
.i_preamble_valid  (preamble_valid) ,
.i_preamble_load (preamble_load),

.o_interamble_bits  (interamble_bits) ,
.o_preamble_bits (preamble_bits) ,
.o_gap (gap)


);



endmodule












