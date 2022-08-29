/**********************************************************************************
** Company: Si-Vision & FOE ASU
** Author: AHMED MOSTAFA KAMAL , ADHAM HAZEM ALGENDI AND AHMED MOHAMED AMIN 
**
** Create Date:     24/3/2022
** Edited on  :     21/4/2022
** Module Name: asu_ddr5_write_shift MODULE
** Description: this file contains the dqs RTL, the design implementation
** is based on IEEE standard (Std 802.15.4-2011)
**
**
**********************************************************************************/
`timescale 1ns / 1ps


// Defining the module external interface (NAME ,input ports and output ports).
module ddr5_phy_write_shift
(
					//////input signals //////
	 
			input	wire 				clk_i   ,               // clk_i : an input represents the clock of the system.
			
			input   wire 				rst_i   ,               // rst_i : active low asynchronous reset to the system.
			
			input   wire			    wr_en_i ,               // wr_en_i : an input represents the write enable signal to the system.
			
			input   wire	[7: 0]		pre_pattern_i      ,    // pre_pattern_i : an input represents the preamble patttern to be shifted on the DQS before the data.
			
			input   wire  				interamble_valid_i ,    // interamble_valid_i : an input represents if there is an interamble or not.
			
			input   wire	[2:0]		interamble_shift_i ,    // interamble_shift_i : an input responsible for shifting the interamble pattern to be out on the DQS.
			
			input   wire  			 	preamble_valid_i   ,    // preamble_valid_i : an input represents that preamble pattern started to be out.
			
			input   wire                preamble_load_i    ,	// preamble_load_i   : input signal indicates loading preamble pattern in preamble register
			
			input   wire                gap_burst_eight_i  ,    // input signal indicates to data burst 8 state and enable is high
			
					//////output signals //////
			
			output  reg		[1:0]		interamble_bits_o  ,    // interamble_bits_o : 2-bit output represents the DQS bits in case of interamble state.
			
			output  reg		[1:0]		preamble_bits_o    ,    // preamble_bits_o : 2-bit output represents the DQS bits in case of preamble state.
			
			output  reg 	[3:0] 		gap_o                   // gap_o : output represents the gap to determine the case whether an interamble or postamble.
) ;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// internal signals and registers

// preamble_pattern : internal register contain the preamble pattern in addition to 2 zero bits to shift this register on DQS in case of preamble state.
reg  [9:0]	 	preamble_pattern ;

// interamble_pattern : internal register contain the preamble pattern and postamble pattern to be shifted on DQS in case of interamble state.
reg  [11:0]	 	interamble_pattern ;

// gap_register : internal register contain the value of the gap.
reg  [3:0] 		gap_register ;

// counter_enable_low : internal counter to count the write enable when it is low to determine the gap value.
reg  [3:0] 		counter_enable_low ;

 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// preamble _pattern
always_ff @(posedge clk_i or negedge rst_i)
 begin
	if(!rst_i)
	  begin
		preamble_pattern <= 10'b00000  ;                //reset preamble register with zeros 
	  end
	  
 	else if (preamble_load_i)
 	  begin
 	    preamble_pattern <= {2'b00 ,pre_pattern_i} ;     // load preamble register with preamble_pattern  
 	  end
	  
	else if (wr_en_i||preamble_valid_i )                
	  begin
		preamble_bits_o <= preamble_pattern [9:8];       // shifting preamble register and sending preamble bits to fsm
		preamble_pattern <= {preamble_pattern[7:0],2'b00}; 
	  end
	  
	else 
		preamble_pattern <= {2'b00 ,pre_pattern_i} ;
	 
 end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// calculate gap_register 
 always_ff @(posedge clk_i or negedge rst_i)
   begin
	if(!rst_i)
	  begin
		counter_enable_low <= 3'b000 ;               // reseting counter 
	  end
	 
	else if ( gap_burst_eight_i)
	  begin
		gap_register <= gap_register -4 ;              // decrement gap register value by 4 in case burst length 8 and phy crc support
		gap_o <= gap_register -4 ;   
        counter_enable_low <= 3'b000 ;
	  end
	  
	else if (!wr_en_i)
	  begin
		counter_enable_low <= counter_enable_low +1 ;       // increment valu of counter by 1
		gap_register <= counter_enable_low+1 ;              // store value of the counter in gap register
		gap_o <= counter_enable_low +1;
	  end
	  
	else
	  begin
		counter_enable_low <= 3'b000 ;
	  end
	  
  end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
//calculate interamble
always@(interamble_valid_i , interamble_shift_i ,gap_register ,interamble_pattern ,pre_pattern_i ) // triggering the combinational always when this sensitivity list changes.
  begin
  
    interamble_bits_o = interamble_pattern [11:10];    // shifting interamble_pattern register
    
	if (interamble_valid_i == 1'b1 ) 
	  begin
		interamble_pattern = {interamble_pattern[9:0],2'b00}; 
	  end  
	  
	  
	else
	  begin
		case (gap_register ) // asking about the value of the gap and detecting interamble pattern.
		
		
4'b01  : begin
			interamble_pattern = {pre_pattern_i[1:0] ,10'b000};
		 end
		
4'b010 : begin
			interamble_pattern = {pre_pattern_i[3:0] ,8'b000} ;
		 end

		
4'b011 : begin
			interamble_pattern = {pre_pattern_i[5:0],6'b0000} ;
		 end
 
		
4'b100 : begin
			interamble_pattern = {pre_pattern_i[7:0] ,4'b000} ;
		 end

		
4'b101 : begin
			interamble_pattern = {2'b00,pre_pattern_i[7:0],2'b00} ;
		 end


4'b110 : begin
			interamble_pattern = {4'b00,pre_pattern_i[7:0]} ;
		 end
 
 
default: interamble_pattern = 12'b000000;

		endcase
	  end
 end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
endmodule







