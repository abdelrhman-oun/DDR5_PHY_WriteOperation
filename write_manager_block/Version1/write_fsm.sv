//////////////////////////////////////////////////////////////////////////////////
// Company: Si-Vision & FOE ASU
// Author: AHMED MOSTAFA KAMAL , ADHAM HAZEM ALGENDI AND AHMED MOHAMED AMIN
//
// Create Date:     24/3/2022
// Module Name: COUNTER MODULE
// Description: this file contains the COUNTER RTL, the design implementation
// is based on IEEE standard (Std 802.15.4-2011)
//
//
/////////////////////////////////////////////////////////////////////////////////


// Defining the module external interface (NAME ,input ports and output ports).
module write_fsm
          # (parameter N =4 ) //DRAM size 
(
                   //////input signals ////////////  
				   
				   
            input logic 					i_clk ,                       // system  phy clock
			     				  
  			input logic 					i_rst ,                       // system reset
			     				  
  			input logic 					i_enable ,                    // system  block enable
			     					
  			input logic     				i_wr_en ,                     // write enable signal from freq ratio block 
                					
			input  logic                    i_preamble_valid ,            // valid signal that indcates correct  preamble pattern is sent on DQS signal 
			    				 
			input logic					    i_preamble_done ,             // signal that  indicates  that whole preamble pattern is sent
			    				 
			input logic					    i_postamble_done ,            // signal that  indicates  that whole postamble pattern is sent on DQS bus
			    			 
			input logic					    i_interamble_done ,           // signal that  indicates  that whole interamble pattern is sent on DQS bus
			    			   
			input logic					    i_wrdata_crc_done ,           // signal that  indicates  that whole data is sent on DQ bus  (MC crc support) 
			     
			input logic                     i_wrdata_done ,               // signal that  indicates  that whole data is sent on DQ bus  (phy crc support)
			    			 
			input logic                     i_data_burst_done ,           // signal that indicates data  is sent on DQ bus (burst length = 8)
			    			 
			input logic                     i_wrmask_done ,               // signal that indicates  whole data is sent on DQ bus (data mask)
			    					   
			input logic                     i_crc_generate ,              // indicates that phy will generate crc or not
			  			      
			input logic                     i_interamble ,                // indicates that if there is interamble exist
			 			  
			input logic    [1: 0]		    i_preamble_bits ,             // preamble bits result from shifting preamble pattern 
			 			     			  
			input logic    [1:0]            i_interamble_bits ,          // interamble bits result from shifting interamble pattern
			   
			input logic    [2:0]            i_gap ,                      // signal detect number of cycles at which  write enable is low 
             			 
			input logic    [2*N -1: 0]		 i_Wr_data ,                // input wrdata from freq ratio block
			   
			input logic    [(N/4-1):0]		 i_Wr_datamask ,           // input data mask  from freq ratio block
			      
			input logic  	[2*N-1: 0]		 i_crc_code ,              // input crc data from crc block
			     			  
			input logic     [1:0]            i_burstlength,           // input burstlength from command block
			     
			   
			   
			  /////////output signals ////////////////
			  
			 output logic  [2*N -1: 0]		o_crc_data ,             // output data to crc block
			      			 
  			 output logic  					o_crc_enable ,           // output enable to crc block
			 			 
			 output logic  [1:0]		    o_DQS ,                  // output data strobe to DRAM
			      			 
  			 output logic   [2*N -1: 0]    o_DQ ,                    // output data to DRAM
			      			 
			 output logic     			   o_DQS_valid ,            // signal indicates that data strobe is sent or not
			      			 
			 output logic  					o_DQ_valid ,            // signal indicates that data  is sent or not
			      			 
			 output logic   [(N/4-1):0]   	o_DM ,                  // output data mask to DRAM
			       			 
			 output logic                   o_interamble_valid ,	// output signal indicates that interamble bits is sent on DQS signal
			   							
			output logic    [2:0]			o_fsm_state             // output from fsm that indicates  to current state 
			 
                  
);

 //state defintions
 typedef enum logic [2:0] {  idle , preamble , wr_data_crc ,  wr_data , data_burst8 ,crc , postamble ,  interamble  }  state_t ;
 state_t current_state , next_state ;



// state transition 		
always_ff @(posedge i_clk or negedge i_rst)
  begin
	if(!i_rst)              // Asynchronous active low reset 
	  begin
		current_state <= idle ;
	  end
   
	else if (i_enable)       // enable fsm 
	  begin	
	  current_state <= next_state ;
	 
	  end
 end
 
 
 
// next_state logic
always_comb 
 begin
  case(current_state)
  idle : 			begin                                    
					if(i_wr_en)                            
					next_state = preamble;
					else
					next_state = idle ;			  
					end
					
					// no operation in this state, when wr_en is high move to preamble state 
					
					
			 
  preamble :		begin                                                                                               
                     if ( i_preamble_done && !i_crc_generate )   
					 next_state = wr_data_crc ;
					 
					 else if (  i_preamble_done && i_crc_generate  )
					  next_state = wr_data ;
					  
					  else 
					  next_state = preamble ;
					end
			    // when preamble is sent on DQS bus and check i_crc_generate if low then move to wr_data_crc or if i_crc_generate is high then move to wr_data 
				
				
			
  wr_data_crc  :  begin                     // (MC crc support or data mask)  
  
					if( !i_interamble && (i_wrdata_crc_done||i_wrmask_done)  ) 
					next_state = postamble ;        

					 else if (  i_interamble &&(i_wrdata_crc_done||i_wrmask_done)  )
					  next_state = interamble ; 					
					else 
					next_state = wr_data_crc;	    
					end
					
					// when data is sent on  DQ bus and check i_interamble if high move to interamble state ,if low move to postamble
					
 					
					
	wr_data  :	 begin                     // (phy crc support)
	
					if( i_burstlength == 2'b01 && i_data_burst_done  )
					next_state = data_burst8 ;

					 else if ( i_wrdata_done)
					  next_state = crc ; 
					
					else 
					next_state = wr_data;	    
				end
			       // when data is sent on DQ bus and check i_burstlength if i_burstlength = 8 ,move to data_burst8 state

				    
					
	data_burst8  : begin                                    // (i_burstlength = 8)
					if( i_wrdata_done  )
					next_state = crc ;

					else 
					next_state = data_burst8;	    
				  end
				   // when rest of  wr_data is sent on DQ bus move to crc state
				   
				   
	crc      :   begin                          // (phy crc support)
					if (i_gap ==3'b001)
					  next_state = wr_data ; 
					
					else if (i_interamble)
					 next_state = interamble ;
					else 
					next_state = postamble ;					                    
				end		
				 	// check i_interamble if high move to interamble state ,if not move to postamble state	
					
					
  postamble     : begin
					 if (i_postamble_done && !i_wr_en)
					  next_state =idle ;
					
					else if (  i_postamble_done && i_wr_en  )
					next_state = preamble ;					
					else 
					next_state = postamble;	
				end
                      // when postamble pattern is sent on DQS bus , check i_wr_en if high move to preamble state ,if low move to idle
					
					
   interamble   :begin
   
					 if (i_interamble_done&&i_crc_generate)
					next_state = wr_data ;
					
					else if (i_interamble_done&&!i_crc_generate)
					next_state = wr_data_crc ; 
					else 
					next_state = interamble;	
				end
                 // when interamble pattern is ent on DQS ,check i_crc_generate if low then move to wr_data_crc , if i_crc_generate is high then move to wr_data 
			
		  
  default : next_state = idle ;		 
  
  endcase
end	



//output logic
always_comb 
 begin
  case(current_state)
		 
			
   idle   :  begin                                    // no operation in this state
               o_DQ  = 8'b0 ;
		       o_DQ_valid = 1'b0 ;
			   o_DM = 1'b0 ;
			   o_fsm_state   = 3'b000 ;
			   o_DQS = 2'b00 ;
			   o_interamble_valid = 1'b0 ;
			   o_DQS_valid = 1'b0 ;	
             end
			 
   preamble  :  begin                               // preamble pattern is sent on DQS bus ,and DQS valid will be high when the correct pattern is sent
                   o_DQ  = 8'b0 ;
		           o_DQ_valid = 1'b0 ;
			       o_DM = 1'b0 ;			  
			       o_fsm_state   = 3'b001 ;			 
             	   o_DQS = i_preamble_bits ;
				   o_interamble_valid = 1'b0 ;
			       o_DQS_valid = i_preamble_valid ;
			     	
                end
			   
   wr_data_crc  : begin                            // wr_data from MC will be sent on DQ bus with DQ_valid ,DQS will be phy _clock,wrdata mask is sent on DM bus 
                      o_DQ  = i_Wr_data ;
		              o_DQ_valid = 1'b1 ;
			          o_DM = i_Wr_datamask  ;
			          o_fsm_state   = 3'b010 ;
			          o_DQS = 2'b10 ;
				      o_interamble_valid = 1'b0 ;
			          o_DQS_valid = 1'b1 ;	
			       
			      end 
			 			
             
	wr_data  :	begin 
				   o_DQ  = i_Wr_data ;               // data will be sent on DQ bus and to crc block to generate crc and DQS will be phy _clock
		           o_DQ_valid = 1'b1 ;
			       o_DM = 1'b0 ;
			       o_fsm_state   = 3'b101 ;
			       o_DQS = 2'b10 ;
				   o_interamble_valid = 1'b0 ;
			       o_DQS_valid = 1'b1 ;	
                  o_crc_data = i_Wr_data ;
                  o_crc_enable = 1'b1 ;	
                
				end
				
	data_burst8  : begin                                //(burstlength =8)
				     o_DQ  = 8'b11111111 ;              // rest of wr_data will be completed with ones and sent it on DQ bus and crc block
		            o_DQ_valid = 1'b1 ;
			        o_DM = 1'b0 ;
			        o_fsm_state   = 3'b110 ;
			        o_DQS = 2'b10 ;
				    o_interamble_valid = 1'b0 ;
			        o_DQS_valid = 1'b1 ;	
				    o_crc_data = 8'b11111111 ;
                    o_crc_enable = 1'b1 ;	
                    
				  end	
				
	crc  :	begin
				 o_DQ  = i_crc_code ;                // crc code is taken from crc block and sent it after data on DQ bus
                                                     // sends interamble_valid to shift register to shift interamble pattern 				 
		         o_DQ_valid = 1'b1 ;
			     o_DM = 1'b0 ;
			     o_fsm_state   = 3'b111 ;
			     o_DQS = 2'b10 ;
				 o_interamble_valid = 1'b1 ;       
			     o_DQS_valid = 1'b1 ;	
				 o_crc_enable = 1'b1 ;	
				
			 end	
			 
	postamble   : begin                             // postaamble pattern is sent on DQS bus 
                 o_DQ  = 8'b0 ; 
		         o_DQ_valid = 1'b0 ;
			     o_DM = 1'b0 ;
			     o_fsm_state = 3'b011 ;
			     o_DQS = 2'b00 ;
				o_interamble_valid = 1'b0 ;
			    o_DQS_valid = 1'b1 ;	
                 o_crc_enable = 1'b0 ;	 
                  end
				  
   interamble  : begin                              // interamble pattern is sent on DQS bus
                  o_DQ  = 8'b0 ;
		         o_DQ_valid = 1'b0 ;
			     o_DM = 1'b0 ;
			     o_fsm_state= 3'b100 ;
			     o_DQS =  i_interamble_bits ;
				 o_interamble_valid = 1'b1 ;
			     o_DQS_valid = 1'b1 ;	
                  o_crc_enable = 1'b0 ;	
                 end
 
			 
   default : begin
			 o_DQ  = 8'b0 ;
		     o_DQ_valid = 1'b0 ;
			 o_DM = 1'b0 ;
			 o_DQS = 2'b00; 
			 o_fsm_state= 3'b000 ;
			o_interamble_valid = 1'b0 ;
			o_DQS_valid = 1'b0 ;	
            o_crc_enable = 1'b0 ;							
             end  
   endcase   
		  
		  
	  end 

endmodule 








