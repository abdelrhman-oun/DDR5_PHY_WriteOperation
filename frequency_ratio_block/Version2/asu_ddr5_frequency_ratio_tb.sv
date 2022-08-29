module asu_ddr5_frequency_ratio_tb ();

timeunit 1ps;
timeprecision 1ps;

////////////////////Parameters///////////////////
parameter pNUM_RANK_TB   = 2;
parameter pDRAM_SIZE_TB  = 4;
parameter clock_period   = 100;

////////////////Testbench signals/////////////////
reg                                    clk_i, rst_i, enable_i;
reg     [2:0]                          dfi_freq_ratio_i;
reg     [pNUM_RANK_TB-1:0]             dfi_cs_n_p0_i,        dfi_cs_n_p1_i,        dfi_cs_n_p2_i,        dfi_cs_n_p3_i;
reg     [pNUM_RANK_TB-1:0]             dfi_reset_n_p0_i,     dfi_reset_n_p1_i,     dfi_reset_n_p2_i,     dfi_reset_n_p3_i;
reg     [13:0]                         dfi_address_p0_i,     dfi_address_p1_i,     dfi_address_p2_i,     dfi_address_p3_i;
reg                                    dfi_wrdata_en_p0_i,   dfi_wrdata_en_p1_i,   dfi_wrdata_en_p2_i,   dfi_wrdata_en_p3_i;
reg     [(2*pDRAM_SIZE_TB)-1:0]        dfi_wrdata_p0_i,      dfi_wrdata_p1_i,      dfi_wrdata_p2_i,      dfi_wrdata_p3_i;
reg     [(pDRAM_SIZE_TB/4)-1:0]        dfi_wrdata_mask_p0_i, dfi_wrdata_mask_p1_i, dfi_wrdata_mask_p2_i, dfi_wrdata_mask_p3_i;

wire    [pNUM_RANK_TB-1:0]             dfi_cs_n_o;
wire    [pNUM_RANK_TB-1:0]             dfi_reset_n_o;
wire    [13:0]                         dfi_address_o;
wire                                   dfi_wrdata_en_o;
wire    [(2*pDRAM_SIZE_TB)-1:0]        dfi_wrdata_o;
wire    [(pDRAM_SIZE_TB/4)-1:0]        dfi_wrdata_mask_o;


//////////////////initial block////////////////
initial
  begin
    $dumpfile("asu_ddr5_frequency_ratio.vcd") ;
    $dumpvars ;
    
    //initial values
    clk_i = 1'b1;
    rst_i = 1'b0;
    enable_i = 1'b1;
    dfi_freq_ratio_i = 3'b010;
    dfi_cs_n_p0_i = 2'b01;
    dfi_cs_n_p1_i = 2'b10;
    dfi_cs_n_p2_i = 2'b00;
    dfi_cs_n_p3_i = 2'b11;
    dfi_reset_n_p0_i = 2'b11;
    dfi_reset_n_p1_i = 2'b01;
    dfi_reset_n_p2_i = 2'b00;
    dfi_reset_n_p3_i = 2'b10;
    dfi_address_p0_i = 14'b00000000000000;
    dfi_address_p1_i = 14'b11111111111111;
    dfi_address_p2_i = 14'b10101010101010;
    dfi_address_p3_i = 14'b01010101010101;
    dfi_wrdata_en_p0_i = 1'b1;
    dfi_wrdata_en_p1_i = 1'b0;
    dfi_wrdata_en_p2_i = 1'b0;
    dfi_wrdata_en_p3_i = 1'b1;
    dfi_wrdata_p0_i = 8'b00000001;
    dfi_wrdata_p1_i = 8'b00000010;
    dfi_wrdata_p2_i = 8'b00000011;
    dfi_wrdata_p3_i = 8'b00000100;
    dfi_wrdata_mask_p0_i = 1'b0;
    dfi_wrdata_mask_p1_i = 1'b1;
    dfi_wrdata_mask_p2_i = 1'b1;
    dfi_wrdata_mask_p3_i = 1'b0;
    
    #(clock_period/2)
    //deactivating reset
    rst_i = 1'b1;
    
    #(clock_period)
    //test mapping p0
    if((dfi_cs_n_o == 2'b01)&&(dfi_reset_n_o == 2'b11)&&(dfi_address_o == 14'b00000000000000)&&(dfi_wrdata_en_o == 1'b1)&&(dfi_wrdata_o == 8'b00000001)&&(dfi_wrdata_mask_o == 1'b0))
      $display ("p0 is mapped") ;
    else
      $display ("p0 FAILED") ;
      
    #(clock_period)
    //test mapping p1
    if((dfi_cs_n_o == 2'b10)&&(dfi_reset_n_o == 2'b01)&&(dfi_address_o == 14'b11111111111111)&&(dfi_wrdata_en_o == 1'b0)&&(dfi_wrdata_o == 8'b00000010)&&(dfi_wrdata_mask_o == 1'b1))
      $display ("p1 is mapped") ;
    else
      $display ("p1 FAILED") ;
      
    #(clock_period)
    //test mapping p2
    if((dfi_cs_n_o == 2'b00)&&(dfi_reset_n_o == 2'b00)&&(dfi_address_o == 14'b10101010101010)&&(dfi_wrdata_en_o == 1'b0)&&(dfi_wrdata_o == 8'b00000011)&&(dfi_wrdata_mask_o == 1'b1))
      $display ("p2 is mapped") ;
    else
      $display ("p2 FAILED") ;
      
    #(clock_period)
    //test mapping p3
    if((dfi_cs_n_o == 2'b11)&&(dfi_reset_n_o == 2'b10)&&(dfi_address_o == 14'b01010101010101)&&(dfi_wrdata_en_o == 1'b1)&&(dfi_wrdata_o == 8'b00000100)&&(dfi_wrdata_mask_o == 1'b0))
      $display ("p3 is mapped") ;
    else
      $display ("p3 FAILED") ;
    
    #(clock_period/2)
    
    $finish;
     
  end





////////////////clock generation/////////////////
always #(clock_period/2) clk_i = ~clk_i;





/////////////////instantiation///////////////////
asu_ddr5_frequency_ratio #(.pNUM_RANK(pNUM_RANK_TB), .pDRAM_SIZE(pDRAM_SIZE_TB)) DUT
(.*);


endmodule


