module FREQUENCY_RATIO_TB ();

timeunit 1ps;
timeprecision 1ps;

////////////////////Parameters///////////////////
parameter NUM_RANK_TB = 2;
parameter DEVICE_TYPE_TB = 4;
parameter clock_period = 100;

////////////////Testbench signals/////////////////
reg                                    i_clock, i_reset, i_enable;
reg     [2:0]                          dfi_freq_ratio;
reg     [NUM_RANK_TB-1:0]              dfi_cs_n_p0,        dfi_cs_n_p1,        dfi_cs_n_p2,        dfi_cs_n_p3;
reg     [NUM_RANK_TB-1:0]              dfi_reset_n_p0,     dfi_reset_n_p1,     dfi_reset_n_p2,     dfi_reset_n_p3;
reg     [13:0]                         dfi_address_p0,     dfi_address_p1,     dfi_address_p2,     dfi_address_p3;
reg                                    dfi_wrdata_en_p0,   dfi_wrdata_en_p1,   dfi_wrdata_en_p2,   dfi_wrdata_en_p3;
reg     [(2*DEVICE_TYPE_TB)-1:0]       dfi_wrdata_p0,      dfi_wrdata_p1,      dfi_wrdata_p2,      dfi_wrdata_p3;
reg     [(DEVICE_TYPE_TB/4)-1:0]       dfi_wrdata_mask_p0, dfi_wrdata_mask_p1, dfi_wrdata_mask_p2, dfi_wrdata_mask_p3;

wire     [NUM_RANK_TB-1:0]             dfi_cs_n;
wire     [NUM_RANK_TB-1:0]             dfi_reset_n;
wire     [13:0]                        dfi_address;
wire                                   dfi_wrdata_en;
wire     [(2*DEVICE_TYPE_TB)-1:0]      dfi_wrdata;
wire     [(DEVICE_TYPE_TB/4)-1:0]      dfi_wrdata_mask;


//////////////////initial block////////////////
initial
  begin
    $dumpfile("FREQUENCY_RATIO.vcd") ;
    $dumpvars ;
    
    //initial values
    i_clock = 1'b1;
    i_reset = 1'b0;
    i_enable = 1'b1;
    dfi_freq_ratio = 3'b010;
    dfi_cs_n_p0 = 2'b01;
    dfi_cs_n_p1 = 2'b10;
    dfi_cs_n_p2 = 2'b00;
    dfi_cs_n_p3 = 2'b11;
    dfi_reset_n_p0 = 2'b11;
    dfi_reset_n_p1 = 2'b01;
    dfi_reset_n_p2 = 2'b00;
    dfi_reset_n_p3 = 2'b10;
    dfi_address_p0 = 14'b00000000000000;
    dfi_address_p1 = 14'b11111111111111;
    dfi_address_p2 = 14'b10101010101010;
    dfi_address_p3 = 14'b01010101010101;
    dfi_wrdata_en_p0 = 1'b1;
    dfi_wrdata_en_p1 = 1'b0;
    dfi_wrdata_en_p2 = 1'b0;
    dfi_wrdata_en_p3 = 1'b1;
    dfi_wrdata_p0 = 8'b00000001;
    dfi_wrdata_p1 = 8'b00000010;
    dfi_wrdata_p2 = 8'b00000011;
    dfi_wrdata_p3 = 8'b00000100;
    dfi_wrdata_mask_p0 = 1'b0;
    dfi_wrdata_mask_p1 = 1'b1;
    dfi_wrdata_mask_p2 = 1'b1;
    dfi_wrdata_mask_p3 = 1'b0;
    
    #(clock_period/2)
    //deactivating reset
    i_reset = 1'b1;
    
    #(clock_period)
    //test mapping p0
    if((dfi_cs_n == 2'b01)&&(dfi_reset_n == 2'b11)&&(dfi_address == 14'b00000000000000)&&(dfi_wrdata_en == 1'b1)&&(dfi_wrdata == 8'b00000001)&&(dfi_wrdata_mask == 1'b0))
      $display ("p0 is mapped") ;
    else
      $display ("p0 FAILED") ;
      
    #(clock_period)
    //test mapping p1
    if((dfi_cs_n == 2'b10)&&(dfi_reset_n == 2'b01)&&(dfi_address == 14'b11111111111111)&&(dfi_wrdata_en == 1'b0)&&(dfi_wrdata == 8'b00000010)&&(dfi_wrdata_mask == 1'b1))
      $display ("p1 is mapped") ;
    else
      $display ("p1 FAILED") ;
      
    #(clock_period)
    //test mapping p2
    if((dfi_cs_n == 2'b00)&&(dfi_reset_n == 2'b00)&&(dfi_address == 14'b10101010101010)&&(dfi_wrdata_en == 1'b0)&&(dfi_wrdata == 8'b00000011)&&(dfi_wrdata_mask == 1'b1))
      $display ("p2 is mapped") ;
    else
      $display ("p2 FAILED") ;
      
    #(clock_period)
    //test mapping p3
    if((dfi_cs_n == 2'b11)&&(dfi_reset_n == 2'b10)&&(dfi_address == 14'b01010101010101)&&(dfi_wrdata_en == 1'b1)&&(dfi_wrdata == 8'b00000100)&&(dfi_wrdata_mask == 1'b0))
      $display ("p3 is mapped") ;
    else
      $display ("p3 FAILED") ;
    
    #(clock_period/2)
    
    $finish;
     
  end





////////////////clock generation/////////////////
always #(clock_period/2) i_clock = ~i_clock;





/////////////////instantiation///////////////////
FREQUENCY_RATIO #(.NUM_RANK(NUM_RANK_TB), .DEVICE_TYPE(DEVICE_TYPE_TB)) DUT
(.*);


endmodule

