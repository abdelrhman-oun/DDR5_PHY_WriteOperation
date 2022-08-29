/***************************************************************************
** File Name   : ddr5_phy_top_BL32_MASK_tb.sv
** Authors     : Ain shams university DDR5 GP team
** Created on  : Apr 20, 2022
** Edited on   : 
** description : 
****************************************************************************/
`timescale 1us/1ns

module ddr5_phy_top_BL32_MASK_tb  ;
			
////////////////////Parameters///////////////////
parameter pDRAM_SIZE = 4;  //DRAM size
parameter pNUM_RANK = 1;    //Number of ranks
parameter logic pCRC_MODE = 1'b0;
parameter logic [1:0] pFREQ_RATIO  = 2'b00 ;
parameter  clock_period = 10 ;
////////////////Testbench signals/////////////////
reg                                    clk_i, rst_i , enable_i;
reg     [2:0]                          dfi_freq_ratio;
reg     [pNUM_RANK-1:0]              dfi_cs_n_p0,        dfi_cs_n_p1,        dfi_cs_n_p2,        dfi_cs_n_p3;
reg     [pNUM_RANK-1:0]              dfi_reset_n_p0,     dfi_reset_n_p1,     dfi_reset_n_p2,     dfi_reset_n_p3;
reg     [13:0]                         dfi_address_p0,     dfi_address_p1,     dfi_address_p2,     dfi_address_p3;
reg                                    dfi_wrdata_en_p0,   dfi_wrdata_en_p1,   dfi_wrdata_en_p2,   dfi_wrdata_en_p3;
reg     [(2*pDRAM_SIZE)-1:0]       dfi_wrdata_p0,      dfi_wrdata_p1,      dfi_wrdata_p2,      dfi_wrdata_p3;
reg     [(pDRAM_SIZE/4)-1:0]       dfi_wrdata_mask_p0, dfi_wrdata_mask_p1, dfi_wrdata_mask_p2, dfi_wrdata_mask_p3;

 	// output signal is used to select the target rank in DRAM interface
          wire [pNUM_RANK-1:0]	CS_n;
  
        // ouput bus hols the command to DRAM interface
          wire [13:0]			CA;
		   
		  wire [2*pDRAM_SIZE -1: 0]   DQ ;

          wire               DQ_valid ;
          wire [(pDRAM_SIZE/4-1):0]   DM ;
		  wire [1:0]         DQS ;
		  wire               DQS_valid ;
		 wire   [pNUM_RANK-1:0]        RESET_n ;
 
  

// parameters
 
  
// instantiate Design Unit
 ////////////////clock generation/////////////////
always #(clock_period/2) clk_i = ~clk_i;





/////////////////instantiation///////////////////
ddr5_phy_top #(.pNUM_RANK(pNUM_RANK), .pDRAM_SIZE(pDRAM_SIZE) ,.pCRC_MODE(pCRC_MODE),.pFREQ_RATIO (pFREQ_RATIO )) DUT
(.*);

  

 
initial
  begin



 rst_i = 1'b0 ; 
# 10 // 1- reset cycle




    clk_i = 1'b0;
    rst_i = 1'b1;
    enable_i = 1'b1;
    dfi_freq_ratio = 2'b00;
    dfi_cs_n_p0 = 1'b1;
    dfi_cs_n_p1 = 1'b1;
    dfi_cs_n_p2 = 1'b1;
    dfi_cs_n_p3 = 1'b1;
    dfi_reset_n_p0 = 1'b1;
    dfi_reset_n_p1 = 1'b1;
    dfi_reset_n_p2 = 1'b1;
    dfi_reset_n_p3 = 1'b1;
    dfi_address_p0 = 14'b0; //wirte command
    dfi_address_p1 = 14'b0;
    dfi_address_p2 = 14'b0;
    dfi_address_p3 = 14'b0;
    dfi_wrdata_en_p0 = 1'b0;
    dfi_wrdata_en_p1 = 1'b0;
    dfi_wrdata_en_p2 = 1'b0;
    dfi_wrdata_en_p3 = 1'b0;
    dfi_wrdata_p0 = 8'b00000000;
    dfi_wrdata_p1 = 8'b00000000;
    dfi_wrdata_p2 = 8'b00000000;
    dfi_wrdata_p3 = 8'b00000000;
    dfi_wrdata_mask_p0 = 1'b0;
    dfi_wrdata_mask_p1 = 1'b0;
    dfi_wrdata_mask_p2 = 1'b0;
    dfi_wrdata_mask_p3 = 1'b0;
	
	#30


// change BL to BL32 

	dfi_cs_n_p0 = 1'b0;
    dfi_address_p0 = 14'b00000000000101;
    
    #clock_period 
    
    dfi_cs_n_p0 = 1'b1;
    dfi_address_p0 = 14'b00000000000010;
    
    #clock_period
    
    dfi_cs_n_p0 = 1'b1;
    dfi_address_p0 = 14'b0;
    
    #(8*clock_period)

	
/*******************************************************************
       test BL32 of first write and BL16 for the secound write 
	      with Mask pre-amble 2cycles  post-amble 0.5cycles
********************************************************************/
	
	// write command
	// change the burst length from the default to the alternate BL mode
	
	dfi_cs_n_p0 = 1'b0;
    dfi_address_p0 = 14'b00000000001101;
	
	dfi_wrdata_en_p0 =1'b1 ;			 
    dfi_wrdata_p0 = 8'b00000000;
    
    #clock_period
    
    dfi_cs_n_p0 = 1'b1;
    dfi_address_p0 = 14'b00000000011100;
	
	dfi_wrdata_en_p0 =1'b1 ;			 
    dfi_wrdata_p0 = 8'b00000000;
    
    #clock_period


    
    dfi_cs_n_p0 = 1'b1;
    dfi_address_p0 = 14'b0;
	
	dfi_wrdata_en_p0 =1'b1 ;
	dfi_wrdata_p0 = 8'b00000000;
    
    #40
	

    dfi_wrdata_en_p0 =1'b1 ;			 
    dfi_wrdata_p0 = 8'b10101010;

    #100 // enable is activated 8clk


	dfi_wrdata_en_p0 =1'b0 ;
			 
	dfi_wrdata_p0 = 8'b10101010;
			 

	# 60 // data done for 8clk  and the gap is 6clk


// secound data
	
	dfi_cs_n_p0 = 1'b0;
    dfi_address_p0 = 14'b10100000101101;
	
	dfi_wrdata_en_p0 =1'b1 ;
	dfi_wrdata_p0 = 8'b00000000;
    
    #clock_period
    
    dfi_cs_n_p0 = 1'b1;
    dfi_address_p0 = 14'b11010000001101;
	
	dfi_wrdata_en_p0 =1'b1 ;
	dfi_wrdata_p0 = 8'b00000000;
    
    #clock_period

    
    dfi_cs_n_p0 = 1'b1;
    dfi_address_p0 = 14'b0;
	
	dfi_wrdata_en_p0 =1'b1 ;
	dfi_wrdata_p0 = 8'b00000000;
    
    #40
	

    dfi_wrdata_en_p0 =1'b1 ;			 
    dfi_wrdata_p0 = 8'b10101010;

    #20 // enable is activated 8clk


	dfi_wrdata_en_p0 =1'b0 ;		 
	dfi_wrdata_p0 = 8'b10101010;
			 
	# 60 // data done for 8clk 


	dfi_wrdata_en_p0 =1'b0 ;
	dfi_wrdata_p0 = 8'b00000000;


/*******************************************************************
     test BL32 with CRC  pre-amble 3cycles  post-amble 1.5cycles
********************************************************************/
	
// change CRC to enable

    dfi_cs_n_p0 = 1'b0;
    dfi_address_p0 = 14'b00011001000101;
    
    #clock_period 
    
    dfi_cs_n_p0 = 1'b1;
    dfi_address_p0 = 14'b00000000000110;
    
    #clock_period
    
    dfi_cs_n_p0 = 1'b1;
    dfi_address_p0 = 14'b0;
    
    #(8*clock_period)
	
	
	
// change the post-amble and the pre-amble
    
    dfi_cs_n_p0 = 1'b0;
    dfi_address_p0 = 14'b00000100000101;
    
    #clock_period

    
    dfi_cs_n_p0 = 1'b1;
    dfi_address_p0 = 14'b00000010010000;
    
    #clock_period
    
    dfi_cs_n_p0 = 1'b1;
    dfi_address_p0 = 14'b0;
	
	#(4*clock_period)
	
	
/******************************************************************************/
	// write command
	// change the burst length from the default to the alternate BL mode
	
	dfi_cs_n_p0 = 1'b0;
    dfi_address_p0 = 14'b00000000001101;
	
	dfi_wrdata_en_p0 =1'b1 ;			 
    dfi_wrdata_p0 = 8'b00000000;
    
    #clock_period
    
    dfi_cs_n_p0 = 1'b1;
    dfi_address_p0 = 14'b00000000011100;
	
	dfi_wrdata_en_p0 =1'b1 ;			 
    dfi_wrdata_p0 = 8'b00000000;
    
    #clock_period

    
    dfi_cs_n_p0 = 1'b1;
    dfi_address_p0 = 14'b0;
	
	dfi_wrdata_en_p0 =1'b1 ;			 
    dfi_wrdata_p0 = 8'b00000000;
    
    #40 

	dfi_wrdata_en_p0 =1'b1 ;			 
	dfi_wrdata_p0 = 8'b10101010;


	#80 //data 1 is done
	
	
	dfi_wrdata_en_p0 =1'b1 ;			 
	dfi_wrdata_p0 = 8'b10011010; // CRC of DATA 1 from CA


	# 10
	
	
	dfi_wrdata_en_p0 =1'b1 ;			 
	dfi_wrdata_p0 = 8'b10101010;


	# 30  
	
	
	dfi_wrdata_en_p0 =1'b0 ;			 
	dfi_wrdata_p0 = 8'b10101010;


	# 50  //DATA 2 IS DONE


	dfi_wrdata_en_p0 =1'b0 ;			 
	dfi_wrdata_p0 = 8'b10011010; // CRC of DATA 1 from CA

	# 10  

	dfi_wrdata_en_p0 =1'b0 ;
	dfi_wrdata_p0 = 8'b00000000;



	 
   #200 $stop;  //finished with simulation 
  end
  



endmodule
















