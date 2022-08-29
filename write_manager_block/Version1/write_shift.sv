//////////////////////////////////////////////////////////////////////////////////
// Company: Si-Vision & FOE ASU
// Author: AHMED MOSTAFA KAMAL , ADHAM HAZEM ALGENDI AND AHMED MOHAMED AMIN 
//
// Create Date:     24/3/2022
// Module Name: dqs MODULE
// Description: this file contains the dqs RTL, the design implementation
// is based on IEEE standard (Std 802.15.4-2011)
//
//
/////////////////////////////////////////////////////////////////////////////////


// Defining the module external interface (NAME ,input ports and output ports).
module write_shift
(
			
			input logic 			 	 	i_clk ,                 // i_clk : an input represents the clock of the system.
			
		
			input logic 				 	i_rst ,                 // i_rst : active low asynchronous reset to the system.
			
		 
			input logic			    	 	i_wr_en ,               // i_wr_en : an input represents the write enable signal to the system.
			
			
			input logic		  [7: 0]		i_pre_pattern ,         // i_pre_pattern : an input represents the preamble patttern to be shifted on the DQS before the data.
			
			
			input logic  				 	i_interamble_valid ,    // i_interamble_valid : an input represents if there is an interamble or not.
			
			
			input logic 	  [2:0]		 	i_interamble_shift ,    // i_interamble_shift : an input responsible for shifting the interamble pattern to be out on the DQS.
			
			
			input logic  			 	 	i_preamble_valid ,      // i_preamble_valid : an input represents that preamble pattern started to be out.
			
			
			input logic                      i_preamble_load,	    // i_preamble_load   : input signal indicates loading preamble pattern in preamble register
			
			
			
			
			output logic	  [1:0]			o_interamble_bits ,     // o_interamble_bits : 2-bit output represents the DQS bits in case of interamble state.
			
			
			output logic      [1:0]		 	o_preamble_bits,       // o_preamble_bits : 2-bit output represents the DQS bits in case of preamble state.
			
			
			output logic 	  [2:0] 		o_gap                  // o_gap : output represents the gap to determine the case whether an interamble or postamble.
) ;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// internal signals and registers

// preamble_pattern : internal register contain the preamble pattern in addition to 2 zero bits to shift this register on DQS in case of preamble state.
logic  [9:0]	 	preamble_pattern ;

// interamble_pattern : internal register contain the preamble pattern and postamble pattern to be shifted on DQS in case of interamble state.
logic  [11:0]	 	interamble_pattern ;

// gap_register : internal register contain the value of the gap.
logic  [2:0] 		gap_register ;

// counter_enable_low : internal counter to count the write enable when it is low to determine the gap value.
logic  [2:0] 		counter_enable_low ;

 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// preamble _pattern
 always_ff @(posedge i_clk or negedge i_rst)
   begin
	if(!i_rst)
	  begin

		preamble_pattern <= 10'b00000  ;                //reset preamble register with zeros 
		end
 	else if (i_preamble_load)
 	  begin
 	    preamble_pattern <= {2'b00 ,i_pre_pattern} ;     // load preamble register with preamble_pattern  
 	    end
	else if (i_wr_en||i_preamble_valid )                
	  begin

		o_preamble_bits <= preamble_pattern [9:8];       // shifting preamble register and sending preamble bits to fsm

		preamble_pattern <= {preamble_pattern[7:0],2'b00}; 
	  end
	  
	else 

		preamble_pattern <= {2'b00 ,i_pre_pattern} ;
	 
  end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// calculate gap_register 
 always_ff @(posedge i_clk or negedge i_rst)
   begin
	if(!i_rst)
	  begin

		counter_enable_low <= 3'b000 ;               // reseting counter 
	  end

	else if (!i_wr_en)
	  begin

		counter_enable_low <= counter_enable_low +1 ;       // increment valu of counter by 1
		gap_register <= counter_enable_low+1 ;              // store value of the counter in gap register
		 o_gap <= counter_enable_low +1;

		                     
	  end
	  
	else
	  begin
        
		counter_enable_low <= 3'b000 ;
	  end
  end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 

//calculate interamble
always@(i_interamble_valid , i_interamble_shift ,gap_register ) // triggering the combinational always when this sensitivity list changes.
  begin

	if (i_interamble_valid == 1'b1 ) 
	  begin

		o_interamble_bits = interamble_pattern [11:10];    // shifting interamble_pattern register

		interamble_pattern = {interamble_pattern[9:0],2'b00}; 
	  end  
	else
	  begin
		case (gap_register ) // asking about the value of the gap and detecting interamble pattern.
		
		
3'b01 : begin
			interamble_pattern = {i_pre_pattern[1:0] ,10'b000};
		end
		
3'b010 : begin
			interamble_pattern = {i_pre_pattern[3:0] ,8'b000} ;
		end

		
3'b011 : begin
			interamble_pattern = {i_pre_pattern[5:0],6'b0000} ;
		end
 
		
3'b100 : begin
			interamble_pattern = {i_pre_pattern[7:0] ,4'b000} ;
		end

		
3'b101 : begin
			interamble_pattern = {2'b00,i_pre_pattern[7:0],2'b00} ;
		end


3'b110 : begin
			interamble_pattern = {4'b00,i_pre_pattern[7:0]} ;
		end
 
		
default: interamble_pattern = 12'b000000;
		endcase
	  end
  end

  
endmodule






