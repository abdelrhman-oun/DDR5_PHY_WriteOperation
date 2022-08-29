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
		  
		  
  			input wire 			i_clk ,         // clock signal 
  			input wire 			i_reset ,       // active low asynchronous reset
  			input wire 			i_crc_en ,      // enable signal from write data block 
  			input wire  [7: 0]		i_crc_in_data , // input data bus from write data block that required crc bits
    
	       // output signals //
  			output wire  [7: 0]	o_crc_code      // output crc bits 
  			
  
);
  

reg   [7:0]  data_register;   // internal register to store the input data to generate crc

reg	[3:0]   counter;         // counter counts number of clock cycle start to count when enable get high




always_ff @(posedge i_clk)
  begin   
	if(!i_reset)    // reseting value of the counter and initial storing zeros in data_register
	  begin
		data_register <= 8'b0  ;      
		counter <= 3'b0  ;
		
	  end
	   
	else if(i_crc_en)
	  begin
		counter <= counter + 1 ;   
		
		
		                          /// generating crc bits ///////
		
		case (counter)
		
		                        //0-7//
	4'b0000 : begin
			data_register[0] <= i_crc_in_data[0] ^ i_crc_in_data[6] ^ i_crc_in_data[7];
			data_register[1] <= i_crc_in_data[0] ^ i_crc_in_data[1] ^ i_crc_in_data[6] ;
			data_register[2] <= i_crc_in_data[0] ^ i_crc_in_data[1] ^ i_crc_in_data[2] ^ i_crc_in_data[6];
		    data_register[3] <= i_crc_in_data[1] ^ i_crc_in_data[2] ^ i_crc_in_data[3] ^ i_crc_in_data[7];
			data_register[4] <= i_crc_in_data[2] ^ i_crc_in_data[3] ^ i_crc_in_data[4] ;
			data_register[5] <= i_crc_in_data[3] ^ i_crc_in_data[4] ^ i_crc_in_data[5] ;
			data_register[6] <= i_crc_in_data[4] ^ i_crc_in_data[5] ^ i_crc_in_data[6] ;
		    data_register[7] <= i_crc_in_data[5] ^ i_crc_in_data[6] ^ i_crc_in_data[7];
			end
			
			                //8-15//
	4'b0001 :  begin              
              data_register[0] <= data_register[0] ^ i_crc_in_data[4] ^ i_crc_in_data[6] ^ i_crc_in_data[0];
			  data_register[1] <= data_register[1] ^ i_crc_in_data[1] ^ i_crc_in_data[4] ^ i_crc_in_data[5]^ i_crc_in_data[6]^ i_crc_in_data[7];
			  data_register[2] <= data_register[2] ^ i_crc_in_data[0] ^ i_crc_in_data[2] ^ i_crc_in_data[4]^ i_crc_in_data[5] ^ i_crc_in_data[7];
			  data_register[3] <= data_register[3] ^ i_crc_in_data[1] ^ i_crc_in_data[3] ^ i_crc_in_data[5] ^ i_crc_in_data[6];
			  data_register[4] <= data_register[4] ^ i_crc_in_data[0] ^ i_crc_in_data[2] ^ i_crc_in_data[4]^ i_crc_in_data[6] ^ i_crc_in_data[7];
			  data_register[5] <= data_register[5] ^ i_crc_in_data[1] ^ i_crc_in_data[3] ^ i_crc_in_data[5]^ i_crc_in_data[7];
			  data_register[6] <= data_register[6] ^ i_crc_in_data[2] ^ i_crc_in_data[4] ^ i_crc_in_data[6];
			  data_register[7] <= data_register[7] ^ i_crc_in_data[3] ^ i_crc_in_data[5] ^ i_crc_in_data[7];
                end
		
		                    //16-23//
	4'b0010 : begin              
              data_register[0] <= data_register[0] ^ i_crc_in_data[0] ^ i_crc_in_data[2] ^ i_crc_in_data[3] ^ i_crc_in_data[5] ^ i_crc_in_data[7];
			  data_register[1] <= data_register[1] ^ i_crc_in_data[0] ^ i_crc_in_data[1] ^ i_crc_in_data[2]^ i_crc_in_data[4] ^ i_crc_in_data[5] ^ i_crc_in_data[6]^ i_crc_in_data[7];
			  data_register[2] <= data_register[2] ^ i_crc_in_data[1] ^ i_crc_in_data[6] ;
		      data_register[3] <= data_register[3] ^ i_crc_in_data[0]^ i_crc_in_data[2] ^ i_crc_in_data[7] ;
		      data_register[4] <= data_register[4] ^ i_crc_in_data[1] ^ i_crc_in_data[3] ;
			  data_register[5] <= data_register[5] ^ i_crc_in_data[0] ^ i_crc_in_data[2] ^ i_crc_in_data[4];
	    	  data_register[6] <= data_register[6] ^ i_crc_in_data[0] ^ i_crc_in_data[1] ^ i_crc_in_data[3]^ i_crc_in_data[5];
			  data_register[7] <= data_register[7] ^ i_crc_in_data[1] ^ i_crc_in_data[2] ^ i_crc_in_data[4]^ i_crc_in_data[6];
                end
				
				         //24-31//
	4'b0011 : begin              
            data_register[0] <= data_register[0] ^ i_crc_in_data[4] ^ i_crc_in_data[6] ^ i_crc_in_data[7];
			data_register[1] <= data_register[1] ^ i_crc_in_data[0] ^ i_crc_in_data[4] ^ i_crc_in_data[5]^ i_crc_in_data[6];
			data_register[2] <= data_register[2] ^ i_crc_in_data[0] ^ i_crc_in_data[1] ^ i_crc_in_data[4]^ i_crc_in_data[5];
			data_register[3] <= data_register[3] ^ i_crc_in_data[1] ^ i_crc_in_data[2] ^ i_crc_in_data[5]^ i_crc_in_data[6];
			data_register[4] <= data_register[4] ^ i_crc_in_data[0] ^ i_crc_in_data[2] ^ i_crc_in_data[3]^ i_crc_in_data[6] ^ i_crc_in_data[7];
		    data_register[5] <= data_register[5] ^ i_crc_in_data[1] ^ i_crc_in_data[3] ^ i_crc_in_data[4]^ i_crc_in_data[7];
			data_register[6] <= data_register[6] ^ i_crc_in_data[2] ^ i_crc_in_data[4] ^ i_crc_in_data[5];
			data_register[7] <= data_register[7] ^ i_crc_in_data[3] ^ i_crc_in_data[5] ^ i_crc_in_data[6];
                end
	
	4'b0100 : //32-39///
				
			   begin              
            data_register[0] <= data_register[0] ^ i_crc_in_data[2] ^ i_crc_in_data[3] ^ i_crc_in_data[7];
			data_register[1] <= data_register[1] ^ i_crc_in_data[0] ^ i_crc_in_data[2] ^ i_crc_in_data[4]^ i_crc_in_data[7];
			data_register[2] <= data_register[2] ^ i_crc_in_data[1] ^ i_crc_in_data[2] ^ i_crc_in_data[5]^ i_crc_in_data[7];
			data_register[3] <= data_register[3] ^ i_crc_in_data[2] ^ i_crc_in_data[3] ^ i_crc_in_data[6];
			data_register[4] <= data_register[4] ^ i_crc_in_data[3] ^ i_crc_in_data[4] ^ i_crc_in_data[7];
			data_register[5] <= data_register[5] ^ i_crc_in_data[0] ^ i_crc_in_data[4] ^ i_crc_in_data[5];
			data_register[6] <= data_register[6] ^ i_crc_in_data[0] ^ i_crc_in_data[1] ^ i_crc_in_data[5] ^ i_crc_in_data[6];
			data_register[7] <= data_register[7] ^ i_crc_in_data[1] ^ i_crc_in_data[2] ^ i_crc_in_data[6]^ i_crc_in_data[7];
                end
				
    4'b0101 :  //40-47//
				
			   begin              
            data_register[0] <= data_register[0] ^ i_crc_in_data[0] ^ i_crc_in_data[3] ^ i_crc_in_data[5];
			data_register[1] <= data_register[1] ^ i_crc_in_data[1] ^ i_crc_in_data[3] ^ i_crc_in_data[4]^ i_crc_in_data[5]^ i_crc_in_data[6];
			data_register[2] <= data_register[2] ^ i_crc_in_data[2] ^ i_crc_in_data[3] ^ i_crc_in_data[4]^ i_crc_in_data[6] ^ i_crc_in_data[7];
			data_register[3] <= data_register[3] ^ i_crc_in_data[0] ^ i_crc_in_data[3] ^ i_crc_in_data[4]^ i_crc_in_data[5] ^ i_crc_in_data[7];
			data_register[4] <= data_register[4] ^ i_crc_in_data[1] ^ i_crc_in_data[4] ^ i_crc_in_data[5]^ i_crc_in_data[6];
			data_register[5] <= data_register[5] ^ i_crc_in_data[0] ^ i_crc_in_data[2] ^ i_crc_in_data[5]^ i_crc_in_data[6] ^ i_crc_in_data[7];
			data_register[6] <= data_register[6] ^ i_crc_in_data[1] ^ i_crc_in_data[3] ^ i_crc_in_data[6]^ i_crc_in_data[7];
			data_register[7] <= data_register[7] ^ i_crc_in_data[2] ^ i_crc_in_data[4] ^ i_crc_in_data[7];
                end

	
	
	4'b0110 : //48-55//
				 
			   begin              
            data_register[0] <= data_register[0] ^ i_crc_in_data[0] ^ i_crc_in_data[1] ^ i_crc_in_data[2]^ i_crc_in_data[4] ^ i_crc_in_data[5]^ i_crc_in_data[6];
			data_register[1] <= data_register[1] ^ i_crc_in_data[0] ^ i_crc_in_data[3] ^ i_crc_in_data[4]^ i_crc_in_data[7];
			data_register[2] <= data_register[2] ^ i_crc_in_data[0] ^ i_crc_in_data[2] ^ i_crc_in_data[6];
			data_register[3] <= data_register[3] ^ i_crc_in_data[0] ^ i_crc_in_data[1] ^ i_crc_in_data[3]^ i_crc_in_data[7];
			data_register[4] <= data_register[4] ^ i_crc_in_data[0] ^ i_crc_in_data[1] ^ i_crc_in_data[2]^ i_crc_in_data[4];
			data_register[5] <= data_register[5] ^ i_crc_in_data[1] ^ i_crc_in_data[2] ^ i_crc_in_data[3]^ i_crc_in_data[5];
		    data_register[6] <= data_register[6] ^ i_crc_in_data[0] ^ i_crc_in_data[2] ^ i_crc_in_data[3]^ i_crc_in_data[4] ^ i_crc_in_data[6];
			data_register[7] <= data_register[7] ^ i_crc_in_data[0] ^ i_crc_in_data[1] ^ i_crc_in_data[3]^ i_crc_in_data[4]^ i_crc_in_data[5]^ i_crc_in_data[7];
                end
				
				
	4'b0111 : //56-63//
				
			   begin              
            data_register[0] <= data_register[0] ^ i_crc_in_data[0] ^ i_crc_in_data[4] ^ i_crc_in_data[7];
			data_register[1] <= data_register[1] ^ i_crc_in_data[0] ^ i_crc_in_data[1] ^ i_crc_in_data[4]^ i_crc_in_data[5]^ i_crc_in_data[7];
			data_register[2] <= data_register[2] ^ i_crc_in_data[1] ^ i_crc_in_data[2] ^ i_crc_in_data[4]^ i_crc_in_data[5] ^ i_crc_in_data[6] ^ i_crc_in_data[7];
			data_register[3] <= data_register[3] ^ i_crc_in_data[2] ^ i_crc_in_data[3] ^ i_crc_in_data[5]^ i_crc_in_data[6] ^ i_crc_in_data[7];
			data_register[4] <= data_register[4] ^ i_crc_in_data[0] ^ i_crc_in_data[3] ^ i_crc_in_data[4]^ i_crc_in_data[6] ^ i_crc_in_data[7];
			data_register[5] <= data_register[5] ^ i_crc_in_data[1] ^ i_crc_in_data[4] ^ i_crc_in_data[5]^ i_crc_in_data[7];
			data_register[6] <= data_register[6] ^ i_crc_in_data[2] ^ i_crc_in_data[5] ^ i_crc_in_data[6];
			data_register[7] <= data_register[7] ^ i_crc_in_data[3] ^ i_crc_in_data[6] ^ i_crc_in_data[7];
                end
				
				
	4'b1000 :  begin              
           
			counter <= 4'b0 ; 
                end
		endcase
		
		  end
		
  end
  

assign o_crc_code = (counter == 4'b1000)? data_register : 8'b0000; 


endmodule  
		
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////


module crc_topt
    # (parameter N = 16)  // parameter indicate the device size (X4, X8, X16)
(
         // input signals //
			input wire 					i_clk ,         // clock signal
  			input wire 					i_reset ,         // active low asynchronous reset
  			input wire 					i_crc_en ,      // enable signal from write data block 
  			input wire  [2*N-1: 0]			i_crc_in_data , // input data bus from write data block that required crc code 
  
          // output signals //
  			output reg  [2*N-1: 0]	    o_crc_code       // output crc bits 
  		
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

