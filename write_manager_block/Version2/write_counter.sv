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
			input wire 					i_clk ,                  // i_clk : an input represents the clock of the system. 
						
			input  wire 					i_rst ,                  // i_rst : active low asynchronous reset to the system.
					
			input  wire 					i_wr_en ,               // i_wr_en : an input represents the write enable signal to the system.
						
			input  wire                     i_phy_crc_mode  ,      // i_phy_crc_mode : input represents either Memory controller or PHY will generate the crc. 
						
			input  wire 					i_dram_crc_en   ,      // i_dram_crc_en : input represents if dram wants a crc for the data or not.
						
			input wire      [2:0]          i_precycle      ,     // i_precycle : input represents the number of cycles for the DQS before the data.
						
			input  wire      [1:0]          i_postcycle     ,      // i_postcycle : input represents the number of cycles for the DQS after the data.
						
			input  wire     [3:0]          i_gap           ,      // i_gap : input represents the number of cycles where write enable is low.
			
			input wire  	 [1:0]          i_burstlength   ,     //i_burstlength : input represents the burstlength of the coming data from the MC.
					                		
			input wire 					i_data_state,             // input signal indicates  to  write data states  
			
			input  wire 					i_post ,                  // input signal indicates to preamble , postamble ,interamble states 
			
			input  wire                     i_interamble_valid,      // input signal indicates that interamble bits is sent on DQS bus
			
						
			output  reg     			    o_preamble_valid  ,      // o_preamble_valid : output represents the DQS valid signal in the preamble state.
					
			output wire      				o_preamble_done   ,    	 // o_preamble_done : output represents the finish of preamble state.
						
			output  wire      				o_postamble_done  ,     // o_postamble_done : output represents the finish of postamble state.
						
			output  wire      				o_interamble_done ,     // o_interamble_done : output represents the finish of interamble state.
						
			output  wire                    o_data_burst_done ,     // o_data_burst_done : output represents the finish of the data burst in case that the burst is not the default.
					
			output  wire                    o_wrdata_done     ,     // o_wrdata_done : output represents the finish of wr_data state.
					
			output  wire                   o_wrmask_done     ,     // o_wrmask_done : output represents the finish of wr_data state in case of mask (no crc coming from MC).
						
			output  wire                    o_interamble      ,     // o_interamble : output represents if there will be an interamble or not.
						
			output  wire        			o_crc_generate    ,     // o_crc_generate : output represents that PHY will generate and send the crc to dram.
			
			output  reg    [2:0]           o_interamble_shift,     // o_interamble_shift : output responsible for starting the shift of the DQS in the case of interamble.
			
			 output wire                     o_preamble_load, 		// o_preamble_load   : output signal indicates loading preamble pattern in preamble register
			 
			output wire                    o_gap_done,	            // output signal indicates to data burst 8 state and enable is high
				 
			output wire      				o_wrdata_crc_done   	// o_wrdata_crc_done : output represents the finish of the wrdata_crc state.
  	
);


// internal signals and registers

// counter_preamble : internal counter responsible for an output flag to move from preamble state.
reg [3:0]  counter_preamble    ;

// counter_write_data : internal counter responsible for an output flag to move from wr_data_state.
reg [3:0]  counter_write_data  ;


// counter_inter_post : internal counter responsible for an output flag to move from interamble state.
reg [2:0]  counter_inter_post  ;

// wr_en_low_flag : internal signal used as a flag to determine that write enable is low in data states.
reg        wr_en_low_flag      ;

// registere to store input gap value in write data states 
reg  [3:0]    gap_value;

// flag will be high in case burst length 8 and phy crc support mode
reg 			burst_eight ;			


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	
	
	// o_preamble_done : output to the controller to move from preamble state.
	assign o_preamble_done      = (counter_preamble == 3'b101)? 1'b1 : 1'b0 ;	
	
	// o_wrdata_crc_done : output to the controller to move from wrdata_crc state. 
	assign o_wrdata_crc_done    = (counter_write_data == 4'b0101 && i_dram_crc_en)? 1'b1 : 1'b0 ;
	
	// o_postamble_done : output to the controller to move from postamble state. 
	assign o_postamble_done     = (counter_inter_post == (i_postcycle-1 +i_phy_crc_mode ))? 1'b1 : 1'b0 ;

	// o_interamble_done : output to the controller to move from interamble state. 
	assign o_interamble_done    = (counter_inter_post == ( gap_value- 1 ))   ? 1'b1 : 1'b0 ;
	
	// o_wrdata_done : output to the controller to move from wrdata state.
	assign o_wrdata_done        = (counter_write_data == 4'b0111 &&i_burstlength == 2'b01) ||(counter_write_data == 4'b0101 &&i_burstlength == 2'b00 )  ? 1'b1 : 1'b0 ;
	
	// o_data_burst_done : output to the controller to move from data_burst state.
	assign o_data_burst_done    = (counter_write_data == 4'b0011)? 1'b1 : 1'b0 ;
	
	// o_wrmask_done : output to the controller to move from wrdata state in the case of the mask.
	assign o_wrmask_done        = (counter_write_data == 4'b0101 && !i_dram_crc_en ) || (counter_write_data == 4'b0011 &&i_burstlength == 2'b01&& !i_dram_crc_en  )? 1'b1 : 1'b0 ;
	
	// o_interamble : output determines whether there will be interamble or not.
	assign o_interamble         = ((i_gap< i_precycle+i_postcycle + (i_phy_crc_mode - 1) )|| ((i_gap < i_precycle+i_postcycle  ) && i_burstlength == 2'b01))? 1'b1 : 1'b0 ;
	
	// o_crc_generate : output determines if PHY will both generate and send crc to DRAM or not.
	assign o_crc_generate       =  i_dram_crc_en && i_phy_crc_mode ;
	
	// o_preamble_load : output signal to load preamble pattern in preamble register.
	assign o_preamble_load    = (counter_write_data == 4'b0001)? 1'b1 : 1'b0 ;
	
	// signal indicates to burst length =8 , phy crc support .
	assign burst_eight        = i_dram_crc_en && i_phy_crc_mode && i_burstlength == 2'b01 ? 1'b1 :1'b0  ; 
	
	// output signal indicates to case byrst length 8 and phy crc support to decrement gap value by 4 .
     assign   o_gap_done =    (counter_preamble == 3'b001 && burst_eight && i_data_state )? 1'b1 : 1'b0 ;  
	
// sequential always	
always_ff @(posedge i_clk or negedge i_rst)
 begin
 if(!i_rst)                       // active low asynchronous reset. 
	begin
		counter_preamble   <= 3'b000  ;
	end
	else if (i_wr_en == 1'b0 && i_data_state  == 1'b1)
	  begin
	    counter_preamble   <= 3'b000  ;
	   end
	else if(i_wr_en == 1'b1)
	  begin
		counter_preamble <= counter_preamble + 1 ; 		// increment counter by 1
		
		if ((counter_preamble == ( 5-i_precycle ))&& !i_data_state)    // correct pattern is sent on DQS bus
				  

		o_preamble_valid <= 1'b1 ; 
	  else if(counter_preamble == 3'b101)       // whole pattern is sent on DQS bus 
       begin
         counter_preamble <= 3'b000 ;
         o_preamble_valid <= 1'b0 ;
	
       end  
	
      
    
		
	  end
  else if(i_burstlength == 2'b01 && counter_preamble == 3'b100)
       begin
         counter_preamble <= counter_preamble + 1 ;
       
       end 
  else if(counter_preamble == 3'b101)       // whole pattern is sent on DQS bus 
       begin
         counter_preamble <= 3'b000 ;
         o_preamble_valid <= 1'b0 ;
	
       end  
 
	 
 end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
always_ff @(posedge i_clk or negedge i_rst)
 begin
   
   
if(!i_rst)                       // active low asynchronous reset. 
	begin
		counter_write_data <= 4'b0000 ;
		wr_en_low_flag     <= 1'b0    ; 
		
	end
	else if(i_post||i_interamble_valid)                                               // preamble , postamble , interamble states
	  begin
	    wr_en_low_flag <= 1'b0  ;
		 counter_write_data <= 4'b0000 ;
		 end
  else if (i_data_state == 1'b1 && i_burstlength == 2'b01 &&i_dram_crc_en == 1'b0 )    // case of  burst length =8 , mask 
		begin
			counter_write_data <= counter_write_data + 1 ;
		end
	else if (!i_wr_en && (i_data_state ||i_post))      //  start counting when enable is low in data states  or preamble states 
				  
	 begin
			   
	wr_en_low_flag <= 1 ;
	counter_write_data <= counter_write_data + 1 ;
						
 end
			
     
	else if (wr_en_low_flag )
		begin
		counter_write_data <= counter_write_data + 1 ;			
		end
	  		
		     
				  
	else 
	        
	counter_write_data <= 4'b0000 ;        
					
			
	  
	        end




always_ff @ (posedge i_clk or negedge i_rst)
 begin
 if(!i_rst)                       // active low asynchronous reset. 
	begin
		counter_inter_post <= 3'b000  ;
		o_interamble_shift <= 3'b000  ; 
		gap_value <= 3'b000 ;
		
	end
	else if(i_interamble_valid)      // start counting in interamble or crc state           
	  begin
		counter_inter_post <= counter_inter_post + 1 ;
		o_interamble_shift <= o_interamble_shift + 1 ;
	
		end
			                   
	  
	else if(i_data_state)
	  begin
		gap_value <= i_gap ;        // store value of input gap in register at write data state
		counter_inter_post <= 3'b000  ;
		o_interamble_shift <= 3'b000  ;
		end
	else 
	begin
	gap_value <=4'b0000 ;
		counter_inter_post <= 3'b000  ;
		o_interamble_shift <= 3'b000  ;
		end
	
end

endmodule 






















