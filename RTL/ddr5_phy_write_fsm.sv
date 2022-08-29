/*****************************************************************************
** Company: Si-Vision & FOE ASU
** Author: AHMED MOSTAFA KAMAL , ADHAM HAZEM ALGENDI AND AHMED MOHAMED AMIN
**
** Create Date:     24/3/2022
** Edited on  :     21/4/2022
** Module Name: asu_ddr5_write_fsm
** Description: this file contains the FSM RTL, the design implementation
** is based on IEEE standard (Std 802.15.4-2011)
**
**
*****************************************************************************/

`timescale 1ns / 1ps


// Defining the module external interface (NAME ,input ports and output ports).
module ddr5_phy_write_fsm
          # (parameter pDRAM_SIZE = 4 ) //DRAM size 
(
                   //////input signals ////////////  
				   
				   
            input	wire 				clk_i    ,              // system  phy clock
	
  			input  	wire 				rst_i    ,              // system reset
		 
  			input  	wire 				enable_i ,              // system  block enable
			
  			input  	wire     			wr_en_i  ,              // write enable signal from freq ratio block 
          	
			input  	wire                preamble_valid_i   ,    // valid signal that indcates correct  preamble pattern is sent on dqs signal 
		
			input  	wire				preamble_done_i    ,    // signal that  indicates  that whole preamble pattern is sent
		
			input  	wire				postamble_done_i   ,    // signal that  indicates  that whole postamble pattern is sent on dqs bus
		
			input  	wire				interamble_done_i  ,    // signal that  indicates  that whole interamble pattern is sent ondqs bus
	  
			input  	wire				wrdata_crc_done_i  ,    // signal that  indicates  that whole data is sent on DQ bus  (MC crc support) 
		
			input  	wire                wrdata_done_i      ,    // signal that  indicates  that whole data is sent on DQ bus  (phy crc support)

			input  	wire                data_burst_done_i  ,    // signal that indicates data  is sent on DQ bus (burst length = 8)
	
			input  	wire                wrmask_done_i      ,    // signal that indicates  whole data is sent on DQ bus (data mask)
		 
			input  	wire                crc_generate_i     ,    // indicates that phy will generate crc or not
		
			input  	wire                interamble_i       ,    // indicates that if there is interamble exist
	
			input  	wire	[1: 0]		preamble_bits_i    ,    // preamble bits result from shifting preamble pattern 
		 
			input  	wire    [1:0]       interamble_bits_i  ,    // interamble bits result from shifting interamble pattern
			   
			input  	wire    [3:0]       gap_i          ,        // signal detect number of cycles at which  write enable is low 
        
			input  	wire    [2*pDRAM_SIZE  -1: 0]	wr_data_i      ,        // input wrdata from freq ratio block
			   
			input  	wire    [(pDRAM_SIZE /4-1):0]	wr_datamask_i  ,        // input data mask  from freq ratio block
		 
			input 	wire    [2*pDRAM_SIZE -1: 0]	crc_code_i     ,        // input crc data from crc block

			input 	wire    [1:0]       burstlength_i  ,        // input burstlength from command block
			   
			  /////////output signals ////////////////

			output  reg                 data_state_o     ,      // output signal indicates  to  write data states
 		
			output  reg 				preamble_state_o ,      // output signal indicates to preamble , postamble ,interamble states 
		
			output  reg  [2*pDRAM_SIZE  -1: 0]	crc_data_o       ,      // output data to crc block
		
  			output  reg  				crc_enable_o     ,      // output enable to crc block
		
			output  reg   [1:0]		    dqs_o            ,      // output data strobe to DRAM
		
  			output  reg   [2*pDRAM_SIZE  -1: 0]   dq_o             ,      // output data to DRAM
		
			output  reg     			dqs_valid_o      ,      //  output signal indicates that data strobe is sent or not
		
			output  reg 				dq_valid_o       ,      //  output signal indicates that data  is sent or not
		
			output  reg   [(pDRAM_SIZE /4-1):0]  	dm_o             ,      // output data mask to DRAM
	
			output  reg                 interamble_valid_o      // output signal indicates that interamble bits is sent ondqs bus
		
			
			 
                  
);

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// internal signals and registers


 //state defintions
 typedef enum reg [2:0] {  idle , preamble , wr_data_crc ,  wr_data , data_burst8 ,crc , postamble ,  interamble  }  state_t ;
 state_t current_state , next_state ;

reg [1:0]			dqs  ;
reg [2*pDRAM_SIZE -1 : 0] 	dq ;
reg   				dqs_valid ;
reg  				dq_valid ;
reg [(pDRAM_SIZE /4-1):0]   	dm  ; 

// state transition 		
always_ff @(posedge clk_i or negedge rst_i)
 begin
	if(!rst_i)              // Asynchronous active low reset 
	  begin
		current_state <= idle ;
	  end
   
	else if (enable_i)       // enable fsm 
	  begin	
	  current_state <= next_state ;
	  end
	  
 end
 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
 
// next_state and output logic
always_comb 
 begin
  case(current_state)
  idle : 		begin                                  
                    dq  = {(2*pDRAM_SIZE){1'b0}} ;
		            dq_valid = 1'b0 ;
			        dm = {(pDRAM_SIZE /4){1'b0}} ;			
					dqs = 2'b00 ;
					interamble_valid_o= 1'b0 ;
					dqs_valid = 1'b0 ;	
					data_state_o  = 1'b0 ;
					preamble_state_o = 1'b0 ;
			        crc_data_o = {(2*pDRAM_SIZE){1'b0}} ;
                    crc_enable_o = 1'b0 ; 
					
					if(wr_en_i)                            
					  next_state = preamble;
					else
					  next_state = idle ;			  
				end
					
					// no operation in this state, when wr_en is high move to preamble state 
					
					
			 
  preamble :	begin   
                     // preamble pattern is sent ondqs bus ,anddqs valid will be high when the correct pattern is sent 
                    dq  = {(2*pDRAM_SIZE){1'b0}};
		            dq_valid = 1'b0 ;
			        dm = {(pDRAM_SIZE /4){1'b0}} ;				      
             	    dqs = preamble_bits_i ;
				    interamble_valid_o= 1'b0 ;
			        dqs_valid = preamble_valid_i ;
				    data_state_o  = 1'b0 ;
				    preamble_state_o = 1'b1 ;
			     	crc_data_o = {(2*pDRAM_SIZE){1'b0}} ;
                    crc_enable_o = 1'b0 ;
        			
					 // when preamble is sent ondqs bus and check crc_generate_i if low then move to wr_data_crc or if crc_generate_i is high then move to wr_data 
				
                    if (  preamble_done_i && !crc_generate_i )  
					  next_state = wr_data_crc ;					 
					else if (   preamble_done_i && crc_generate_i  )
					  next_state = wr_data ;		    
					else 					 
					  next_state = preamble ;				 
				end
			    
				
				
			
  wr_data_crc  : begin                                       // (MC crc support or data mask)  
                       // wr_data from MC will be sent on dq bus with dq_valid ,dqS will be phy _clock,wrdata mask is sent on dm bus
                    dq  = wr_data_i ;
		            dq_valid = 1'b1 ;
			        dm = wr_datamask_i  ;			         
					dqs = 2'b10 ;
				    interamble_valid_o= 1'b0 ;
			        dqs_valid = 1'b1 ;	
					data_state_o  = 1'b1 ;
					preamble_state_o = 1'b0 ;
			        crc_data_o = {(2*pDRAM_SIZE){1'b0}} ;
                    crc_enable_o = 1'b0 ;
			    
				     // when data is sent on  dq bus and check i_interamble if high move to interamble state ,if low move to postamble
					if( !interamble_i && (wrdata_crc_done_i|| wrmask_done_i)  ) 
					  next_state = postamble ;        
					else if (  interamble_i &&(wrdata_crc_done_i|| wrmask_done_i)  )
					  next_state = interamble ; 					
					else 
					  next_state = wr_data_crc;	    
				 end
					
					// when data is sent on  dq bus and check interamble_i if high move to interamble state ,if low move to postamble
					
 					
					
	wr_data  :	begin                     // (phy crc support)
	                  // data will be sent on dq bus and to crc block to generate crc anddqs will be phy _clock
	                dq  = wr_data_i ;              
		            dq_valid = 1'b1 ;
			        dm = {(pDRAM_SIZE /4){1'b0}}  ;			      
			        dqs = 2'b10 ;
				    interamble_valid_o= 1'b0 ;
			        dqs_valid = 1'b1 ;	
                    crc_data_o = wr_data_i ;
                    crc_enable_o = 1'b1 ;	
				    data_state_o  = 1'b1 ;
				    preamble_state_o = 1'b0 ;
				
                    // when data is sent on dq bus and checkburstlength_i if burstlength_i = 8 ,move to data_burst8 state
					if(burstlength_i == 2'b01 && data_burst_done_i  )
					  next_state = data_burst8 ;
					else if (wrdata_done_i)
					  next_state = crc ; 
					else 
					 next_state = wr_data;	    
				end
			       

				    
					
	data_burst8  : begin           	// (i_burstlength = 8)
	
	             // rest of wr_data will be completed with ones and sent it on dq bus and crc block             
		            dq_valid = 1'b1 ;                 //(burstlength =8)
				    dq  = {(2*pDRAM_SIZE){1'b1}} ;              // rest of wr_data will be completed with ones and sent it on dq bus and crc block
			        dm = {(pDRAM_SIZE /4){1'b0}}  ;			       
					dqs = 2'b10 ;
					interamble_valid_o= 1'b0 ;
					dqs_valid = 1'b1 ;	
				    crc_data_o = {(2*pDRAM_SIZE){1'b1}} ;
                    crc_enable_o = 1'b1 ;
					data_state_o  = 1'b1 ;
					preamble_state_o= 1'b0 ;
					
					// when rest of  wr_data is sent on dq bus move to crc state
					if(wrdata_done_i  )
					  next_state = crc ;
					else 
					  next_state = data_burst8;	    
				  end
				   
				   
				   
	crc      :   begin            	// (phy crc support)
	                // crc code is taken from crc block and sent it after data on dq bus
                    // sends interamble_valid to shift register to shift interamble pattern
	                dq  = crc_code_i ;            				 
		            dq_valid = 1'b1 ;
			        dm = {(pDRAM_SIZE /4){1'b0}} ;			    
			        dqs = 2'b10 ;
				    interamble_valid_o = 1'b1 ;       
			        dqs_valid = 1'b1 ;	
				    crc_data_o = {(2*pDRAM_SIZE){1'b0}} ;
				    crc_enable_o = 1'b1 ;
				    data_state_o  = 1'b0 ;
			    	preamble_state_o = 1'b0 ;
	
                   // check interamble_i if high move to interamble state ,if not move to postamble state	
					if (gap_i ==3'b001 )
					  next_state = wr_data ; 
					else if (interamble_i)
					  next_state = interamble ;
					else 
					  next_state = postamble ;					                    
				end		
				 	
					
					
  postamble     : begin    
                         // postaamble pattern is sent ondqs bus 
                    dq  = {(2*pDRAM_SIZE){1'b0}} ; 
		            dq_valid = 1'b0 ;
			        dm = {(pDRAM_SIZE /4){1'b0}}  ;			    
			        dqs = 2'b00 ;
				    interamble_valid_o= 1'b1 ;
			        dqs_valid = 1'b1 ;	
				    crc_data_o = {(2*pDRAM_SIZE){1'b0}} ;
                    crc_enable_o = 1'b0 ;	
				    data_state_o  = 1'b0 ;
				    preamble_state_o = 1'b0 ;
					 
					  // when postamble pattern is sent ondqs bus , check wr_en_i if high move to preamble state ,if low move to idle
					if (postamble_done_i && !wr_en_i)
					  next_state =idle ;
					else if (  postamble_done_i && wr_en_i  )
					  next_state = preamble ;					
					else 
					  next_state = postamble;	
				end
                      
					
					
   interamble   :begin    
                          // interamble pattern is sent ondqs bus
                    dq  = {(2*pDRAM_SIZE){1'b0}} ;
		            dq_valid = 1'b0 ;
			        dm = {(pDRAM_SIZE /4){1'b0}}  ;
			        dqs =  interamble_bits_i ;
				    interamble_valid_o= 1'b1 ;
			        dqs_valid = 1'b1 ;
					crc_data_o = {(2*pDRAM_SIZE){1'b0}} ;                    
					data_state_o  = 1'b0 ;
					preamble_state_o = 1'b0 ;
					crc_enable_o = 1'b0 ;
					   // when interamble pattern is ent ondqs ,check crc_generate_i if low then move to wr_data_crc , if crc_generate_i is high then move to wr_data 
			
					if (interamble_done_i&&crc_generate_i)
					  next_state = wr_data ;					
					else if (interamble_done_i&&!crc_generate_i)					
					  next_state = wr_data_crc ;				 
					else   					
					  next_state = interamble;				

				end
                
		  
   default : begin			 
					dq_valid = 1'b0 ;
					dm = {(pDRAM_SIZE /4){1'b0}}  ;
					dqs = 2'b00; 
					interamble_valid_o= 1'b0 ;
					dqs_valid = 1'b0 ;	
					crc_enable_o = 1'b0 ;				
					next_state = idle ; 		 
             end
    endcase
  
 end	

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 

// registered output 		
always_ff @(posedge clk_i or negedge rst_i)
  begin
	if(!rst_i)              // Asynchronous active low reset 
	  begin
		dq_o <= {(2*pDRAM_SIZE){1'b0}} ;
		dqs_o <= 2'b00 ;
		dq_valid_o <= 1'b0;
        dqs_valid_o <=1'b0  ;
       	dm_o <= 	{(pDRAM_SIZE /4){1'b0}}  ;
	  end
   
	else if (enable_i)       // enable fsm 
	  begin	
	    dq_o <= dq ;
		dqs_o <=dqs ;
		dq_valid_o  <= dq_valid ;
        dqs_valid_o <=dqs_valid  ;
       	dm_o <= dm;
	  end
 end
	  

endmodule 









