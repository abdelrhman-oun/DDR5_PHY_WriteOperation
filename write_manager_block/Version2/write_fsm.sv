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
				   
				   
            input wire 					i_clk ,                       // system  phy clock
			     				  
  			input  wire 					i_rst ,                       // system reset
			     				  
  			input  wire 					i_enable ,                    // system  block enable
			     					
  			input  wire     				i_wr_en ,                     // write enable signal from freq ratio block 
                					
			input  wire                    i_preamble_valid ,            // valid signal that indcates correct  preamble pattern is sent on DQS signal 
			    				 
			input  wire					    i_preamble_done ,             // signal that  indicates  that whole preamble pattern is sent
			    				 
			input  wire				    i_postamble_done ,            // signal that  indicates  that whole postamble pattern is sent on DQS bus
			    			 
			input  wire					    i_interamble_done ,           // signal that  indicates  that whole interamble pattern is sent on DQS bus
			    			   
			input  wire					    i_wrdata_crc_done ,           // signal that  indicates  that whole data is sent on DQ bus  (MC crc support) 
			     
			input  wire                     i_wrdata_done ,               // signal that  indicates  that whole data is sent on DQ bus  (phy crc support)
			    			 
			input  wire                     i_data_burst_done ,           // signal that indicates data  is sent on DQ bus (burst length = 8)
			    			 
			input  wire                     i_wrmask_done ,               // signal that indicates  whole data is sent on DQ bus (data mask)
			    					   
			input  wire                     i_crc_generate ,              // indicates that phy will generate crc or not
			  			      
			input  wire                     i_interamble ,                // indicates that if there is interamble exist
			 			  
			input  wire    [1: 0]		    i_preamble_bits ,             // preamble bits result from shifting preamble pattern 
			 			     			  
			input  wire   [1:0]            i_interamble_bits ,          // interamble bits result from shifting interamble pattern
			   
			input  wire    [3:0]            i_gap ,                      // signal detect number of cycles at which  write enable is low 
             			 
			input  wire    [2*N -1: 0]		 i_Wr_data ,                // input wrdata from freq ratio block
			   
			input  wire    [(N/4-1):0]		 i_Wr_datamask ,           // input data mask  from freq ratio block
			      
			input wire  	[2*N-1: 0]		 i_crc_code ,              // input crc data from crc block
			     			  
			input wire     [1:0]            i_burstlength,           // input burstlength from command block
			     
			   
			   
			  /////////output signals ////////////////
			  
			  
			  
			  output  reg                  o_data_state ,           // output signal indicates  to  write data states
 			  
			  output  reg 					o_post ,                 // output signal indicates to preamble , postamble ,interamble states 
			 		  	  
			 output  reg  [2*N -1: 0]		o_crc_data ,             // output data to crc block
			      			 
  			 output  reg  					o_crc_enable ,           // output enable to crc block
			 			 
			 output  reg   [1:0]		    o_DQS ,                  // output data strobe to DRAM
			      			 
  			 output  reg   [2*N -1: 0]      o_DQ ,                    // output data to DRAM
			      			 
			 output  reg     			   o_DQS_valid ,            //  output signal indicates that data strobe is sent or not
			      			 
			 output  reg 					o_DQ_valid ,            //  output signal indicates that data  is sent or not
			      			 
			 output  reg   [(N/4-1):0]   	o_DM ,                  // output data mask to DRAM
			       			 
			 output  reg                   o_interamble_valid  	// output signal indicates that interamble bits is sent on DQS bus
			   							
			
			 
                  
);

 //state defintions
 typedef enum logic [2:0] {  idle , preamble , wr_data_crc ,  wr_data , data_burst8 ,crc , postamble ,  interamble  }  state_t ;
 state_t current_state , next_state ;

reg [1:0] DQS  ;
reg [2*N-1 : 0] DQ ;
reg    DQS_valid ;
reg  DQ_valid ;
reg  [(N/4-1):0]   	DM  ; 

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
                    DQ  = 8'b0 ;
		            DQ_valid = 1'b0 ;
			        DM = 1'b0 ;			
			        DQS = 2'b00 ;
			        o_interamble_valid = 1'b0 ;
			        DQS_valid = 1'b0 ;	
			        o_data_state = 1'b0 ;
			        o_post = 1'b0 ;
			        o_crc_data = 1'b0 ;
                    o_crc_enable = 1'b0 ; 
					
					if(i_wr_en)                            
					next_state = preamble;
					else
					next_state = idle ;			  
					end
					
					// no operation in this state, when wr_en is high move to preamble state 
					
					
			 
  preamble :		begin   
                     // preamble pattern is sent on DQS bus ,and DQS valid will be high when the correct pattern is sent 
                     DQ  = 8'b0 ;
		             DQ_valid = 1'b0 ;
			         DM = 1'b0 ;				      
             	     DQS = i_preamble_bits ;
				     o_interamble_valid = 1'b0 ;
			         DQS_valid = i_preamble_valid ;
				     o_data_state = 1'b0 ;
				     o_post = 1'b1 ;
			     	 o_crc_data = 1'b0 ;
                    	o_crc_enable = 1'b0 ;
        			
					 // when preamble is sent on DQS bus and check i_crc_generate if low then move to wr_data_crc or if i_crc_generate is high then move to wr_data 
				
                     if ( i_preamble_done && !i_crc_generate )  
                    					 
					 next_state = wr_data_crc ;					 
					
					 else if (  i_preamble_done && i_crc_generate  )
					 
					  next_state = wr_data ;		   
                     					  
					  else 					 
					  next_state = preamble ;				 
				
					end
			    
				
				
			
  wr_data_crc  :  begin                                       // (MC crc support or data mask)  
                       // wr_data from MC will be sent on DQ bus with DQ_valid ,DQS will be phy _clock,wrdata mask is sent on DM bus
                      DQ  = i_Wr_data ;
		              DQ_valid = 1'b1 ;
			          DM = i_Wr_datamask  ;			         
			          DQS = 2'b10 ;
				      o_interamble_valid = 1'b0 ;
			          DQS_valid = 1'b1 ;	
					  o_data_state = 1'b1 ;
					  o_post = 1'b0 ;
			         o_crc_data = 1'b0 ;
                     o_crc_enable = 1'b0 ;
			    
				     // when data is sent on  DQ bus and check i_interamble if high move to interamble state ,if low move to postamble
					if( !i_interamble && (i_wrdata_crc_done||i_wrmask_done)  ) 
					next_state = postamble ;        

					 else if (  i_interamble &&(i_wrdata_crc_done||i_wrmask_done)  )
					  next_state = interamble ; 					
					else 
					next_state = wr_data_crc;	    
					end
					
					// when data is sent on  DQ bus and check i_interamble if high move to interamble state ,if low move to postamble
					
 					
					
	wr_data  :	begin                     // (phy crc support)
	                  // data will be sent on DQ bus and to crc block to generate crc and DQS will be phy _clock
	                 DQ  = i_Wr_data ;              
		             DQ_valid = 1'b1 ;
			         DM = 1'b0 ;			      
			         DQS = 2'b10 ;
				     o_interamble_valid = 1'b0 ;
			         DQS_valid = 1'b1 ;	
                    o_crc_data = i_Wr_data ;
                    o_crc_enable = 1'b1 ;	
				    o_data_state = 1'b1 ;
				    o_post = 1'b0 ;
				
                    // when data is sent on DQ bus and check i_burstlength if i_burstlength = 8 ,move to data_burst8 state
					if( i_burstlength == 2'b01 && i_data_burst_done  )
					next_state = data_burst8 ;

					 else if ( i_wrdata_done)
					  next_state = crc ; 
					
					else 
					next_state = wr_data;	    
				end
			       

				    
					
	data_burst8  : begin           	// (i_burstlength = 8)
	
	             // rest of wr_data will be completed with ones and sent it on DQ bus and crc block
	                DQ  = 8'b11111111 ;              
		            DQ_valid = 1'b1 ;                 //(burstlength =8)
				     DQ  = 8'b11111111 ;              // rest of wr_data will be completed with ones and sent it on DQ bus and crc block
			        DM = 1'b0 ;			       
			        DQS = 2'b10 ;
				    o_interamble_valid = 1'b0 ;
			        DQS_valid = 1'b1 ;	
				    o_crc_data = 8'b11111111 ;
                    o_crc_enable = 1'b1 ;
					o_data_state = 1'b1 ;
                    o_post = 1'b0 ;
					
					// when rest of  wr_data is sent on DQ bus move to crc state
					if( i_wrdata_done  )
					next_state = crc ;

					else 
					next_state = data_burst8;	    
				  end
				   
				   
				   
	crc      :   begin            	// (phy crc support)
	                // crc code is taken from crc block and sent it after data on DQ bus
                    // sends interamble_valid to shift register to shift interamble pattern
	               DQ  = i_crc_code ;            				 
		            DQ_valid = 1'b1 ;
			        DM = 1'b0 ;			    
			        DQS = 2'b10 ;
				    o_interamble_valid = 1'b1 ;       
			        DQS_valid = 1'b1 ;	
				    o_crc_data = 8'b00000000 ;
				    o_crc_enable = 1'b1 ;
				    o_data_state = 1'b0 ;
			    	o_post = 1'b0 ;
							 
                   // check i_interamble if high move to interamble state ,if not move to postamble state	
					if (i_gap ==3'b001 )
					  next_state = wr_data ; 
					
					else if (i_interamble)
					 next_state = interamble ;
					else 
					next_state = postamble ;					                    
				end		
				 	
					
					
  postamble     : begin    
                         // postaamble pattern is sent on DQS bus 
                       DQ  = 8'b0 ; 
		              DQ_valid = 1'b0 ;
			          DM = 1'b0 ;			    
			          DQS = 2'b00 ;
				      o_interamble_valid = 1'b1 ;
			          DQS_valid = 1'b1 ;	
				      o_crc_data = 8'b00000000 ;
                      o_crc_enable = 1'b0 ;	
				     o_data_state = 1'b0 ;
				     o_post = 1'b1 ;
					 
					  // when postamble pattern is sent on DQS bus , check i_wr_en if high move to preamble state ,if low move to idle
					  if (i_postamble_done && !i_wr_en)
					  next_state =idle ;
					
					else if (  i_postamble_done && i_wr_en  )
					next_state = preamble ;					
					else 
					next_state = postamble;	
				end
                      
					
					
   interamble   :begin    
                          // interamble pattern is sent on DQS bus
                      DQ  = 8'b0 ;
		              DQ_valid = 1'b0 ;
			          DM = 1'b0 ;
			         DQS =  i_interamble_bits ;
				     o_interamble_valid = 1'b1 ;
			         DQS_valid = 1'b1 ;
					 o_crc_data = 8'b00000000 ;                    
					 o_data_state = 1'b0 ;
					 o_post = 1'b1 ;
					  o_crc_enable = 1'b0 ;
					   // when interamble pattern is ent on DQS ,check i_crc_generate if low then move to wr_data_crc , if i_crc_generate is high then move to wr_data 
			
					 if (i_interamble_done&&i_crc_generate)
					 
					next_state = wr_data ;					
					
					else if (i_interamble_done&&!i_crc_generate)					
					next_state = wr_data_crc ;				 
				
					else   					
					next_state = interamble;				

				end
                
		  
   default : begin			 
		     DQ_valid = 1'b0 ;
			 DM = 1'b0 ;
			 DQS = 2'b00; 
			 o_interamble_valid = 1'b0 ;
			 DQS_valid = 1'b0 ;	
             o_crc_enable = 1'b0 ;				
                
              next_state = idle ; 		 
             end
  endcase
end	


	  // registered output 		
always_ff @(posedge i_clk or negedge i_rst)
  begin
	if(!i_rst)              // Asynchronous active low reset 
	  begin
		o_DQ <= 8'b00000000 ;
		o_DQS <= 2'b00 ;
		o_DQ_valid <= 1'b0;
        o_DQS_valid<=1'b0  ;
       	o_DM <= 	1'b0 ;
	  end
   
	else if (i_enable)       // enable fsm 
	  begin	
	    o_DQ <= DQ ;
		o_DQS <= DQS ;
		o_DQ_valid <= DQ_valid ;
        o_DQS_valid<=DQS_valid  ;
       	o_DM <= DM;
	  end
 end
	  

endmodule 









