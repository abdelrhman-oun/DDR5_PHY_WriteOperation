/***************************************************************************
** File Name   : COMMAND_ADDRESS.sv
** Author      : Abdelrahman Oun 
** Created on  : Mar 15, 2022
** description : COMMAND ADDRESS block is used to forward the command from
         the PHY interface to the DRAM interface and extract some
         info from mode register write (MRW) command like pre-amble,
         post-amble and CRC enable.
****************************************************************************/

// comment the next line to make the block don't generate the burst length
`define BURST_LENGTH_ENABLE

module COMMAND_ADDRESS #(
  // parameter used to specify the number of ranks used in the DIMM
  parameter int unsigned      NUM_RANK	= 1
  )(
  
  ////////////////input signals//////////////
  
  // input clock signal
  input logic i_clock,
  
  // input active low asynchronous reset
  input logic i_reset,
  
  // input enable signal
  input logic i_enable,
  
  // input bus from freq ratio block holds the command
  input logic [13:0]			dfi_address,
  
  // input signal is used to select the target rank
  input logic [NUM_RANK-1:0]	dfi_cs_n,
  
  ////////////////output signals//////////////
  
  // output signal is used to select the target rank in DRAM interface
  output logic [NUM_RANK-1:0]	CS_n,
  
  // ouput bus hols the command to DRAM interface
  output logic [13:0]			CA,

`ifdef BURST_LENGTH_ENABLE
    // ouput signal to write data block holds the burst length value
  output logic [5:0]			burst_length,  // may be optimized
`endif

    // output signal to write data block holds the pre-amble pattern
  output logic [7:0]     		pre_pattern,
  
  // output singal to write data block holds pre-amble number of cycles
  output logic [2:0]			pre_cycle,
  
  // output signal to write data block holds the post-amble pattern
  // output logic [2:0]		post_pattern,     //removed from the design
  
  // output signal to write data block holds post-amble number of cycles
  output logic	[1:0]           post_cycle,   
  
  // outout signal to write data block holds if DRAM need CRC or not
  output logic       			DRAM_CRC_en   
  
  
  );
  
  localparam [1:0]  IDEL = 2'b00,
`ifdef BURST_LENGTH_ENABLE
                    WRITE_1ST = 2'b01,
`endif
                    COMMAND_1ST = 2'b10,
                    COMMAND_2ND = 2'b11;
          
          


  logic [1:0] current_state, next_state;
  
  
  // internal signals (inter -> internal)
  // these signals are connected to the registers of the ouput pins
`ifdef BURST_LENGTH_ENABLE  
  logic [5:0]   burst_length_new;
  logic [5:0]   burst_length_default;
  logic         burst_length_sel_reg;
`endif

  
  // default_sel is a flag indicates if it is first time to be in IDEL state
  // mode register en is used to enable the mode register to store the MR number
  // operation en is used to enable the operation register to store the OP value 
  logic default_sel, mode_register_en,operation_en;
  
  // mode register holds the MR number
  // operation holds the OP values
  logic [7:0] mode_register,operation;

    
`ifdef BURST_LENGTH_ENABLE
  // select which register is connected to the output burst length
  // burst_length_sel_reg = 1 => default burst length
  // burst_length_sel_reg = 0 => MR burst will be loaded
  assign burst_length = burst_length_sel_reg ? burst_length_default : burst_length_new;
`endif


  always_ff @ (posedge i_clock or negedge i_reset) begin
    if (!i_reset) begin
	  // output registers
	  CA   <= 14'b0;
      CS_n <= {NUM_RANK{1'b0}};
	  
	  //internal signal
	  mode_register <= 8'b0;
      operation <= 8'b0;
	  
	end
	
	else if (i_enable) begin
      // assign the command on dfi_address on CA bus
      CA   <= dfi_address;
      // assign the CS signal to dfi_cs
      CS_n <= dfi_cs_n;
	  
	  
	  // when 1st cycle command is valid, store the number of MR in mode register
      if(mode_register_en && (!dfi_cs_n))begin
        mode_register <= dfi_address [12:5];
      end
    
      // when 2nd cycle command is valid, store the operation vlue in operation regsiter
      if(operation_en)begin
        operation <= dfi_address [7:0];
      end
	  
	  
	end
  end

  
  
  ///////////////always block to control the flow of current sate register/////////////////
  always_ff @ (posedge i_clock or negedge i_reset) begin
  
    if (!i_reset) begin
      current_state <= IDEL;
    end
    else if (i_enable) begin
      current_state <= next_state;
    end
  end
  
  ///////////////////always block to control the flow of the next sate/////////////////////
  always_comb begin
    unique case (current_state)
      IDEL : begin
        // when CS is low and the first command is MRW command go to COMMAND_1ST
        if(!dfi_cs_n && (dfi_address[4:0] == 5'b00101)) begin
          next_state = COMMAND_1ST;
        end
        
`ifdef BURST_LENGTH_ENABLE
        else if (!dfi_cs_n && (dfi_address[4:0] == 5'b01101)) begin
          next_state = WRITE_1ST;
        end
`endif
        
        else begin
          next_state = IDEL;
        end
      end
    
      COMMAND_1ST : begin
        // when CS is high and the secound cycle command wasn't cancled go to COMMAND_2ND
      if(dfi_cs_n && !dfi_address[10]) begin
          next_state = COMMAND_2ND;
      end
      else begin
        next_state = IDEL;
      end
      end
      
      COMMAND_2ND : begin
        // go to idel state at the end
      next_state = IDEL;
      end
      
`ifdef BURST_LENGTH_ENABLE
          WRITE_1ST : begin
        //go to idel state at the end
      next_state = IDEL;
      end
`endif
    
    endcase
  end


	
  ///////////////////always sequential block to control the flow of the output signals /////////////////////
  always_ff @ (posedge i_clock or negedge i_reset) begin
    if (!i_reset) begin
    
      // output registers
      
`ifdef BURST_LENGTH_ENABLE  
      burst_length_default <= 6'b00;
      burst_length_new <= 6'b00;
      burst_length_sel_reg <= 1'b0;	  
`endif
      pre_pattern <= 8'b0;
      pre_cycle <= 3'b000;
      // post_pattern <= 3'b0;
      post_cycle <= 2'b00;
      DRAM_CRC_en <= 1'b0;
    
      // internal registers
      default_sel <= 1'b0;
    end
    else if (i_enable) begin
	  
      if (!default_sel) begin
        default_sel <= 1'b1;
    
      // begin with the default values, these values are from  JEDEC
`ifdef BURST_LENGTH_ENABLE  
        burst_length_default <= 16;
        burst_length_new <= 16;
        burst_length_sel_reg <= 1'b0;		// MR burst will be loaded	
`endif
        pre_pattern <= 8'b00000010 ;
        pre_cycle <= 3'b010;
        // post_pattern <= 3'b000;
        post_cycle <= 2'b01;
        DRAM_CRC_en <= 1'b0;
      end
      else begin
		
	    unique case (current_state)
		
		  COMMAND_2ND : begin
      
            // decode the mode register 8 value to the desired output signals
            if(mode_register == 8) begin
              unique case(operation[4:3])
				2'b00: begin
				  // reserved
				end 
				  
                2'b01: begin
                 // 2-cycle pre-amble with pattern "0010"
                  pre_pattern <= 8'b00000010;
                  pre_cycle <= 3'b010;
                end
            
                2'b10: begin
                  // 3-cycle pre-amble with pattern "000010"
                  pre_pattern <= 8'b00000010;
                  pre_cycle <= 3'b011;
                end
            
                2'b11: begin
                  // 4-cycle pre-amble with pattern "00001010"
                  pre_pattern <= 8'b00001010;
                  pre_cycle <= 3'b100;
                end
				
				
              endcase
        
              unique case (operation[7])
                1'b0: begin
                  // 0.5-cycle post-amble with pattern "0"
                  // post_pattern <= 3'b000;
                  post_cycle <= 2'b01;
                end
          
                1'b1: begin
                  // 1.5-cycle post-amble with pattern "000"
                  // post_pattern <= 3'b000;
                  post_cycle <= 2'b10;
                end
              endcase 
            end
        
            // decode the mode register 50 value to the DRAM CRC enable signal
            else if (mode_register == 50) begin
              DRAM_CRC_en <= (operation[2:1] != 0)? 1'b1 :  1'b0;
            end

`ifdef BURST_LENGTH_ENABLE 
            // decode the mode register 0 value to the desired burst length value 
            else if (mode_register == 0) begin
			  unique case (operation[1:0])
			    2'b00: begin
                  burst_length_new <= 16;
				end
				
				2'b01: begin
				  burst_length_new <= 8;
				end
				
				2'b10 , 2'b11: begin
				  burst_length_new <= 32;
				end
			  endcase
            end
`endif 
          end
    
`ifdef BURST_LENGTH_ENABLE
          WRITE_1ST : begin
            // when CS is high check if default or not is wanted
            if(dfi_cs_n) begin
              burst_length_sel_reg <= CA[5];
            end
          end
`endif
          default : begin
		  
		  end
        endcase
      end
    end
  end
  


  ///////////////////always combinational block to control the flow of the output signals /////////////////////
  always_comb begin
  
    unique case (current_state)
    
      IDEL : begin
    
        mode_register_en = 1'b1; //enable mode register to store the MR number
        operation_en = 1'b0;
      end
    
      COMMAND_1ST : begin
      
        mode_register_en = 1'b0;
        operation_en = 1'b1;     //enable operation register to store to op of the MR
      end
    
      COMMAND_2ND : begin
    
       mode_register_en = 1'b0; // disable mode register
       operation_en = 1'b0;     // disable operation register  
      end
    
`ifdef BURST_LENGTH_ENABLE
      WRITE_1ST : begin
    
       mode_register_en = 1'b0; // disable mode register
       operation_en = 1'b0;     // disable operation register  
      end
`endif
    endcase
  end    
endmodule
