/*********************************************************************************************
** File Name   : asu_ddr5_frequency_ratio.sv
** Author      : Muhammad Elmelegy
** Created on  : Mar 15, 2022
** Edited on   : Apr 21, 2022
** description : FREQUENCY RATIO Block that maps the input signal phases into one phase
                 at the output according to the frequency ratio determined at initialization
**********************************************************************************************/
`timescale 1ns / 1ps


module ddr5_phy_frequency_ratio #(parameter pNUM_RANK = 2,    //Number of ranks                     
                                    
                                  parameter pDRAM_SIZE = 4  //Either x4 or x8 or x16
)   
(
/////////////////////////////Input Ports/////////////////////////////////

//the input clock, reset, and enable signals of the FREQUENCY RATIO Block
input   wire                              clk_i, rst_i, enable_i,

//input dfi_freq_ratio_i signal that carries the frequency ratio to be used
input   wire  [1:0]                       dfi_freq_ratio_i,

//input dfi_cs_n_i & dfi_reset_n_i signals divided into 4 phases each phase is pNUM_RANK width
input   wire  [pNUM_RANK-1:0]             dfi_cs_n_p0_i,        dfi_cs_n_p1_i,        dfi_cs_n_p2_i,        dfi_cs_n_p3_i,
input   wire  [pNUM_RANK-1:0]             dfi_reset_n_p0_i,     dfi_reset_n_p1_i,     dfi_reset_n_p2_i,     dfi_reset_n_p3_i,

//input dfi_address_i signal divided into 4 phases each phase is 14 bits
input   wire  [13:0]                      dfi_address_p0_i,     dfi_address_p1_i,     dfi_address_p2_i,     dfi_address_p3_i,

//input dfi_wrdata_en_i signal divided into 4 phases each phase is 1 bit
input   wire                              dfi_wrdata_en_p0_i,   dfi_wrdata_en_p1_i,   dfi_wrdata_en_p2_i,   dfi_wrdata_en_p3_i,

//input dfi_wrdata_i signal divided into 4 phases each phase size is double the pDRAM_SIZE
input   wire  [(2*pDRAM_SIZE)-1:0]        dfi_wrdata_p0_i,      dfi_wrdata_p1_i,      dfi_wrdata_p2_i,      dfi_wrdata_p3_i,

//input dfi_wrdata_mask_i signal divided into 4 phases each phase size is pDRAM_SIZE/4
input   wire  [(pDRAM_SIZE/4)-1:0]        dfi_wrdata_mask_p0_i, dfi_wrdata_mask_p1_i, dfi_wrdata_mask_p2_i, dfi_wrdata_mask_p3_i,


/////////////////////////////Output Ports/////////////////////////////////

//output dfi_cs_n_o & dfi_reset_n_o signals the input phases of dfi_cs_n_i & dfi_reset_n_i will be mapped to these signals
output  reg   [pNUM_RANK-1:0]             dfi_cs_n_o,
output  reg   [pNUM_RANK-1:0]             dfi_reset_n_o,

//the following output signals work the same as dfi_cs_n_o & dfi_reset_n_o
output  reg   [13:0]                      dfi_address_o,
output  reg                               dfi_wrdata_en_o,
output  reg   [(2*pDRAM_SIZE)-1:0]        dfi_wrdata_o,
output  reg   [(pDRAM_SIZE/4)-1:0]        dfi_wrdata_mask_o
);


//phase_select signal will determine which input phase will be mapped to the output (the MUX selector in the block diagram)
//it takes four values 00, 01, 10, 11
reg           [1:0]                       phase_select;

//last_phase signal will determine the last phase to be mapped to the output either p0 or p1 or p3     
wire          [1:0]                       last_phase;

//count_done flag signal determines if the phase_select value equals the last_phase value
wire                                      count_done;



/////////////////////////Mapping dfi_cs_n_p0_i, ...p1_i, ...p2_i, ...p3_i signals to dfi_cs_n_o//////////////////////////////
always_ff @(posedge clk_i or negedge rst_i)
  begin
    if(!rst_i)                                      //Asynchronous active low reset
      begin
        dfi_cs_n_o <= 'b0;                          //{pNUM_RANK{1'b0}};        
      end
      
    else if(enable_i)
      begin
        unique case(phase_select)                   //checking the value of phase_select signal to choose the phase to be mapped
          2'b00: begin
                  dfi_cs_n_o <= dfi_cs_n_p0_i;      //mapping dfi_cs_n_p0_i to dfi_cs_n_o output when phase_select is 00 
                 end
          2'b01: begin
                  dfi_cs_n_o <= dfi_cs_n_p1_i;      //mapping dfi_cs_n_p1_i to dfi_cs_n_o output when phase_select is 01
                 end
          2'b10: begin
                  dfi_cs_n_o <= dfi_cs_n_p2_i;      //mapping dfi_cs_n_p2_i to dfi_cs_n_o output when phase_select is 10
                 end
          2'b11: begin
                  dfi_cs_n_o <= dfi_cs_n_p3_i;      //mapping dfi_cs_n_p3_i to dfi_cs_n_o output when phase_select is 11
                 end
        endcase  
      end
  end


  
/////////////////////////Mapping dfi_reset_n_p0_i, ...p1_i, ...p2_i, ...p3_i signals to dfi_reset_n_o////////////////////////////
always_ff @(posedge clk_i or negedge rst_i)
  begin
    if(!rst_i)
      begin
        dfi_reset_n_o <= 'b0;                       //{pNUM_RANK{1'b0}};
      end
      
    else if(enable_i)
      begin
        unique case(phase_select)
          2'b00: begin
                  dfi_reset_n_o <= dfi_reset_n_p0_i;
                 end
          2'b01: begin
                  dfi_reset_n_o <= dfi_reset_n_p1_i;
                 end
          2'b10: begin
                  dfi_reset_n_o <= dfi_reset_n_p2_i;
                 end
          2'b11: begin
                  dfi_reset_n_o <= dfi_reset_n_p3_i;
                 end
        endcase  
      end
  end



/////////////////////////Mapping dfi_address_p0_i, ...p1_i, ...p2_i, ...p3_i signals to dfi_address_o/////////////////////////////
always_ff @(posedge clk_i or negedge rst_i)
  begin
    if(!rst_i)
      begin
        dfi_address_o <= 14'b0;
      end
      
    else if(enable_i)
      begin
        unique case(phase_select)
          2'b00: begin
                  dfi_address_o <= dfi_address_p0_i;
                 end
          2'b01: begin
                  dfi_address_o <= dfi_address_p1_i;
                 end
          2'b10: begin
                  dfi_address_o <= dfi_address_p2_i;
                 end
          2'b11: begin
                  dfi_address_o <= dfi_address_p3_i;
                 end
        endcase  
      end
  end



////////////////////////Mapping dfi_wrdata_en_p0_i, ...p1_i, ...p2_i, ...p3_i signals to dfi_wrdata_en_o////////////////////////////
always_ff @(posedge clk_i or negedge rst_i)
  begin
    if(!rst_i)
      begin
        dfi_wrdata_en_o <= 1'b0;
      end
      
    else if(enable_i)
      begin
        unique case(phase_select)
          2'b00: begin
                  dfi_wrdata_en_o <= dfi_wrdata_en_p0_i;
                 end
          2'b01: begin
                  dfi_wrdata_en_o <= dfi_wrdata_en_p1_i;
                 end
          2'b10: begin
                  dfi_wrdata_en_o <= dfi_wrdata_en_p2_i;
                 end
          2'b11: begin
                  dfi_wrdata_en_o <= dfi_wrdata_en_p3_i;
                 end
        endcase  
      end
  end


/////////////////////////////Mapping dfi_wrdata_p0_i, ...p1_i, ...p2_i, ...p3_i signals to dfi_wrdata_o/////////////////////////////////
always_ff @(posedge clk_i or negedge rst_i)
  begin
    if(!rst_i)                                
      begin
        dfi_wrdata_o <= 'b0;                        //{(2*pDRAM_SIZE){1'b0}};
      end
      
    else if(enable_i)
      begin
        unique case(phase_select)
          2'b00: begin
                  dfi_wrdata_o <= dfi_wrdata_p0_i;
                 end
          2'b01: begin
                  dfi_wrdata_o <= dfi_wrdata_p1_i;
                 end
          2'b10: begin
                  dfi_wrdata_o <= dfi_wrdata_p2_i;
                 end
          2'b11: begin
                  dfi_wrdata_o <= dfi_wrdata_p3_i;
                 end
        endcase  
      end
  end



/////////////////////////Mapping dfi_wrdata_mask_p0_i, ...p1_i, ...p2_i, ...p3_i signals to dfi_wrdata_mask_o///////////////////////////////
always_ff @(posedge clk_i or negedge rst_i)
  begin
    if(!rst_i)                              
      begin
        dfi_wrdata_mask_o <= 'b0;                   //{(pDRAM_SIZE/4){1'b0}};
      end
      
    else if(enable_i)
      begin
        unique case(phase_select)
          2'b00: begin
                  dfi_wrdata_mask_o <= dfi_wrdata_mask_p0_i;
                 end
          2'b01: begin
                  dfi_wrdata_mask_o <= dfi_wrdata_mask_p1_i;
                 end
          2'b10: begin
                  dfi_wrdata_mask_o <= dfi_wrdata_mask_p2_i;
                 end
          2'b11: begin
                  dfi_wrdata_mask_o <= dfi_wrdata_mask_p3_i;
                 end
        endcase  
      end
  end



///////////////////////2-bit counter whose output is phase_select which will be the MUXs selector////////////////////////////
always_ff @(posedge clk_i or negedge rst_i)
  begin
    if(!rst_i)                                      //Asynchronous active low reset
      begin
        phase_select <= 2'b0;
      end
      
    else if(enable_i && !count_done)                //the couter will continue counting if count_done signal is low
      begin
        phase_select <= phase_select + 2'b1;  
      end
      
    else if(enable_i && count_done)                 //when count_done signal is high then the counter has reached the last phase
      begin                                         //so it will be reset to 00 and start again
        phase_select <= 2'b0;  
      end
  end



/*

Ratio              dfi_freq_ratio_i             last_phase
                     [1]    [0]                  [1]  [0]
 1:1                  0      0                    0    0
 1:2                  0      1                    0    1
 1:4                  1      0                    1    1

*/

//from the previous truth table last_phase signal can be determined as following
assign last_phase[0] = dfi_freq_ratio_i[1] | dfi_freq_ratio_i[0];
assign last_phase[1] = dfi_freq_ratio_i[1];

//count_done flag is high when the counter output (phase_select) reaches the last phase (last_phase)
assign count_done = (phase_select == last_phase);



endmodule