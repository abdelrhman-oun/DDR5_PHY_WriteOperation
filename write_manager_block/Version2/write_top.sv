module write_manager
     # (parameter N =4 ) //DRAM size 
(
			input wire					i_clk ,
  			input wire					i_rst ,
			input wire					i_enable ,
			
  			
  
  			 
  			
			 input wire					i_wr_en,
			 input wire    				i_phy_crc_mode ,
			 input wire    				i_DRAM_crc_en ,
			 input wire [1:0]      i_burstlength,
			 input wire     [2:0]              i_precycle,
			 input wire     [1:0]              i_postcycle,
			 
			 input wire 	[2*N -1: 0]		i_Wr_data ,
			 input wire		[(N/4-1):0]	i_Wr_datamask ,
			 
			 input wire [7: 0]		i_pre_pattern ,
			 
			 input wire [2*N -1: 0]    i_crc_code ,
			 
			 output reg[2*N -1: 0] 			o_DQ ,

			 output reg 					o_DQ_valid ,
			 output reg    [(N/4-1):0]   			o_DM ,			 
			 output reg[1:0]		o_DQS ,
			 output reg    			    o_DQS_valid ,
			 output reg [2*N-1: 0]			o_crc_data,
			 output reg    			    o_crc_enable  
);

reg	preamble_valid ;
reg	preamble_done  ;				  
reg	postamble_done ;			 
reg	interamble_done ;			   
reg	wrdata_crc_done ;			   
reg	wrdata_done ;			 
reg	data_burst_done ;			 
reg	wrmask_done ;					   
reg	crc_generate ; 			  
reg	interamble ;			   
reg	[1:0] preamble_bits ;			 
reg	[1:0] interamble_bits ;			 
reg	[3:0] gap ; 
reg	interamble_valid ;
reg	[2:0] interamble_shift ; 
reg preamble_load ;
reg post ;
reg data_state ; 
reg gap_done ; 
			
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


.o_data_state  (data_state) ,
.o_post     (post)        ,

.i_burstlength (i_burstlength),
.o_crc_data (o_crc_data),			 
.o_crc_enable (o_crc_enable),			 
.o_DQS (o_DQS),			 
.o_DQ (o_DQ),			 
.o_DQS_valid (o_DQS_valid) ,			 
.o_DQ_valid (o_DQ_valid),			 
.o_DM  (o_DM),			 
.o_interamble_valid (interamble_valid)	 			 

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
.i_data_state  (data_state)             ,
.i_post         (post)            ,
.i_interamble_valid (interamble_valid)          ,


.o_preamble_load (preamble_load),	
.o_preamble_valid (preamble_valid) ,	
.o_preamble_done  (preamble_done) ,	
.o_postamble_done (postamble_done) ,
.o_interamble_done (interamble_done) ,
.o_data_burst_done (data_burst_done) ,
.o_wrdata_done    (wrdata_done) ,
.o_wrmask_done    (wrmask_done) ,
.o_interamble     (interamble) ,
.o_gap_done(gap_done) ,
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
.i_gap_done (gap_done),
.o_interamble_bits  (interamble_bits) ,
.o_preamble_bits (preamble_bits) ,
.o_gap (gap)


);



endmodule













