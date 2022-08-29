/********************************************************************************
** Company: Si-Vision & FOE ASU
** Author: AHMED MOSTAFA KAMAL , ADHAM HAZEM ALGENDI AND AHMED MOHAMED AMIN
**
** Create Date: 24/3/2022
** Edited on  : 21/4/2022
** Module Name: asu_ddr5_crc_x4
** Description: this file contains the CRC RTL, the design implementation
** is based on IEEE standard (Std 802.15.4-2011)
**
**
********************************************************************************/
`timescale 1ns / 1ps


module ddr5_phy_crc_x4 (
          // input signals //
		  
		  
  			input wire 			clk_i ,         // clock signal 
  			input wire 			rst_i ,       // active low asynchronous reset
  			input wire 			crc_en_i ,      // enable signal from write data block 
  			input wire  [7: 0]		crc_in_data_i , // input data bus from write data block that required crc bits
    
	       // output signals //
  			output wire  [7: 0]	crc_code_o      // output crc bits 
  			
  
);
  

reg   [7:0]  data_register;   // internal register to store the input data to generate crc

reg	[3:0]   counter;         // counter counts number of clock cycle start to count when enable get high




always_ff @(posedge clk_i or negedge rst_i)
  begin   
	if(!rst_i)    // reseting value of the counter and initial storing zeros in data_register
	  begin
		data_register <= 8'b0  ;      
		counter <= 3'b0  ;
		
	  end
	   
	else if(crc_en_i)
	  begin
		counter <= counter + 1 ;   
		
		
		
		
		case (counter)
		
		                        //0-7//
	4'b0000 : begin
			data_register[0] <= crc_in_data_i[0] ^ crc_in_data_i[6] ^ crc_in_data_i[7];
			data_register[1] <= crc_in_data_i[0] ^ crc_in_data_i[1] ^ crc_in_data_i[6] ;
			data_register[2] <= crc_in_data_i[0] ^ crc_in_data_i[1] ^ crc_in_data_i[2] ^ crc_in_data_i[6];
		    data_register[3] <= crc_in_data_i[1] ^ crc_in_data_i[2] ^ crc_in_data_i[3] ^ crc_in_data_i[7];
			data_register[4] <= crc_in_data_i[2] ^ crc_in_data_i[3] ^ crc_in_data_i[4] ;
			data_register[5] <= crc_in_data_i[3] ^ crc_in_data_i[4] ^ crc_in_data_i[5] ;
			data_register[6] <= crc_in_data_i[4] ^ crc_in_data_i[5] ^ crc_in_data_i[6] ;
		    data_register[7] <= crc_in_data_i[5] ^ crc_in_data_i[6] ^ crc_in_data_i[7];
			end
			
			                //8-15//
	4'b0001 :  begin              
              data_register[0] <= data_register[0] ^ crc_in_data_i[4] ^ crc_in_data_i[6] ^ crc_in_data_i[0];
			  data_register[1] <= data_register[1] ^ crc_in_data_i[1] ^ crc_in_data_i[4] ^ crc_in_data_i[5]^ crc_in_data_i[6]^ crc_in_data_i[7];
			  data_register[2] <= data_register[2] ^ crc_in_data_i[0] ^ crc_in_data_i[2] ^ crc_in_data_i[4]^ crc_in_data_i[5] ^ crc_in_data_i[7];
			  data_register[3] <= data_register[3] ^ crc_in_data_i[1] ^ crc_in_data_i[3] ^ crc_in_data_i[5] ^ crc_in_data_i[6];
			  data_register[4] <= data_register[4] ^ crc_in_data_i[0] ^ crc_in_data_i[2] ^ crc_in_data_i[4]^ crc_in_data_i[6] ^ crc_in_data_i[7];
			  data_register[5] <= data_register[5] ^ crc_in_data_i[1] ^ crc_in_data_i[3] ^ crc_in_data_i[5]^ crc_in_data_i[7];
			  data_register[6] <= data_register[6] ^ crc_in_data_i[2] ^ crc_in_data_i[4] ^ crc_in_data_i[6];
			  data_register[7] <= data_register[7] ^ crc_in_data_i[3] ^ crc_in_data_i[5] ^ crc_in_data_i[7];
                end
		
		                    //16-23//
	4'b0010 : begin              
              data_register[0] <= data_register[0] ^ crc_in_data_i[0] ^ crc_in_data_i[2] ^ crc_in_data_i[3] ^ crc_in_data_i[5] ^ crc_in_data_i[7];
			  data_register[1] <= data_register[1] ^ crc_in_data_i[0] ^ crc_in_data_i[1] ^ crc_in_data_i[2]^ crc_in_data_i[4] ^ crc_in_data_i[5] ^ crc_in_data_i[6]^ crc_in_data_i[7];
			  data_register[2] <= data_register[2] ^ crc_in_data_i[1] ^ crc_in_data_i[6] ;
		      data_register[3] <= data_register[3] ^ crc_in_data_i[0]^ crc_in_data_i[2] ^ crc_in_data_i[7] ;
		      data_register[4] <= data_register[4] ^ crc_in_data_i[1] ^ crc_in_data_i[3] ;
			  data_register[5] <= data_register[5] ^ crc_in_data_i[0] ^ crc_in_data_i[2] ^ crc_in_data_i[4];
	    	  data_register[6] <= data_register[6] ^ crc_in_data_i[0] ^ crc_in_data_i[1] ^ crc_in_data_i[3]^ crc_in_data_i[5];
			  data_register[7] <= data_register[7] ^ crc_in_data_i[1] ^ crc_in_data_i[2] ^ crc_in_data_i[4]^ crc_in_data_i[6];
                end
				
				         //24-31//
	4'b0011 : begin              
            data_register[0] <= data_register[0] ^ crc_in_data_i[4] ^ crc_in_data_i[6] ^ crc_in_data_i[7];
			data_register[1] <= data_register[1] ^ crc_in_data_i[0] ^ crc_in_data_i[4] ^ crc_in_data_i[5]^ crc_in_data_i[6];
			data_register[2] <= data_register[2] ^ crc_in_data_i[0] ^ crc_in_data_i[1] ^ crc_in_data_i[4]^ crc_in_data_i[5];
			data_register[3] <= data_register[3] ^ crc_in_data_i[1] ^ crc_in_data_i[2] ^ crc_in_data_i[5]^ crc_in_data_i[6];
			data_register[4] <= data_register[4] ^ crc_in_data_i[0] ^ crc_in_data_i[2] ^ crc_in_data_i[3]^ crc_in_data_i[6] ^ crc_in_data_i[7];
		    data_register[5] <= data_register[5] ^ crc_in_data_i[1] ^ crc_in_data_i[3] ^ crc_in_data_i[4]^ crc_in_data_i[7];
			data_register[6] <= data_register[6] ^ crc_in_data_i[2] ^ crc_in_data_i[4] ^ crc_in_data_i[5];
			data_register[7] <= data_register[7] ^ crc_in_data_i[3] ^ crc_in_data_i[5] ^ crc_in_data_i[6];
                end
	
	4'b0100 : //32-39///
				
			   begin              
            data_register[0] <= data_register[0] ^ crc_in_data_i[2] ^ crc_in_data_i[3] ^ crc_in_data_i[7];
			data_register[1] <= data_register[1] ^ crc_in_data_i[0] ^ crc_in_data_i[2] ^ crc_in_data_i[4]^ crc_in_data_i[7];
			data_register[2] <= data_register[2] ^ crc_in_data_i[1] ^ crc_in_data_i[2] ^ crc_in_data_i[5]^ crc_in_data_i[7];
			data_register[3] <= data_register[3] ^ crc_in_data_i[2] ^ crc_in_data_i[3] ^ crc_in_data_i[6];
			data_register[4] <= data_register[4] ^ crc_in_data_i[3] ^ crc_in_data_i[4] ^ crc_in_data_i[7];
			data_register[5] <= data_register[5] ^ crc_in_data_i[0] ^ crc_in_data_i[4] ^ crc_in_data_i[5];
			data_register[6] <= data_register[6] ^ crc_in_data_i[0] ^ crc_in_data_i[1] ^ crc_in_data_i[5] ^ crc_in_data_i[6];
			data_register[7] <= data_register[7] ^ crc_in_data_i[1] ^ crc_in_data_i[2] ^ crc_in_data_i[6]^ crc_in_data_i[7];
                end
				
    4'b0101 :  //40-47//
				
			   begin              
            data_register[0] <= data_register[0] ^ crc_in_data_i[0] ^ crc_in_data_i[3] ^ crc_in_data_i[5];
			data_register[1] <= data_register[1] ^ crc_in_data_i[1] ^ crc_in_data_i[3] ^ crc_in_data_i[4]^ crc_in_data_i[5]^ crc_in_data_i[6];
			data_register[2] <= data_register[2] ^ crc_in_data_i[2] ^ crc_in_data_i[3] ^ crc_in_data_i[4]^ crc_in_data_i[6] ^ crc_in_data_i[7];
			data_register[3] <= data_register[3] ^ crc_in_data_i[0] ^ crc_in_data_i[3] ^ crc_in_data_i[4]^ crc_in_data_i[5] ^ crc_in_data_i[7];
			data_register[4] <= data_register[4] ^ crc_in_data_i[1] ^ crc_in_data_i[4] ^ crc_in_data_i[5]^ crc_in_data_i[6];
			data_register[5] <= data_register[5] ^ crc_in_data_i[0] ^ crc_in_data_i[2] ^ crc_in_data_i[5]^ crc_in_data_i[6] ^ crc_in_data_i[7];
			data_register[6] <= data_register[6] ^ crc_in_data_i[1] ^ crc_in_data_i[3] ^ crc_in_data_i[6]^ crc_in_data_i[7];
			data_register[7] <= data_register[7] ^ crc_in_data_i[2] ^ crc_in_data_i[4] ^ crc_in_data_i[7];
                end

	
	
	4'b0110 : //48-55//
				 
			   begin              
            data_register[0] <= data_register[0] ^ crc_in_data_i[0] ^ crc_in_data_i[1] ^ crc_in_data_i[2]^ crc_in_data_i[4] ^ crc_in_data_i[5]^ crc_in_data_i[6];
			data_register[1] <= data_register[1] ^ crc_in_data_i[0] ^ crc_in_data_i[3] ^ crc_in_data_i[4]^ crc_in_data_i[7];
			data_register[2] <= data_register[2] ^ crc_in_data_i[0] ^ crc_in_data_i[2] ^ crc_in_data_i[6];
			data_register[3] <= data_register[3] ^ crc_in_data_i[0] ^ crc_in_data_i[1] ^ crc_in_data_i[3]^ crc_in_data_i[7];
			data_register[4] <= data_register[4] ^ crc_in_data_i[0] ^ crc_in_data_i[1] ^ crc_in_data_i[2]^ crc_in_data_i[4];
			data_register[5] <= data_register[5] ^ crc_in_data_i[1] ^ crc_in_data_i[2] ^ crc_in_data_i[3]^ crc_in_data_i[5];
		    data_register[6] <= data_register[6] ^ crc_in_data_i[0] ^ crc_in_data_i[2] ^ crc_in_data_i[3]^ crc_in_data_i[4] ^ crc_in_data_i[6];
			data_register[7] <= data_register[7] ^ crc_in_data_i[0] ^ crc_in_data_i[1] ^ crc_in_data_i[3]^ crc_in_data_i[4]^ crc_in_data_i[5]^ crc_in_data_i[7];
                end
				
				
	4'b0111 : //56-63//
				
			   begin              
            data_register[0] <= data_register[0] ^ crc_in_data_i[0] ^ crc_in_data_i[4] ^ crc_in_data_i[7];
			data_register[1] <= data_register[1] ^ crc_in_data_i[0] ^ crc_in_data_i[1] ^ crc_in_data_i[4]^ crc_in_data_i[5]^ crc_in_data_i[7];
			data_register[2] <= data_register[2] ^ crc_in_data_i[1] ^ crc_in_data_i[2] ^ crc_in_data_i[4]^ crc_in_data_i[5] ^ crc_in_data_i[6] ^ crc_in_data_i[7];
			data_register[3] <= data_register[3] ^ crc_in_data_i[2] ^ crc_in_data_i[3] ^ crc_in_data_i[5]^ crc_in_data_i[6] ^ crc_in_data_i[7];
			data_register[4] <= data_register[4] ^ crc_in_data_i[0] ^ crc_in_data_i[3] ^ crc_in_data_i[4]^ crc_in_data_i[6] ^ crc_in_data_i[7];
			data_register[5] <= data_register[5] ^ crc_in_data_i[1] ^ crc_in_data_i[4] ^ crc_in_data_i[5]^ crc_in_data_i[7];
			data_register[6] <= data_register[6] ^ crc_in_data_i[2] ^ crc_in_data_i[5] ^ crc_in_data_i[6];
			data_register[7] <= data_register[7] ^ crc_in_data_i[3] ^ crc_in_data_i[6] ^ crc_in_data_i[7];
                end
				
				
	4'b1000 :  begin              
           
			counter <= 4'b0 ; 
                end
		endcase
		
	
		  end
		
		
			
			
		  

  end
  

assign crc_code_o = (counter == 4'b1000)? data_register : 8'b0000; 


endmodule  
