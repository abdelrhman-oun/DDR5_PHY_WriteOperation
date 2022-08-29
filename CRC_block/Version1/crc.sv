//////////////////////////////////////////////////////////////////////////////////
// Company: Si-Vision & FOE ASU
// Author: AHMED MOSTAFA KAMAL , ADHAM HAZEM ALGENDI AND AHMED MOHAMED AMIN
//
// Create Date: 24/3/2022
// Module Name: crc
// Description: this file contains the CRC RTL, the design implementation
// is based on IEEE standard (Std 802.15.4-2011)
//
//
/////////////////////////////////////////////////////////////////////////////////

module crc_u0 (
          // input signals //
		  
		  
  			input logic 			i_clk ,         // clock signal 
  			input logic 			i_reset ,       // active low asynchronous reset
  			input logic 			i_crc_en ,      // enable signal from write data block 
  			input logic  [7: 0]		i_crc_in_data , // input data bus from write data block that required crc bits
    
	       // output signals //
  			output logic  [7: 0]	o_crc_code      // output crc bits 
  			
  
);
  

logic   [63:0]  data_register;   // internal register to store the input data to generate crc

logic	[3:0]   counter;         // counter counts number of clock cycle start to count when enable get high

logic      data_ready ;          // data_ready is a flag get high when counter equal to 8 to make sure to generate crc to the required data 


always_ff @(posedge i_clk)
  begin   
	if(!i_reset)    // reseting value of the counter and initial storing zeros in data_register
	  begin
		data_register <= 64'b0  ;      
		counter <= 3'b0  ;
		
	  end
	   
	else if(i_crc_en)
	  begin
		if(!data_ready)
		  begin
			data_register  <= {i_crc_in_data , data_register [63 : 8] } ;   // storing input data to data register to generate crc 
			counter <= counter + 1 ;                                        // increment counter by one 
			
		  end
		else
		  begin                                           /// generating crc bits ///////
			o_crc_code[0] = data_register[63] ^ data_register[60] ^
			data_register[56] ^ data_register[54] ^ data_register[53] ^ data_register[52] ^ data_register[50] ^ data_register[49] ^ data_register[48] ^
			data_register[45] ^ data_register[43] ^ data_register[40] ^ data_register[39] ^ data_register[35] ^ data_register[34] ^ data_register[31] ^
			data_register[30] ^ data_register[28] ^ data_register[23] ^ data_register[21] ^ data_register[19] ^ data_register[18] ^ data_register[16] ^
			data_register[14] ^ data_register[12] ^ data_register[8] ^ data_register[7] ^ data_register[6] ^ data_register[0] ;
			
			o_crc_code[1] = data_register[63] ^ data_register[61] ^ data_register[60] ^ data_register[57] ^
			data_register[56] ^ data_register[55] ^ data_register[52] ^ data_register[51] ^ data_register[48] ^ data_register[46] ^ data_register[45] ^
			data_register[44] ^ data_register[43] ^ data_register[41] ^ data_register[39] ^ data_register[36] ^ data_register[34] ^ data_register[32] ^
			data_register[30] ^ data_register[29] ^ data_register[28] ^ data_register[24] ^ data_register[23] ^ data_register[22] ^ data_register[21] ^
			data_register[20] ^ data_register[18] ^ data_register[17] ^ data_register[16] ^ data_register[15] ^ data_register[14] ^ data_register[13] ^
			data_register[12] ^ data_register[9] ^ data_register[6] ^ data_register[1] ^ data_register[0];
			
			o_crc_code[2] = data_register[63] ^ data_register[62] ^ data_register[61] ^ data_register[60] ^
			data_register[58] ^ data_register[57] ^ data_register[54] ^ data_register[50] ^ data_register[48] ^ data_register[47] ^ data_register[46] ^
			data_register[44] ^ data_register[43] ^ data_register[42] ^ data_register[39] ^ data_register[37] ^ data_register[34] ^ data_register[33] ^
			data_register[29] ^ data_register[28] ^ data_register[25] ^ data_register[24] ^ data_register[22] ^ data_register[17] ^ data_register[15] ^
			data_register[13] ^ data_register[12] ^ data_register[10] ^ data_register[8] ^ data_register[6] ^ data_register[2] ^ data_register[1] ^ data_register[0];
			
			o_crc_code[3] = data_register[63] ^ data_register[62] ^ data_register[61] ^ data_register[59] ^
			data_register[58] ^ data_register[55] ^ data_register[51] ^ data_register[49] ^ data_register[48] ^ data_register[47] ^ 
			data_register[45] ^data_register[44] ^ data_register[43] ^ data_register[40] ^ data_register[38] ^ data_register[35] ^ data_register[34] ^ data_register[30] ^
			data_register[29] ^ data_register[26] ^ data_register[25] ^ data_register[23] ^ data_register[18] ^ data_register[16] ^ data_register[14] ^
			data_register[13] ^ data_register[11] ^ data_register[9] ^ data_register[7] ^ data_register[3] ^ data_register[2] ^ data_register[1];
			
			o_crc_code[4] = data_register[63] ^ data_register[62] ^ data_register[60] ^
			data_register[59] ^ data_register[56] ^ data_register[52] ^ data_register[50] ^ data_register[49] ^ data_register[48] ^ data_register[46] ^
			data_register[45] ^ data_register[44] ^ data_register[41] ^ data_register[39] ^ data_register[36] ^ data_register[35] ^ data_register[31] ^
			data_register[30] ^ data_register[27] ^ data_register[26] ^ data_register[24] ^ data_register[19] ^ data_register[17] ^ data_register[15] ^
			data_register[14] ^ data_register[12] ^ data_register[10] ^ data_register[8] ^ data_register[4] ^ data_register[3] ^ data_register[2];
			
			o_crc_code[5] = data_register[63] ^ data_register[61] ^ data_register[60] ^
			data_register[57] ^ data_register[53] ^ data_register[51] ^ data_register[50] ^ data_register[49] ^ data_register[47] ^ data_register[46] ^
			data_register[45] ^ data_register[42] ^ data_register[40] ^ data_register[37] ^ data_register[36] ^ data_register[32] ^ data_register[31] ^
			data_register[28] ^ data_register[27] ^ data_register[25] ^ data_register[20] ^ data_register[18] ^ data_register[16] ^ data_register[15] ^
			data_register[13] ^ data_register[11] ^ data_register[9] ^ data_register[5] ^ data_register[4] ^ data_register[3];

			o_crc_code[6] = data_register[62] ^ data_register[61] ^ data_register[58] ^
			data_register[54] ^ data_register[52] ^ data_register[51] ^ data_register[50] ^ data_register[48] ^ data_register[47] ^ data_register[46] ^
			data_register[43] ^ data_register[41] ^ data_register[38] ^ data_register[37] ^ data_register[33] ^ data_register[32] ^ data_register[29] ^
			data_register[28] ^ data_register[26] ^ data_register[21] ^ data_register[19] ^ data_register[17] ^ data_register[16] ^ data_register[14] ^
			data_register[12] ^ data_register[10] ^ data_register[6] ^ data_register[5] ^ data_register[4];

			o_crc_code[7] = data_register[63] ^ data_register[62] ^ data_register[59] ^
			data_register[55] ^ data_register[53] ^ data_register[52] ^ data_register[51] ^ data_register[49] ^ data_register[48] ^ data_register[47] ^
			data_register[44] ^ data_register[42] ^ data_register[39] ^ data_register[38] ^ data_register[34] ^ data_register[33] ^ data_register[30] ^
			data_register[29] ^ data_register[27] ^ data_register[22] ^ data_register[20] ^ data_register[18] ^ data_register[17] ^ data_register[15] ^
			data_register[13] ^ data_register[11] ^ data_register[7] ^ data_register[6] ^ data_register[5];
			
			
			
			
            counter <= 0 ;              
			
           end
	end	   

  end
  

assign data_ready = (counter == 4'b1000) ? 1 : 0 ;    // all data stored in data_register and ready to generate crc 


endmodule  
		
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
module crc
    # (parameter N = 16)  // parameter indicate the device size (X4, X8, X16)
(
         // input signals //
			input logic 					i_clk ,         // clock signal
  			input logic 					i_reset ,         // active low asynchronous reset
  			input logic 					i_crc_en ,      // enable signal from write data block 
  			input logic  [2*N-1: 0]			i_crc_in_data , // input data bus from write data block that required crc code 
  
          // output signals //
  			output logic  [2*N-1: 0]	    o_crc_code       // output crc bits 
  		
); 




                           // duplicating crc block according to the device size /// 
genvar i ;

  generate
    for ( i=0 ; i< 2*N ; i = i + 8 )
	  begin
        crc_u0 U0 (.i_crc_in_data (i_crc_in_data[i+7 : i]), .o_crc_code(o_crc_code[i+7 : i]) , .i_clk(i_clk), .i_reset(i_reset), .i_crc_en(i_crc_en)) ;
	  end
  endgenerate
endmodule  



