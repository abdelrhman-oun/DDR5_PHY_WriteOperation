/***************************************************************************
** File Name   : ddr5_phy_command_address.sv
** Author      : Abdelrahman Oun 
** Created on  : Apr 20, 2022
** Edited on   : May 28, 2022
** description : COMMAND ADDRESS block is used to forward the command from
         the PHY interface to the DRAM interface and extract some
         info from mode register write (MRW) command like pre-amble,
         post-amble and CRC enable.
****************************************************************************/

`timescale 1ns / 1ps


module ddr5_phy_command_address #(
  // parameter used to specify the number of ranks used in the DIMM
  parameter     pNUM_RANK	= 1
  )(
  
  ////////////////input signals//////////////
  
  // input clock signal
  input wire clk_i,
  
  // input active low asynchronous reset
  input wire rst_i,
  
  // input enable signal
  input wire enable_i,
  
  // input bus from freq ratio block holds the command
  input wire [13:0]			dfi_address_i,
  
  // input signal is used to select the target rank
  input wire [pNUM_RANK-1:0]	dfi_cs_i,
  
  ////////////////output signals//////////////
  
  // output signal is used to select the target rank in DRAM interface
  output reg [pNUM_RANK-1:0]	chip_select_o,
  
  // ouput bus hols the command to DRAM interface
  output reg [13:0]			command_address_o,


    // ouput signal to write data block holds the burst length value
  output wire [1:0]			burst_length_o,


    // output signal to write data block holds the pre-amble pattern
  output reg [7:0] 		pre_pattern_o,
  
  // output singal to write data block holds pre-amble number of cycles
  output reg [2:0]			num_pre_cycle_o,

  
  // output signal to write data block holds post-amble number of cycles
  output reg	[1:0]   num_post_cycle_o,   
  
  // outout signal to write data block holds if DRAM need CRC or not
  output reg 			dram_crc_en_o   
  
  
  );


  // default_sel is a flag indicates if it is first clock cycle to select the default values
  reg command_1st_flag, command_2nd_flag, write_1st_flag, default_sel;

  // these signals are connected to the registers of the ouput pins
  reg [1:0]   burst_length_alternate;
  reg [1:0]   burst_length_default;
  reg         burst_length_sel;

  // mode register holds the MR address
  // operation holds the OP values
  reg [7:0] mode_register,operation;

    
  // select which register is connected to the output burst length
  assign burst_length_o = burst_length_sel ? burst_length_default : burst_length_alternate;
  
    ///////////////always block to control the flow of current sate register/////////////////
  always_ff @ (posedge clk_i or negedge rst_i) begin
    if (!rst_i) begin
      
	  // internal registers
	  command_1st_flag <= 1'b0;
	  command_2nd_flag <= 1'b0;
	  write_1st_flag <= 1'b0;
      default_sel <= 1'b0;
      mode_register <= 8'b0;
      operation <= 8'b0;
	  
      // output registers
      command_address_o   <= 14'b0;
      chip_select_o <= {pNUM_RANK{1'b0}}; 
      burst_length_default <= 2'b00;
      burst_length_alternate <= 2'b00;
      burst_length_sel <= 1'b0;	  
      pre_pattern_o <= 8'b0;
      num_pre_cycle_o <= 3'b0;
      num_post_cycle_o <= 2'b00;
      dram_crc_en_o <= 1'b0;
    
    end
    else if (enable_i) begin
	
	  // assign the command on dfi_address on CA bus
      command_address_o   <= dfi_address_i;
      // assign the CS signal to dfi_cs
      chip_select_o <= dfi_cs_i;
	
	  if (!default_sel) begin
        default_sel <= 1'b1;
		command_1st_flag <= 1'b0;
	    command_2nd_flag <= 1'b0;
		write_1st_flag <= 1'b0;
    
        // begin with the default values, these values are from  JEDEC
        burst_length_default <= 2'b00;
        burst_length_alternate <= 2'b00;
        burst_length_sel <= 1'b0;			
        pre_pattern_o <= 8'b00000010 ;
        num_pre_cycle_o <= 3'b010;
        num_post_cycle_o <= 2'b01;
        dram_crc_en_o <= 1'b0;
      end
      else begin
	  
	    if(!dfi_cs_i && (dfi_address_i[4:0] == 5'b00101)) begin // mode register write command first cycle
	      // enabel command 1st cycle flag
		  command_1st_flag <= 1'b1;
		  // from command truth table in JEDEC the mode register address is in CA[12:5] of the 1st cycle
		  mode_register <= dfi_address_i [12:5]; 
	    end
	    else if (!dfi_cs_i && (dfi_address_i[4:0] == 5'b01101)) begin // write command
		  // enable write command 1st cycle flag
		  write_1st_flag <= 1'b1;
	    end
	    
	    
	    if(dfi_cs_i && !dfi_address_i[10] && command_1st_flag) begin // mode register write command second cycle
	      // disabel command 1st cycle flag
		  command_1st_flag <= 1'b0;
		  // enabel command 2nd cycle flag
	      command_2nd_flag <= 1'b1;
		  // from command truth table in JEDEC the mode register operation is in CA[7:0] of the 2nd cycle
		  operation <= dfi_address_i [7:0];
	    end
	    else if (dfi_cs_i && write_1st_flag) begin
		  // disable write command 1st cycle flag
		  write_1st_flag <= 1'b0;
		  
		  // when CS is high check if default or not is wanted
	      // CA5:BL*=L, the command places the DRAM into the alternate Burst mode described by MR0[1:0] instead of the default Burst Length 16 mode.
		  burst_length_sel <= command_address_o[5];
	    end
	    
	    if(dfi_cs_i && command_2nd_flag) begin
		  // disabel command 2nd cycle flag
	      command_2nd_flag <= 1'b0;
		  
/*
|-------------------------------------------------------------------------------------------------------------------|
| mode register |   operation   | pre_pattern_o | num_pre_cycle_o | num_post_cycle_o | burst_length | dram_crc_en_o |
|---------------|---------------|---------------|-----------------|------------------|--------------|---------------|
|       0       |  8'b00000000  |       -       |         -       |        -         |     2'b00    |        -      |
|---------------|---------------|---------------|-----------------|------------------|--------------|---------------|
|       0       |  8'b00000001  |       -       |         -       |        -         |     2'b01    |        -      |
|---------------|---------------|---------------|-----------------|------------------|--------------|---------------|
|       0       |  8'b00000010  |       -       |         -       |        -         |     2'b10    |        -      |
|---------------|---------------|---------------|-----------------|------------------|--------------|---------------|
|       0       |  8'b00000011  |       -       |         -       |        -         |     2'b11    |        -      |
|---------------|---------------|---------------|-----------------|------------------|--------------|---------------|
|       8       |  8'b00001000  |  8'b00000010  |      3'b010     |      2'b01       |       -      |       -       |
|---------------|---------------|---------------|-----------------|------------------|--------------|---------------|
|       8       |  8'b00010000  |  8'b00000010  |      3'b011     |      2'b01       |       -      |       -       |
|---------------|---------------|---------------|-----------------|------------------|--------------|---------------|
|       8       |  8'b00011000  |  8'b00001010  |      3'b100     |      2'b01       |       -      |       -       |
|---------------|---------------|---------------|-----------------|------------------|--------------|---------------|
|       8       |  8'b10001000  |  8'b00000010  |      3'b010     |      2'b10       |       -      |       -       |
|---------------|---------------|---------------|-----------------|------------------|--------------|---------------|
|       8       |  8'b10010000  |  8'b00000010  |      3'b011     |      2'b10       |       -      |       -       |
|---------------|---------------|---------------|-----------------|------------------|--------------|---------------|
|       8       |  8'b10011000  |  8'b00001010  |      3'b100     |      2'b10       |       -      |       -       |
|---------------|---------------|---------------|-----------------|------------------|--------------|---------------|
|       50      |  8'b00000000  |       -       |         -       |        -         |       -      |      1'b0     |
|---------------|---------------|---------------|-----------------|------------------|--------------|---------------|
|       50      |  8'b00000001  |       -       |         -       |        -         |       -      |      1'b1     |
|---------------|---------------|---------------|-----------------|------------------|--------------|---------------|
|       50      |  8'b00000010  |       -       |         -       |        -         |       -      |      1'b1     |
|---------------|---------------|---------------|-----------------|------------------|--------------|---------------|
|       50      |  8'b00000011  |       -       |         -       |        -         |       -      |      1'b1     | |-------------------------------------------------------------------------------------------------------------------|
*/
		  
		  // decode the mode register 8 value to the desired output signals
          if(mode_register == 8) begin
            case(operation[4:3])
            2'b01: begin
              // 2-cycle pre-amble with pattern "0010"
              pre_pattern_o <= 8'b00000010;
              num_pre_cycle_o <= 3'b010;
            end
              
            2'b10: begin
              // 3-cycle pre-amble with pattern "000010"
              pre_pattern_o <= 8'b00000010;
              num_pre_cycle_o <= 3'b011;
            end
                
            2'b11: begin
              // 4-cycle pre-amble with pattern "00001010"
              pre_pattern_o <= 8'b00001010;
              num_pre_cycle_o <= 3'b100;
            end
            endcase
          
            case (operation[7])
            1'b0: begin
              // 0.5-cycle post-amble with pattern "0"
              num_post_cycle_o <= 2'b01;
            end
              
            1'b1: begin
              // 1.5-cycle post-amble with pattern "000"
              num_post_cycle_o <= 2'b10;
            end
            endcase 
          end
            
          // decode the mode register 50 value to the DRAM CRC enable signal
          else if (mode_register == 50) begin
            dram_crc_en_o <= operation[2] | operation[1];
          end
	    
          // decode the mode register 0 value to the desired burst length value 
          else if (mode_register == 0) begin
            burst_length_alternate <= operation[1:0];
          end
	    end
      end
    end
  end
  

endmodule
