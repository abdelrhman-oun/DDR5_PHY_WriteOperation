/***************************************************************************
** File Name   : asu_ddr5_phy_top.sv
** Authors     : Ain shams university DDR5 GP team
** Created on  : Apr 20, 2022
** Edited on   : 
** description : 
****************************************************************************/

`timescale 1ns / 1ps

module ddr5_phy_top
     # (parameter pDRAM_SIZE = 4,  //DRAM size
	    parameter pNUM_RANK = 2,    //Number of ranks
		parameter logic pCRC_MODE = 1'b1,
		parameter logic [1:0] pFREQ_RATIO  = 2'b00
	 )  
 (
 
        ////////////////input signals//////////////
		
		input wire 					clk_i ,
  		input wire 					rst_i ,
		input wire 					enable_i,
		
		//input dfi_cs_n & dfi_reset_n signals divided into 4 phases each phase is NUM_RANK width
        input   wire  [pNUM_RANK-1:0]              dfi_cs_n_p0,        dfi_cs_n_p1,        dfi_cs_n_p2,        dfi_cs_n_p3,
        input   wire  [pNUM_RANK-1:0]              dfi_reset_n_p0,     dfi_reset_n_p1,     dfi_reset_n_p2,     dfi_reset_n_p3,

        //input dfi_address signal divided into 4 phases each phase is 14 bits
        input   wire  [13:0]                      dfi_address_p0,     dfi_address_p1,     dfi_address_p2,     dfi_address_p3,

        //input dfi_wrdata_en signal divided into 4 phases each phase is 1 bit
        input   wire                              dfi_wrdata_en_p0,   dfi_wrdata_en_p1,   dfi_wrdata_en_p2,   dfi_wrdata_en_p3,

        //input dfi_wrdata signal divided into 4 phases each phase size is double the N
        input   wire  [(2*pDRAM_SIZE)-1:0]       dfi_wrdata_p0,      dfi_wrdata_p1,      dfi_wrdata_p2,      dfi_wrdata_p3,

        //input dfi_wrdata_mask signal divided into 4 phases each phase size is N/4
        input   wire  [(pDRAM_SIZE/4)-1:0]       dfi_wrdata_mask_p0, dfi_wrdata_mask_p1, dfi_wrdata_mask_p2, dfi_wrdata_mask_p3,
		
		
		
		////////////////output signals//////////////
		
		output  wire [pNUM_RANK-1:0] RESET_n,
		
		// output signal is used to select the target rank in DRAM interface
        output wire [pNUM_RANK-1:0]	CS_n,
  
        // ouput bus hols the command to DRAM interface
        output wire [13:0]			CA,
		   
		output wire [2*pDRAM_SIZE -1: 0]   DQ ,

        output wire               DQ_valid ,
        output wire [(pDRAM_SIZE/4-1):0]   DM ,
		output wire [1:0]         DQS ,
		output wire               DQS_valid
		
  			
);
  localparam pDATA_WIDTH	= 4;
  localparam pADDR_WIDTH	= 1;
  
  
  wire phy_CRC_mode;
  wire [1:0] dfi_freq_ratio;

  wire   [pNUM_RANK-1:0]    dfi_cs_n;
  wire   [13:0]            dfi_address;
  wire                     dfi_wrdata_en;
  wire   [(2*pDRAM_SIZE)-1:0]       dfi_wrdata;
  wire   [(pDRAM_SIZE/4)-1:0]       dfi_wrdata_mask;

  wire [1:0]			   burst_length;
  wire [7:0] 		       pre_pattern;
  wire [2:0]			   pre_cycle;
  wire [2:0]			   post_pattrn; 
  wire	[1:0]              post_cycle;  
  wire          		   DRAM_CRC_en;   
  
  wire                     crc_en;
  wire [2*pDRAM_SIZE-1: 0]          crc_in_data;
  wire [2*pDRAM_SIZE-1: 0]          crc_code;


ddr5_phy_frequency_ratio #(.pNUM_RANK(pNUM_RANK),
                  .pDRAM_SIZE(pDRAM_SIZE)
)   FREQ_U (
  .clk_i(clk_i),
  .rst_i(rst_i), 
  .enable_i(enable_i),
  .dfi_freq_ratio_i(dfi_freq_ratio),
  .dfi_cs_n_p0_i(dfi_cs_n_p0),
  .dfi_cs_n_p1_i(dfi_cs_n_p1),
  .dfi_cs_n_p2_i(dfi_cs_n_p2),
  .dfi_cs_n_p3_i(dfi_cs_n_p3),
  .dfi_reset_n_p0_i(dfi_reset_n_p0),
  .dfi_reset_n_p1_i(dfi_reset_n_p1),
  .dfi_reset_n_p2_i(dfi_reset_n_p2),
  .dfi_reset_n_p3_i(dfi_reset_n_p3),
  .dfi_address_p0_i(dfi_address_p0),
  .dfi_address_p1_i(dfi_address_p1), 
  .dfi_address_p2_i(dfi_address_p2),
  .dfi_address_p3_i(dfi_address_p3),
  .dfi_wrdata_en_p0_i(dfi_wrdata_en_p0),
  .dfi_wrdata_en_p1_i(dfi_wrdata_en_p1),   
  .dfi_wrdata_en_p2_i(dfi_wrdata_en_p2),   
  .dfi_wrdata_en_p3_i(dfi_wrdata_en_p3),
  .dfi_wrdata_p0_i(dfi_wrdata_p0),      
  .dfi_wrdata_p1_i(dfi_wrdata_p1),      
  .dfi_wrdata_p2_i(dfi_wrdata_p2),      
  .dfi_wrdata_p3_i(dfi_wrdata_p3),
  .dfi_wrdata_mask_p0_i(dfi_wrdata_mask_p0), 
  .dfi_wrdata_mask_p1_i(dfi_wrdata_mask_p1), 
  .dfi_wrdata_mask_p2_i(dfi_wrdata_mask_p2), 
  .dfi_wrdata_mask_p3_i(dfi_wrdata_mask_p3),
  .dfi_cs_n_o(dfi_cs_n),
  .dfi_reset_n_o(RESET_n),
  .dfi_address_o(dfi_address),
  .dfi_wrdata_en_o(dfi_wrdata_en),
  .dfi_wrdata_o(dfi_wrdata),
  .dfi_wrdata_mask_o(dfi_wrdata_mask)
);

ddr5_phy_command_address #(.pNUM_RANK(pNUM_RANK)
) CA_U (
  .clk_i(clk_i),
  .rst_i(rst_i),
  .enable_i(enable_i),
  .dfi_address_i(dfi_address),
  .dfi_cs_i(dfi_cs_n),
  .chip_select_o(CS_n),
  .command_address_o(CA),
  .burst_length_o(burst_length),
  .pre_pattern_o(pre_pattern),
  .num_pre_cycle_o(pre_cycle),
  .num_post_cycle_o(post_cycle),   
  .dram_crc_en_o(DRAM_CRC_en)  
);

ddr5_phy_crc #(.pDRAM_SIZE(pDRAM_SIZE)
) crc_U (
.clk_i(clk_i),
.rst_i(rst_i),
.crc_en_i(crc_en),
.crc_in_data_i(crc_in_data),
.crc_code_o(crc_code)		
); 


ddr5_phy_write_manager #(.pDRAM_SIZE(pDRAM_SIZE)
) WR_U (
.clk_i(clk_i) ,
.rst_i (rst_i),
.enable_i (enable_i) ,
.wr_en_i(dfi_wrdata_en),
.phy_crc_mode_i(phy_CRC_mode) ,
.dram_crc_en_i(DRAM_CRC_en) ,
.burstlength_i(burst_length),
.precycle_i(pre_cycle),
.postcycle_i(post_cycle),
.wr_data_i (dfi_wrdata),
.wr_datamask_i (dfi_wrdata_mask) ,
.pre_pattern_i (pre_pattern),
.crc_code_i (crc_code),
.dq_o (DQ) ,
.dq_valid_o (DQ_valid),
.dm_o (DM),			 
.dqs_o (DQS),
.dqs_valid_o (DQS_valid),
.crc_data_o(crc_in_data),
.crc_enable_o(crc_en)   
);


ddr5_phy_register_file #(
 .pDATA_WIDTH(pDATA_WIDTH),
 .pADDR_WIDTH(pADDR_WIDTH),
 .pCRC_MODE(pCRC_MODE),
 .pFREQ_RATIO(pFREQ_RATIO)
) REGFILE_U (
.clk_i(clk_i),
.rst_i(rst_i),
.enable_i(enable_i),
.phy_CRC_mode_o(phy_CRC_mode),
.dfi_freq_ratio_o(dfi_freq_ratio) 
);


endmodule













