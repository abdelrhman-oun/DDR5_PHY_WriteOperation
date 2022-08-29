/**********************************************************************************
** Company: Si-Vision & FOE ASU
** Author: AHMED MOSTAFA KAMAL , ADHAM HAZEM ALGENDI AND AHMED MOHAMED AMIN
**
** Create Date: 24/3/2022
** Edited on :  21/4/2022
** Module Name: asu_ddr5_crc
** Description: this file contains the CRC RTL, the design implementation
** is based on IEEE standard (Std 802.15.4-2011)
**
**
*********************************************************************************/


module asu_ddr5_crc
    # (parameter pDRAM_SIZE = 4 )  // parameter indicate the device size (X4, X8, X16)
(
         // input signals //
			input wire 					clk_i ,         // clock signal
  			input wire 					rst_i ,         // active low asynchronous reset
  			input wire 					crc_en_i ,      // enable signal from write data block 
  			input wire  [2*pDRAM_SIZE-1: 0]			crc_in_data_i , // input data bus from write data block that required crc code 
  
          // output signals //
  			output reg  [2*pDRAM_SIZE-1: 0]	    crc_code_o       // output crc bits 
  		
); 




                           // duplicating crc block according to the device size /// 
genvar i ;

  generate
    for ( i=0 ; i< 2*pDRAM_SIZE ; i = i + 8 )
	  begin
        asu_ddr5_crc_x4 crc_x4_U (.crc_in_data_i (crc_in_data_i[i+7 : i]), .crc_code_o(crc_code_o[i+7 : i]) , .clk_i(clk_i), .rst_i(rst_i), .crc_en_i(crc_en_i)) ;
	  end
  endgenerate
endmodule  

