/***************************************************************************
** File Name   : COMMAND_ADDRESS_tb.sv
** Author      : Abdelrahman Oun 
** Created on  : Mar 15, 2022
** description : funcational verificaiton to COMMAND_ADDRESS.sv  moduel
****************************************************************************/

`timescale 1ns / 1ns

`define BURST_LENGTH_ENABLE

module COMMAND_ADDRESS_tb;
  
  parameter CLK_PERIOD = 50;
  
  parameter NUM_RANK = 1;
  
  //input signals
  logic i_clock, i_reset, i_enable;
  logic [13:0]			dfi_address;
  logic [NUM_RANK-1:0]	dfi_cs_n;
  
  //output signals
  logic [NUM_RANK-1:0]	CS_n; 
  logic [13:0]		CA;
`ifdef BURST_LENGTH_ENABLE
  logic [5:0]			burst_length;
`endif
  logic [7:0] 		pre_pattern;
  logic [2:0]			pre_cycle;
  //logic [2:0]			post_pattern;
  logic	[1:0]   post_cycle;
  logic 			DRAM_CRC_en;
  
  ///////////////////////DUT Instabtation//////////////////////
  
  COMMAND_ADDRESS #(
    .NUM_RANK(NUM_RANK)
  ) DUT (
    .i_clock(i_clock),
    .i_reset(i_reset),
    .i_enable(i_enable),
    .dfi_address(dfi_address),
    .dfi_cs_n(dfi_cs_n),
    .CS_n(CS_n),
    .CA(CA),
`ifdef BURST_LENGTH_ENABLE
    .burst_length(burst_length),
`endif
    .pre_pattern(pre_pattern),
    .pre_cycle(pre_cycle),
    //.post_pattern(post_pattern),
    .post_cycle(post_cycle),
    .DRAM_CRC_en(DRAM_CRC_en)
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
    
    // write command
    dfi_cs_n = 1'b0;
    dfi_address = 14'b10100000001101;
    
    #CLK_PERIOD
    if((CS_n == 1'b0) && (CA == 14'b10100000001101))
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
        if((pre_pattern == 8'b00001010) && (pre_cycle == 4) &&  (post_cycle == 2) )
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
    
    // mode register write command
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
        if(burst_length == 16)
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
        if(burst_length == 32)
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
  
  