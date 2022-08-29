/***************************************************************************
** File Name   : asu_ddr5_command_address_tb.sv
** Author      : Abdelrahman Oun 
** Created on  : Mar 15, 2022
** Edited on   : Apr 21, 2022
** description : funcational verificaiton to COMMAND_ADDRESS.sv  moduel
****************************************************************************/

`timescale 1us / 1ns

`define BURST_LENGTH_ENABLE

module ddr5_phy_command_address_tb;
  
  parameter CLK_PERIOD = 10;
  
  parameter NUM_RANK = 1;
  
  //input signals
  reg i_clock, i_reset, i_enable;
  reg [13:0]			dfi_address;
  reg [NUM_RANK-1:0]	dfi_cs_n;
  
  //output signals
  wire [NUM_RANK-1:0]	CS_n; 
  wire [13:0]		    CA;
`ifdef BURST_LENGTH_ENABLE
  wire [1:0]			burst_length;
`endif
  wire [7:0] 		    pre_pattern;
  wire [2:0]			pre_cycle;
  wire	[1:0]           post_cycle;
  wire			DRAM_CRC_en;
  
  ///////////////////////DUT Instabtation//////////////////////
  
  ddr5_phy_command_address #(
    .pNUM_RANK(NUM_RANK)
  ) DUT (
    .clk_i(i_clock),
    .rst_i(i_reset),
    .enable_i(i_enable),
    .dfi_address_i(dfi_address),
    .dfi_cs_i(dfi_cs_n),
    .chip_select_o(CS_n),
    .command_address_o(CA),
`ifdef BURST_LENGTH_ENABLE
    .burst_length_o(burst_length),
`endif
    .pre_pattern_o(pre_pattern),
    .num_pre_cycle_o(pre_cycle),
    .num_post_cycle_o(post_cycle),
    .dram_crc_en_o(DRAM_CRC_en)
  );
  
  /////////////////////// Clock Generator /////////////////////
  
  always #(CLK_PERIOD/2) i_clock = ~i_clock;
  
  
  // Initial block
  initial begin
    
    //initialization
    initialize();
    
    //reset the design
    reset();
    
    // test begin
    #CLK_PERIOD
    
    // write command default BL => BL16
    dfi_cs_n = 1'b0;
    dfi_address = 14'b10100000101101;
    
    #CLK_PERIOD
    if((CS_n == 1'b0) && (CA == 14'b10100000101101))
      $display("OK");
    else
      $display("NOT OK !!!!!");
    
    dfi_cs_n = 1'b1;
    dfi_address = 14'b11010000001101;
    
    #CLK_PERIOD
        if((CS_n == 1'b1) && (CA == 14'b11010000001101))
          $display("test case 1 passed");
        else
          $display("NOT OK !!!!!");
    
    dfi_cs_n = 1'b1;
    dfi_address = 14'b0;
    
//////////////////////////////////////////////////////////////////////////////////////////////////////////////    
    #(4*CLK_PERIOD)
    
    // mode register write command
    // change the post-amble and the pre-amble
    dfi_cs_n = 1'b0;
    dfi_address = 14'b00000100000101;
    
    #CLK_PERIOD
    if((CS_n == 1'b0) && (CA == 14'b00000100000101))
      $display("OK");
    else
      $display("NOT OK !!!!!");
    
    dfi_cs_n = 1'b1;
    dfi_address = 14'b00000010011000;
    
    #CLK_PERIOD
        if((CS_n == 1'b1) && (CA == 14'b00000010011000))
          $display("OK");
        else
          $display("NOT OK !!!!!");
    
    dfi_cs_n = 1'b1;
    dfi_address = 14'b0;
    
    #CLK_PERIOD
        if((pre_pattern == 8'b00001010) && (pre_cycle == 3'b100) && (post_cycle == 2'b10) )
          $display("test case 2 passed");
        else
          $display("NOT OK !!!!!");
          
          
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
    #(4*CLK_PERIOD)
    
    // mode register write command
    // change the CRC enable
    dfi_cs_n = 1'b0;
    dfi_address = 14'b00011001000101;
    
    #CLK_PERIOD
    if((CS_n == 1'b0) && (CA == 14'b00011001000101))
      $display("OK");
    else
      $display("NOT OK !!!!!");
    
    dfi_cs_n = 1'b1;
    dfi_address = 14'b00000000000110;
    
    #CLK_PERIOD
        if((CS_n == 1'b1) && (CA == 14'b00000000000110))
          $display("OK");
        else
          $display("NOT OK !!!!!");
    
    dfi_cs_n = 1'b1;
    dfi_address = 14'b0;
    
    #CLK_PERIOD
        if(DRAM_CRC_en == 1'b1)
          $display("test case 3 passed");
        else
          $display("NOT OK !!!!!");
          
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

`ifdef BURST_LENGTH_ENABLE /*******************************/
          
    #(4*CLK_PERIOD)
    
    // write command
    // change the burst length from the default to the alternate BL mode
    dfi_cs_n = 1'b0;
    dfi_address = 14'b00000000001101;
    
    #CLK_PERIOD
    if((CS_n == 1'b0) && (CA == 14'b00000000001101))
      $display("OK");
    else
      $display("NOT OK !!!!!");
    
    dfi_cs_n = 1'b1;
    dfi_address = 14'b00000000011100;
    
    #CLK_PERIOD
        if((CS_n == 1'b1) && (CA == 14'b00000000011100))
          $display("OK");
        else
          $display("NOT OK !!!!!");
    
    dfi_cs_n = 1'b1;
    dfi_address = 14'b0;
    
    #CLK_PERIOD
        if(burst_length == 2'b00)
          $display("test case 4 passed");
        else
          $display("NOT OK !!!!!");
          
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////          
    #(4*CLK_PERIOD)
    
    // mode register write command
    // change the burst length
    dfi_cs_n = 1'b0;
    dfi_address = 14'b00000000000101;
    
    #CLK_PERIOD
    if((CS_n == 1'b0) && (CA == 14'b00000000000101))
      $display("OK");
    else
      $display("NOT OK !!!!!");
    
    dfi_cs_n = 1'b1;
    dfi_address = 14'b00000000000011;
    
    #CLK_PERIOD
        if((CS_n == 1'b1) && (CA == 14'b00000000000011))
          $display("OK");
        else
          $display("NOT OK !!!!!");
    
    dfi_cs_n = 1'b1;
    dfi_address = 14'b0;
    
    #CLK_PERIOD
        if(burst_length == 2'b11)
          $display("test case 5 passed");
        else
          $display("NOT OK !!!!!");
          
`endif /*******************************/
    
    
    #100;
    $stop;
    
  end
  
  ///////////////////////////// Tasks /////////////////////////
  
  task initialize;
    begin
      i_clock = 1'b1;
      i_enable = 1'b1;
      dfi_cs_n = 1'b1;
      dfi_address = 13'b0;
    end
  endtask
  
  task reset;
    begin
      i_reset = 1'b0;
      #(CLK_PERIOD/2)
      i_reset = 1'b1;
    end
  endtask
      
endmodule
  
  