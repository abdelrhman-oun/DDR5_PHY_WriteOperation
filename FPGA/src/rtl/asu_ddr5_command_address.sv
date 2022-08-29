/***************************************************************************
** File Name   : asu_ddr5_command_address.sv
** Author      : Abdelrahman Oun 
** Created on  : Mar 15, 2022
** Edited on   : Apr 20, 2022
** description : COMMAND ADDRESS block is used to forward the command from
         the PHY interface to the DRAM interface and extract some
         info from mode register write (MRW) command like pre-amble,
         post-amble and CRC enable.
****************************************************************************/

`timescale 1ns / 1ps

`define BURST_LENGTH_ENABLE

module asu_ddr5_command_address #(
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

`ifdef BURST_LENGTH_ENABLE
    // ouput signal to write data block holds the burst length value
  output wire [1:0]			burst_length_o,
`endif

    // output signal to write data block holds the pre-amble pattern
  output reg [7:0] 		pre_pattern_o,
  
  // output singal to write data block holds pre-amble number of cycles
  output reg [2:0]			pre_cycle_o,

  
  // output signal to write data block holds post-amble number of cycles
  output reg	[1:0]   post_cycle_o,   
  
  // outout signal to write data block holds if DRAM need CRC or not
  output reg 			dram_crc_en_o   
  
  
  );
  
  localparam [1:0]  IDEL = 2'b00,
`ifdef BURST_LENGTH_ENABLE
                    WRITE_1ST = 2'b01,
`endif
                    COMMAND_1ST = 2'b10,
                    COMMAND_2ND = 2'b11;
          
          


  reg [1:0] current_state, next_state;
  
  
  // internal signals (inter -> internal)
  // these signals are connected to the registers of the ouput pins
`ifdef BURST_LENGTH_ENABLE  
  reg [1:0]   burst_length_inter;
  reg [1:0]   burst_length_new;
  reg [1:0]   burst_length_default;
  reg         burst_length_sel;
  reg         burst_length_sel_reg;
`endif

  reg [7:0]   pre_pattern_inter;
  reg [2:0]	  pre_cycle_inter;
  reg	[1:0]   post_cycle_inter;
  reg	  DRAM_CRC_en_inter;
  
  // default_sel is a flag indicates if it is first time to be in IDEL state
  // mode register en is used to enable the mode register to store the MR number
  // operation en is used to enable the operation register to store the OP value 
  reg default_sel, mode_register_en, operation_en;
  
  // mode register holds the MR number
  // operation holds the OP values
  reg [7:0] mode_register,operation;

    
`ifdef BURST_LENGTH_ENABLE
  // select which register is connected to the output burst length
  assign burst_length_o = burst_length_sel ? burst_length_default : burst_length_new;
`endif
  
    ///////////////always block to control the flow of current sate register/////////////////
  always_ff @ (posedge clk_i or negedge rst_i) begin
    if (!rst_i) begin
      
	  //reset current state
      current_state <= IDEL;
	
      // output registers
      command_address_o   <= 14'b0;
      chip_select_o <= {pNUM_RANK{1'b0}};
`ifdef BURST_LENGTH_ENABLE  
      burst_length_default <= 2'b00;
      burst_length_new <= 2'b00;
      burst_length_sel_reg <= 1'b0;	  
`endif
      pre_pattern_o <= 8'b0;
      pre_cycle_o <= 3'b0;
      post_cycle_o <= 2'b00;
      dram_crc_en_o <= 1'b0;
    
      // internal registers
      default_sel <= 1'b0;
      mode_register <= 8'b0;
      operation <= 8'b0;
    end
    else if (enable_i) begin
	
	  //assign current state to next state
	  current_state <= next_state;
    
      // assign the command on dfi_address on CA bus
      command_address_o   <= dfi_address_i;
      // assign the CS signal to dfi_cs
      chip_select_o <= dfi_cs_i;
    
      if (!default_sel) begin
        default_sel <= 1'b1;
    
      // begin with the default values, these values are from  JEDEC
`ifdef BURST_LENGTH_ENABLE  
        burst_length_default <= 2'b00;
        burst_length_new <= 2'b00;
        burst_length_sel_reg <= 1'b0;			
`endif
        pre_pattern_o <= 8'b00000010 ;
        pre_cycle_o <= 3'b010;
        post_cycle_o <= 2'b01;
        dram_crc_en_o <= 1'b0;
      end
      else begin
        
    // assign the outputs to the extracted values from MRW command
`ifdef BURST_LENGTH_ENABLE  
        burst_length_new <= burst_length_inter;
        burst_length_sel_reg <= burst_length_sel;		
`endif
        pre_pattern_o <= pre_pattern_inter;
        pre_cycle_o <= pre_cycle_inter;
        post_cycle_o <= post_cycle_inter;
        dram_crc_en_o <= DRAM_CRC_en_inter;
      end
    
      // when 1st cycle command is valid, store the number of MR in mode register
      if(mode_register_en && (!dfi_cs_i))begin
        mode_register <= dfi_address_i [12:5];
      end
    
      // when 2nd cycle command is valid, store the operation vlue in operation regsiter
      if(operation_en)begin
        operation <= dfi_address_i [7:0];
      end
    end
  end
  
  
  ///////////////////always block to control the flow of the next sate/////////////////////
  /////////////////always block to control the flow of the output signals//////////////////
  
  always_comb begin
  
      
`ifdef BURST_LENGTH_ENABLE  
    burst_length_inter = burst_length_new;
    burst_length_sel = burst_length_sel_reg;	
`endif    
    pre_pattern_inter = pre_pattern_o;
    pre_cycle_inter = pre_cycle_o;
    post_cycle_inter = post_cycle_o;
    DRAM_CRC_en_inter = dram_crc_en_o;

  
    case (current_state)
      IDEL : begin
        // when CS is low and the first command is MRW command go to COMMAND_1ST
        if(!dfi_cs_i && (dfi_address_i[4:0] == 5'b00101)) begin
        next_state = COMMAND_1ST;
        end
        
`ifdef BURST_LENGTH_ENABLE
              else if (!dfi_cs_i && (dfi_address_i[4:0] == 5'b01101)) begin
          next_state = WRITE_1ST;
        end
`endif
        
        else begin
          next_state = IDEL;
        end
		
		mode_register_en = 1'b1; //enable mode register to store the MR number
        operation_en = 1'b0;

      end
    
      COMMAND_1ST : begin
        // when CS is high and the secound cycle command wasn't cancled go to COMMAND_2ND
        if(dfi_cs_i && !dfi_address_i[10]) begin
          next_state = COMMAND_2ND;
        end
        else begin
        next_state = IDEL;
        end
		
		mode_register_en = 1'b0;
        operation_en = 1'b1;     //enable operation register to store to op of the MR
		
      end
      
      COMMAND_2ND : begin
        // go to idel state at the end
        next_state = IDEL;
	  
	    mode_register_en = 1'b0; // disable mode register
        operation_en = 1'b0;     // disable operation register
      
    // decode the mode register 8 value to the desired output signals
        if(mode_register == 8) begin
          case(operation[4:3])
          2'b01: begin
            // 2-cycle pre-amble with pattern "0010"
            pre_pattern_inter = 8'b00000010;
            pre_cycle_inter = 3'b010;
          end
            
          2'b10: begin
              // 3-cycle pre-amble with pattern "000010"
            pre_pattern_inter = 8'b00000010;
            pre_cycle_inter = 3'b011;
          end
            
          2'b11: begin
            // 4-cycle pre-amble with pattern "00001010"
            pre_pattern_inter = 8'b00001010;
            pre_cycle_inter = 3'b100;
          end
          endcase
        
          case (operation[7])
          1'b0: begin
            // 0.5-cycle post-amble with pattern "0"
            post_cycle_inter = 2'b01;
          end
          
          1'b1: begin
            // 1.5-cycle post-amble with pattern "000"
            post_cycle_inter = 2'b10;
          end
          endcase 
        end
        
        // decode the mode register 50 value to the DRAM CRC enable signal
        else if (mode_register == 50) begin
          DRAM_CRC_en_inter = operation[2] | operation[1];
        end

`ifdef BURST_LENGTH_ENABLE 
        // decode the mode register 0 value to the desired burst length value 
        else if (mode_register == 0) begin
          burst_length_inter = operation[1:0];
        end
`endif 

      end
      
`ifdef BURST_LENGTH_ENABLE
      WRITE_1ST : begin
        //go to idel state at the end
        next_state = IDEL;
		
		mode_register_en = 1'b0; // disable mode register
        operation_en = 1'b0;     // disable operation register  
	  
	    // when CS is high check if default or not is wanted
        if(dfi_cs_i) begin
          burst_length_sel = command_address_o[5];
        end
      end
`endif
    
    endcase
  end

  
      
endmodule
