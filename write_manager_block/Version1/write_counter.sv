//////////////////////////////////////////////////////////////////////////////////
// Company: Si-Vision & FOE ASU
// Author: AHMED MOSTAFA KAMAL and ADHAM HAZEM ALGENDI
//
// Create Date:     24/3/2022
// Module Name: COUNTER MODULE
// Description: this file contains the COUNTER RTL, the design implementation
// is based on IEEE standard (Std 802.15.4-2011)
//
//
/////////////////////////////////////////////////////////////////////////////////


// Defining the module external interface (NAME ,input ports and output ports).
module write_counters
         
(			
			input logic 					i_clk ,                  // i_clk : an input represents the clock of the system. 
						
			input logic 					i_rst ,                  // i_rst : active low asynchronous reset to the system.
					
			input logic 					i_wr_en ,               // i_wr_en : an input represents the write enable signal to the system.
						
			input logic                     i_phy_crc_mode  ,      // i_phy_crc_mode : input represents either Memory controller or PHY will generate the crc. 
						
			input logic 					i_dram_crc_en   ,      // i_dram_crc_en : input represents if dram wants a crc for the data or not.
						
			input logic      [2:0]          i_precycle      ,     // i_precycle : input represents the number of cycles for the DQS before the data.
						
			input logic      [1:0]          i_postcycle     ,      // i_postcycle : input represents the number of cycles for the DQS after the data.
						
			input logic      [2:0]          i_gap           ,      // i_gap : input represents the number of cycles where write enable is low.
			
			input logic  	 [1:0]          i_burstlength   ,      //i_burstlength : input represents the burstlength of the coming data from the MC.
						
			input logic      [2:0]			i_fsm_state     ,       // i_fsm_state : input represents the state of the Write Controller.
						
			output logic     			    o_preamble_valid  ,     // o_preamble_valid : output represents the DQS valid signal in the preamble state.
					
			output logic      				o_preamble_done   ,    	// o_preamble_done : output represents the finish of preamble state.
						
			output logic      				o_postamble_done  ,     // o_postamble_done : output represents the finish of postamble state.
						
			output logic      				o_interamble_done ,     // o_interamble_done : output represents the finish of interamble state.
						
			output logic                    o_data_burst_done ,     // o_data_burst_done : output represents the finish of the data burst in case that the burst is not the default.
					
			output logic                    o_wrdata_done     ,     // o_wrdata_done : output represents the finish of wr_data state.
					
			output logic                    o_wrmask_done     ,     // o_wrmask_done : output represents the finish of wr_data state in case of mask (no crc coming from MC).
						
			output logic                    o_interamble      ,    // o_interamble : output represents if there will be an interamble or not.
						
			output logic        			o_crc_generate    ,    // o_crc_generate : output represents that PHY will generate and send the crc to dram.
			
			output logic    [2:0]           o_interamble_shift,     // o_interamble_shift : output responsible for starting the shift of the DQS in the case of interamble.
			
			 output logic                     o_preamble_load,      // o_preamble_load   : output signal indicates loading preamble pattern in preamble register
					
			output logic      				o_wrdata_crc_done   	// o_wrdata_crc_done : output represents the finish of the wrdata_crc state.
  	
);


// internal signals and registers

// counter_preamble : internal counter responsible for an output flag to move from preamble state.
logic [3:0]  counter_preamble    ;

// counter_write_data : internal counter responsible for an output flag to move from wr_data_state.
logic [3:0]  counter_write_data  ;

// counter_postamble : internal counter responsible for an output flag to move from postamble state.
logic [1:0]  counter_postamble   ;

// counter_interamble : internal counter responsible for an output flag to move from interamble state.
logic [2:0]  counter_interamble  ;

// wr_en_low_flag : internal signal used as a flag to determine that write enable is low in data states.
logic        wr_en_low_flag      ;
logic  [2:0]    gap_value;

// sequential always 
 
always_ff @(posedge i_clk or negedge i_rst)
 begin
	if(!i_rst)                       // active low asynchronous reset. 
	begin
		
	
		counter_preamble   <= 3'b000  ;
		counter_write_data <= 4'b0000 ;
		counter_postamble  <= 2'b00   ;        // intially reseting all counters values with zeros
		counter_interamble <= 3'b000  ;
		o_interamble_shift <= 3'b000  ;
		wr_en_low_flag     <= 1'b0    ; 
		
		
	end
// making a multiplexer according to the state of the controller.
case (i_fsm_state)


// preamble state.
// 	i_fsm_state = 3'b001 : represents that the controller is in the preamble state.
3'b001 :    begin 

				counter_postamble <= 2'b00; 
				
				  
				 if (i_wr_en == 0)           
				  begin

		  
				    counter_preamble   <= counter_preamble + 1   ;
					

				    wr_en_low_flag     <= 1 ;
					

				    counter_write_data <= counter_write_data + 1 ;
					
				  end  
			
			end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////			
// wr_data_crc state.	
// 	i_fsm_state = 3'b010 : represents that the controller is in the wr_data_crc state.	  
3'b010 :    begin 
     
				o_preamble_valid <= 1'b0 ;

				counter_write_data <= counter_write_data + 1 ;
				if (i_wr_en == 0)
			      begin

					counter_preamble = 3'b000 ;

					wr_en_low_flag <= 1 ;
					if (wr_en_low_flag == 1)
					  begin
				  
						counter_write_data <= counter_write_data + 1 ;
						
						if (counter_write_data == 4'b0110)
						  begin 

							wr_en_low_flag <= 1'b0  ; 
							
						  end 
					  end

		          end
			
     
				else if (wr_en_low_flag == 1)
				  begin

					counter_write_data <= counter_write_data + 1 ;
					
					if (counter_write_data == 4'b0101)
							begin 

								 wr_en_low_flag <= 1'b0  ;
							
								 counter_write_data <= 4'b0000 ;
					
								 
							end 
					
				  end
				
		     
				  
				else 
					begin

						counter_write_data <= 4'b0000 ;

						counter_preamble <= counter_preamble + 1 ;
					end 
	  
	        end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// postamble 
// 	i_fsm_state = 3'b011 : represents that the controller is in the postamble state.	
3'b011 :    begin


				counter_postamble <= counter_postamble + 1 ;
				

				counter_write_data <= 4'b0000 ;
				

				if ((counter_preamble == ( 5-i_precycle )))
				  begin

					o_preamble_valid <= 1'b1 ;
				  end
		    end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////			
// wrdata 
// 	i_fsm_state = 3'b101 : represents that the controller is in the wrdata state.	
3'b101 :    begin

				counter_write_data <= counter_write_data+1 ;

        if(i_wr_en == 1'b0)
          begin
				counter_preamble <= 3'b000 ;
				  end
				  

				o_preamble_valid <= 1'b0 ;
					
		    end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////			
// interamble
// 	i_fsm_state = 3'b100 : represents that the controller is in the interamble state. 		
3'b100 :    begin

                gap_value <= i_gap;
				o_interamble_shift <= o_interamble_shift + 1 ;

				counter_write_data <= 4'b0000 ;

				counter_interamble <= counter_interamble + 1;
		
            end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////			
//crc 

3'b111  :   begin 
		           
				o_interamble_shift <= o_interamble_shift + 1 ;

            	counter_write_data <= 4'b0000 ;

                counter_interamble <= counter_interamble + 1 ;
			
            end	
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////			
//data_burst8

3'b110  :   begin 

                counter_write_data <= counter_write_data + 1 ;
             	
            end	
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////			    
default :  begin
				counter_preamble <= 3'b000    ;
				counter_write_data <= 4'b0000 ;
				counter_postamble <= 2'b00    ;
				counter_interamble <= 3'b000  ;
				o_preamble_valid <= 1'b0     ;
		 
	
			end 
	endcase
 end



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	
	
	// o_preamble_done : output to the controller to move from preamble state.
	assign o_preamble_done      = (counter_preamble == 3'b101)? 1 : 0 ;	
	
	// o_wrdata_crc_done : output to the controller to move from wrdata_crc state. 
	assign o_wrdata_crc_done    = (counter_write_data == 4'b0101 && i_dram_crc_en)? 1 : 0 ;
	
	// o_postamble_done : output to the controller to move from postamble state. 
	assign o_postamble_done     = (counter_postamble == (i_postcycle-1))? 1 : 0 ;

	// o_interamble_done : output to the controller to move from interamble state. 
	assign o_interamble_done    = (counter_interamble == ( gap_value-1) ) ? 1 : 0 ;
	
	// o_wrdata_done : output to the controller to move from wrdata state.
	assign o_wrdata_done        = (counter_write_data == 4'b1001 &&i_burstlength == 2'b01) ||(counter_write_data == 4'b0111 &&i_burstlength == 2'b00 )  ? 1 : 0 ;
	
	// o_data_burst_done : output to the controller to move from data_burst state.
	assign o_data_burst_done    = (counter_write_data == 4'b0101)? 1 : 0 ;
	
	// o_wrmask_done : output to the controller to move from wrdata state in the case of the mask.
	assign o_wrmask_done        = (counter_write_data == 4'b0101 && !i_dram_crc_en )? 1 : 0 ;
	
	// o_interamble : output determines whether there will be interamble or not.
	assign o_interamble         = ((i_gap < i_precycle+i_postcycle + (i_phy_crc_mode - 1) )|| ((i_gap < i_precycle+i_postcycle  ) && i_burstlength == 2'b01))? 1 : 0 ;
	
	// o_crc_generate : output determines if PHY will both generate and send crc to DRAM or not.
	assign o_crc_generate       =  i_dram_crc_en && i_phy_crc_mode ;
	
	
	
// sequential always	
always_ff @(posedge i_clk or negedge i_rst)
 begin
	if(i_wr_en == 1'b1)
	  begin
	
		counter_preamble <= counter_preamble + 1 ;     // increment counter by 1
		if ((counter_preamble == ( 5-i_precycle )))    // correct pattern is sent on DQS bus
				  begin

					o_preamble_valid <= 1'b1 ;
				  end
	   else if(counter_preamble == 3'b110)       // whole pattern is sent on DQS bus 
       begin
         counter_preamble <= 3'b000 ;
		 o_preamble_load <= 1'b1;               // o_preamble_load : output signal is sent to load preamble pattern in preamble register after whole pattern is sevt on DQS bus 
       end 	
		
	  end
  else if(counter_preamble == 3'b101)
       begin
         counter_preamble <= 3'b000 ;
		  o_preamble_load <= 1'b1;
       end 
	   else 
	   o_preamble_load <= 1'b0;
	 
 end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
endmodule 



















