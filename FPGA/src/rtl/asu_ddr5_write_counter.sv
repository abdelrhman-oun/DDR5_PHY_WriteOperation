/*******************************************************************************
** Company: Si-Vision & FOE ASU
** Author: AHMED MOSTAFA KAMAL and ADHAM HAZEM ALGENDI
**
** Create Date:     24/3/2022
** Edited on  :     21/4/2022
** Module Name: asu_ddr5_write_counters MODULE
** Description: this file contains the COUNTER RTL, the design implementation
** is based on IEEE standard (Std 802.15.4-2011)
**
******************************************************************************/


// Defining the module external interface (NAME ,input ports and output ports).
module asu_ddr5_write_counters
         
(			
					//////input signals ////// 
					
			input 	wire 				clk_i   ,                 // clk_i : an input represents the clock of the system. 
			
			input  	wire 				rst_i   ,                 // rst_i : active low asynchronous reset to the system.
		
			input  	wire 				wr_en_i ,                 // wr_en_i : an input represents the write enable signal to the system.
			
			input  	wire                phy_crc_mode_i      ,     // phy_crc_mode_i : input represents either Memory controller or PHY will generate the crc. 
			
			input  	wire 				dram_crc_en_i       ,     // dram_crc_en_i : input represents if dram wants a crc for the data or not.
			
			input 	wire	[2:0]       precycle_i          ,     // precycle_i : input represents the number of cycles for the DQS before the data.
		
			input  	wire	[1:0]       postcycle_i         ,     // postcycle_i : input represents the number of cycles for the DQS after the data.
			
			input  	wire	[3:0]       gap_i               ,     // gap_i : input represents the number of cycles where write enable is low.
			
			input 	wire	[1:0]       burstlength_i       ,     //burstlength_i : input represents the burstlength of the coming data from the MC.
	
			input 	wire 				data_state_i        ,     // input signal indicates  to  write data states  
			
			input  	wire 				preamble_state_i    ,     // input signal indicates to preamble , postamble ,interamble states 
			
			input  	wire                interamble_valid_i  ,     // input signal indicates that interamble bits is sent on DQS bus
			
					//////output signals ////// 
					
			output  reg     			preamble_valid_o    ,     // preamble_valid_o : output represents the DQS valid signal in the preamble state.
			
			output  reg		[2:0]       interamble_shift_o  ,     // interamble_shift_o : output responsible for starting the shift of the DQS in the case of interamble.
					
			output 	wire      			preamble_done_o     ,     // preamble_done_o : output represents the finish of preamble state.
	
			output  wire      			postamble_done_o    ,     // postamble_done_o : output represents the finish of postamble state.
	
			output  wire      			interamble_done_o   ,     // interamble_done_o : output represents the finish of interamble state.
	
			output  wire                data_burst_done_o   ,     // data_burst_done_o : output represents the finish of the data burst in case that the burst is not the default.
	
			output  wire                wrdata_done_o       ,     // wrdata_done_o : output represents the finish of wr_data state.
	
			output  wire                wrmask_done_o       ,     // wrmask_done_o : output represents the finish of wr_data state in case of mask (no crc coming from MC).
	
			output  wire                interamble_o        ,     // interamble_o : output represents if there will be an interamble or not.
			
			output  wire        		crc_generate_o      ,     // crc_generate_o : output represents that PHY will generate and send the crc to dram.
			
			output 	wire                preamble_load_o     , 	  // preamble_load_o   : output signal indicates loading preamble pattern in preamble register
		
			output 	wire                gap_burst_eight_o   ,	  // output signal indicates to data burst 8 state and enable is high
		 
			output 	wire      			wrdata_crc_done_o   	  // wrdata_crc_done_o : output represents the finish of the wrdata_crc state.
  	
);

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// internal signals and registers

// counter_preamble : internal counter responsible for an output flag to move from preamble state.
reg [3:0]  	counter_preamble    ;

// counter_write_data : internal counter responsible for an output flag to move from wr_data_state.
reg [3:0]  	counter_write_data  ;


// counter_inter_post : internal counter responsible for an output flag to move from interamble state.
reg [2:0]  	counter_inter_post  ;

// wr_en_low_flag : internal signal used as a flag to determine that write enable is low in data states.
reg        	wr_en_low_flag      ;

// registere to store input gap value in write data states 
reg [3:0]	gap_value;

// flag will be high in case burst length 8 and phy crc support mode
reg 		burst_eight ;			


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	
	// preamble_done_o : output to the controller to move from preamble state.
	assign preamble_done_o      = (counter_preamble == 3'b101)? 1'b1 : 1'b0 ;	
	
	// wrdata_crc_done_o : output to the controller to move from wrdata_crc state. 
	assign wrdata_crc_done_o    = (counter_write_data == 4'b0101 && dram_crc_en_i)? 1'b1 : 1'b0 ;
	
	// postamble_done_o : output to the controller to move from postamble or interamble state. 
	assign postamble_done_o     = (counter_inter_post == (postcycle_i-1 +(phy_crc_mode_i&&dram_crc_en_i) ))? 1'b1 : 1'b0 ;

	// interamble_done_o : output to the controller to move from interamble state. 
	assign interamble_done_o    = (counter_inter_post == ( gap_value- 1 ))   ? 1'b1 : 1'b0 ;
	
	// wrdata_done_o : output to the controller to move from wrdata state.
	assign wrdata_done_o        = (counter_write_data == 4'b0111 &&burstlength_i == 2'b01) ||(counter_write_data == 4'b0101 &&(burstlength_i == 2'b00||burstlength_i == 2'b10) )  ? 1'b1 : 1'b0 ;
	
	// data_burst_done_o : output to the controller to move from data_burst state.
	assign data_burst_done_o    = (counter_write_data == 4'b0011)? 1'b1 : 1'b0 ;
	
	// wrmask_done_o : output to the controller to move from wrdata state in the case of the mask.
	assign wrmask_done_o        = (counter_write_data == 4'b0101 && !dram_crc_en_i ) || (counter_write_data == 4'b0011 &&burstlength_i == 2'b01&& !dram_crc_en_i  )? 1'b1 : 1'b0 ;
	
	// interamble_o : output determines whether there will be interamble or not.
	assign interamble_o         = ((gap_i< precycle_i+postcycle_i + (phy_crc_mode_i - 1) )|| ((gap_i < precycle_i+postcycle_i  ) && burstlength_i == 2'b01))? 1'b1 : 1'b0 ;
	
	// crc_generate_o : output determines if PHY will both generate and send crc to DRAM or not.
	assign crc_generate_o       =  dram_crc_en_i && phy_crc_mode_i ;
	
	// preamble_load_o : output signal to load preamble pattern in preamble register.
	assign preamble_load_o    = (counter_write_data == 4'b0001)? 1'b1 : 1'b0 ;
	
	// signal indicates to burst length =8 , phy crc support .
	assign burst_eight        = dram_crc_en_i && phy_crc_mode_i && burstlength_i == 2'b01 ? 1'b1 :1'b0  ; 
	
	// output signal indicates to case byrst length 8 and phy crc support to decrement gap value by 4 .
    assign  gap_burst_eight_o =    (counter_preamble == 3'b001 && burst_eight && data_state_i )? 1'b1 : 1'b0 ;  

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
// Preamble sequential always	
always_ff @(posedge clk_i or negedge rst_i)
 begin
	if(!rst_i)                       // active low asynchronous reset. 
	  begin
		counter_preamble   <= 3'b000  ;
		preamble_valid_o <= 1'b0 ;
	  end
	
	else if (wr_en_i == 1'b0 && data_state_i  == 1'b1)
	  begin
	    counter_preamble   <= 3'b000  ;
	  end
	   
	else if(wr_en_i == 1'b1)
	  begin
		counter_preamble <= counter_preamble + 1 ; 		// increment counter by 1
		
		if ((counter_preamble == ( 5-precycle_i ))&& !data_state_i)    // correct pattern is sent on DQS bus
	      begin
			preamble_valid_o <= 1'b1 ; 
		  end 
		else if(counter_preamble == 3'b101)       // whole pattern is sent on DQS bus 
		  begin
			counter_preamble <= 3'b000 ;
			preamble_valid_o <= 1'b0 ;
	
		  end  
	
	  end
	  
	  
	else if(burstlength_i == 2'b01 && counter_preamble == 3'b100)
      begin
         counter_preamble <= counter_preamble + 1 ;
      end 
	
	else if(counter_preamble == 3'b101)       // whole pattern is sent on DQS bus 
      begin
         counter_preamble <= 3'b000 ;
         preamble_valid_o <= 1'b0 ;
      end  
 	 
 end
 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Data sequential always
always_ff @(posedge clk_i or negedge rst_i)
 begin  
	if(!rst_i)                       // active low asynchronous reset. 
	  begin
		counter_write_data <= 4'b0000 ;
		wr_en_low_flag     <= 1'b0    ; 	
	  end
	
	else if(preamble_state_i ||interamble_valid_i)                                               // preamble , postamble , interamble states
	  begin
	    wr_en_low_flag <= 1'b0  ;
		counter_write_data <= 4'b0000 ;
	  end
	
	else if (data_state_i == 1'b1 && burstlength_i == 2'b01 &&dram_crc_en_i == 1'b0 )    // case of  burst length =8 , mask 
	  begin
		counter_write_data <= counter_write_data + 1 ;
	  end
	
	
	else if (!wr_en_i && (data_state_i ||preamble_state_i ))      //  start counting when enable is low in data states  or preamble states   
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

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Postamble and Interamble sequential always
always_ff @ (posedge clk_i or negedge rst_i)
 begin
	if(!rst_i)                       // active low asynchronous reset. 
	  begin
		counter_inter_post <= 3'b000  ;
		interamble_shift_o <= 3'b000  ; 
		gap_value <= 3'b000 ;
	  end
	
	else if(interamble_valid_i)      // start counting in interamble or crc state           
	  begin
		counter_inter_post <= counter_inter_post + 1 ;
		interamble_shift_o <= interamble_shift_o + 1 ;
	  end  
	  
	else if(data_state_i)
	  begin
		gap_value <= gap_i ;        // store value of input gap in register at write data state
		counter_inter_post <= 3'b000  ;
		interamble_shift_o <= 3'b000  ;
	  end
	
	else 
	  begin
		gap_value <=4'b0000 ;
		counter_inter_post <= 3'b000  ;
		interamble_shift_o <= 3'b000  ;
	  end
	
 end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

endmodule 






















