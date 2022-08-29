/*********************************************************************************************
** File Name :   FREQUENCY_RATIO_RTL.sv
** Author :      Muhammad Elmelegy
** Created on :  Mar 15, 2022
** description : FREQUENCY RATIO Block that maps the input signal phases into one phase
                 at the output according to the frequency ratio determined at initialization
**********************************************************************************************/

module FREQUENCY_RATIO #(parameter NUM_RANK = 2,    //Number of ranks                     
                                    
                         parameter DEVICE_TYPE = 4  //Either x4 or x8 or x16
)   
(
/////////////////////////////Input Ports/////////////////////////////////

//the input clock, reset, and enable signals of the FREQUENCY RATIO Block
input   logic                              i_clock, i_reset, i_enable,

//input dfi_freq_ratio signal that carries the frequency ratio to be used
input   logic  [2:0]                       dfi_freq_ratio,

//input dfi_cs_n & dfi_reset_n signals divided into 4 phases each phase is NUM_RANK width
input   logic  [NUM_RANK-1:0]              dfi_cs_n_p0,        dfi_cs_n_p1,        dfi_cs_n_p2,        dfi_cs_n_p3,
input   logic  [NUM_RANK-1:0]              dfi_reset_n_p0,     dfi_reset_n_p1,     dfi_reset_n_p2,     dfi_reset_n_p3,

//input dfi_address signal divided into 4 phases each phase is 14 bits
input   logic  [13:0]                      dfi_address_p0,     dfi_address_p1,     dfi_address_p2,     dfi_address_p3,

//input dfi_wrdata_en signal divided into 4 phases each phase is 1 bit
input   logic                              dfi_wrdata_en_p0,   dfi_wrdata_en_p1,   dfi_wrdata_en_p2,   dfi_wrdata_en_p3,

//input dfi_wrdata signal divided into 4 phases each phase size is double the DEVICE_TYPE
input   logic  [(2*DEVICE_TYPE)-1:0]       dfi_wrdata_p0,      dfi_wrdata_p1,      dfi_wrdata_p2,      dfi_wrdata_p3,

//input dfi_wrdata_mask signal divided into 4 phases each phase size is DEVICE_TYPE/4
input   logic  [(DEVICE_TYPE/4)-1:0]       dfi_wrdata_mask_p0, dfi_wrdata_mask_p1, dfi_wrdata_mask_p2, dfi_wrdata_mask_p3,


/////////////////////////////Output Ports/////////////////////////////////

//output dfi_cs_n & dfi_reset_n signals the input phases of dfi_cs_n & dfi_reset_n will be mapped to these signals
output  logic   [NUM_RANK-1:0]             dfi_cs_n,
output  logic   [NUM_RANK-1:0]             dfi_reset_n,

//the following output signals work the same as dfi_cs_n & dfi_reset_n
output  logic   [13:0]                     dfi_address,
output  logic                              dfi_wrdata_en,
output  logic   [(2*DEVICE_TYPE)-1:0]      dfi_wrdata,
output  logic   [(DEVICE_TYPE/4)-1:0]      dfi_wrdata_mask
);


//phase_select signal will determine which input phase will be mapped to the output (the MUX selector in the block diagram)
//it takes four values 00, 01, 10, 11
logic           [1:0]                      phase_select;

//last_phase signal will determine the last phase to be mapped to the output either p0 or p1 or p3     
logic           [1:0]                      last_phase;

//count_done flag signal determines if the phase_select value equals the last_phase value
logic                                      count_done;



/////////////////////////Mapping dfi_cs_n_p0, ...p1, ...p2, ...p3 signals to dfi_cs_n//////////////////////////////
always_ff @(posedge i_clock or negedge i_reset)
  begin
    if(!i_reset)                                //Asynchronous active low reset
      begin
        dfi_cs_n <= 'b0;                        //{NUM_RANK{1'b0}};        
      end
      
    else if(i_enable)
      begin
        unique case(phase_select)               //checking the value of phase_select signal to choose the phase to be mapped
          2'b00: begin
                  dfi_cs_n <= dfi_cs_n_p0;      //mapping dfi_cs_n_p0 to dfi_cs_n output when phase_select is 00 
                 end
          2'b01: begin
                  dfi_cs_n <= dfi_cs_n_p1;      //mapping dfi_cs_n_p1 to dfi_cs_n output when phase_select is 01
                 end
          2'b10: begin
                  dfi_cs_n <= dfi_cs_n_p2;      //mapping dfi_cs_n_p2 to dfi_cs_n output when phase_select is 10
                 end
          2'b11: begin
                  dfi_cs_n <= dfi_cs_n_p3;      //mapping dfi_cs_n_p3 to dfi_cs_n output when phase_select is 11
                 end
        endcase  
      end
  end


  
/////////////////////////Mapping dfi_reset_n_p0, ...p1, ...p2, ...p3 signals to dfi_reset_n////////////////////////////
always_ff @(posedge i_clock or negedge i_reset)
  begin
    if(!i_reset)
      begin
        dfi_reset_n <= 'b0;               //{NUM_RANK{1'b0}};
      end
      
    else if(i_enable)
      begin
        unique case(phase_select)
          2'b00: begin
                  dfi_reset_n <= dfi_reset_n_p0;
                 end
          2'b01: begin
                  dfi_reset_n <= dfi_reset_n_p1;
                 end
          2'b10: begin
                  dfi_reset_n <= dfi_reset_n_p2;
                 end
          2'b11: begin
                  dfi_reset_n <= dfi_reset_n_p3;
                 end
        endcase  
      end
  end



/////////////////////////Mapping dfi_address_p0, ...p1, ...p2, ...p3 signals to dfi_address/////////////////////////////
always_ff @(posedge i_clock or negedge i_reset)
  begin
    if(!i_reset)
      begin
        dfi_address <= 14'b0;
      end
      
    else if(i_enable)
      begin
        unique case(phase_select)
          2'b00: begin
                  dfi_address <= dfi_address_p0;
                 end
          2'b01: begin
                  dfi_address <= dfi_address_p1;
                 end
          2'b10: begin
                  dfi_address <= dfi_address_p2;
                 end
          2'b11: begin
                  dfi_address <= dfi_address_p3;
                 end
        endcase  
      end
  end



////////////////////////Mapping dfi_wrdata_en_p0, ...p1, ...p2, ...p3 signals to dfi_wrdata_en////////////////////////////
always_ff @(posedge i_clock or negedge i_reset)
  begin
    if(!i_reset)
      begin
        dfi_wrdata_en <= 1'b0;
      end
      
    else if(i_enable)
      begin
        unique case(phase_select)
          2'b00: begin
                  dfi_wrdata_en <= dfi_wrdata_en_p0;
                 end
          2'b01: begin
                  dfi_wrdata_en <= dfi_wrdata_en_p1;
                 end
          2'b10: begin
                  dfi_wrdata_en <= dfi_wrdata_en_p2;
                 end
          2'b11: begin
                  dfi_wrdata_en <= dfi_wrdata_en_p3;
                 end
        endcase  
      end
  end


/////////////////////////////Mapping dfi_wrdata_p0, ...p1, ...p2, ...p3 signals to dfi_wrdata/////////////////////////////////
always_ff @(posedge i_clock or negedge i_reset)
  begin
    if(!i_reset)                                
      begin
        dfi_wrdata <= 'b0;                      //{(2*DEVICE_TYPE){1'b0}};
      end
      
    else if(i_enable)
      begin
        unique case(phase_select)
          2'b00: begin
                  dfi_wrdata <= dfi_wrdata_p0;
                 end
          2'b01: begin
                  dfi_wrdata <= dfi_wrdata_p1;
                 end
          2'b10: begin
                  dfi_wrdata <= dfi_wrdata_p2;
                 end
          2'b11: begin
                  dfi_wrdata <= dfi_wrdata_p3;
                 end
        endcase  
      end
  end



/////////////////////////Mapping dfi_wrdata_mask_p0, ...p1, ...p2, ...p3 signals to dfi_wrdata_mask///////////////////////////////
always_ff @(posedge i_clock or negedge i_reset)
  begin
    if(!i_reset)                              
      begin
        dfi_wrdata_mask <= 'b0;               //{(DEVICE_TYPE/4){1'b0}};
      end
      
    else if(i_enable)
      begin
        unique case(phase_select)
          2'b00: begin
                  dfi_wrdata_mask <= dfi_wrdata_mask_p0;
                 end
          2'b01: begin
                  dfi_wrdata_mask <= dfi_wrdata_mask_p1;
                 end
          2'b10: begin
                  dfi_wrdata_mask <= dfi_wrdata_mask_p2;
                 end
          2'b11: begin
                  dfi_wrdata_mask <= dfi_wrdata_mask_p3;
                 end
        endcase  
      end
  end



///////////////////////2-bit counter whose output is phase_select which will be the MUXs selector////////////////////////////
always_ff @(posedge i_clock or negedge i_reset)
  begin
    if(!i_reset)                                //Asynchronous active low reset
      begin
        phase_select <= 2'b0;
      end
      
    else if(i_enable && !count_done)            //the couter will continue counting if count_done signal is low
      begin
        phase_select <= phase_select + 2'b1;  
      end
      
    else if(i_enable && count_done)             //when count_done signal is high then the counter has reached the last phase
      begin                                     //so it will be reset to 00 and start again
        phase_select <= 2'b0;  
      end
  end



/*

Ratio              dfi_freq_ratio                	last_phase
                  [2]    [1]    [0]                  [1]  [0]
 1:1               0      0      0                    0    0
 1:2               0      0      1                    0    1
 1:4               0      1      0                    1    1

*/

//from the previous truth table last_phase signal can be determined as following
assign last_phase[0] = dfi_freq_ratio[1] | dfi_freq_ratio[0];
assign last_phase[1] = dfi_freq_ratio[1];

//count_done flag is high when the counter output (phase_select) reaches the last phase (last_phase)
assign count_done = (phase_select == last_phase);



endmodule