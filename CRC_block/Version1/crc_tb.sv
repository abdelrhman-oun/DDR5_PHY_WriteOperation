`timescale 1us/1ns

module crc_top_module_tb  ;


 parameter N = 16;
 
                //input signals//
			logic 			i_clkt ;
  		    logic 			i_reset ;
  			logic 			i_crc_ent ;
  			logic  [2*N -1: 0]		i_crc_in_datat ;
			
			
			  //output signals//
  			logic  [2*N -1: 0]		o_crc_codet ;
  			
 
  

// parameters
 
  
// instantiate Design Unit
crc DUT (
.i_clk(i_clkt), 
.i_reset(i_reset),
.i_crc_en(i_crc_ent),
.i_crc_in_data(i_crc_in_datat),
.o_crc_code(o_crc_codet) 
);  

 
initial
  begin
  
 i_reset = 1'b0 ; 
 ///////////////////X4//////////////
 
 
 /*
 # 10

i_reset = 1'b1 ;
i_crc_ent = 1'b1 ;
 i_crc_in_datat = 8'b00010000 ;


# 10

i_reset = 1'b1 ;
i_crc_ent = 1'b1 ;
 i_crc_in_datat = 8'b00110010 ;


# 10

i_reset = 1'b1 ;
i_crc_ent = 1'b1 ;
 i_crc_in_datat = 8'b01010100 ;


# 10

i_reset = 1'b1 ;
i_crc_ent = 1'b1 ;
 i_crc_in_datat = 8'b01110110 ;


# 10

i_reset = 1'b1 ;
i_crc_ent = 1'b1 ;
 i_crc_in_datat = 8'b10011000 ;



# 10

i_reset = 1'b1 ;
i_crc_ent = 1'b1 ;
 i_crc_in_datat = 8'b11101111 ;


# 10

i_reset = 1'b1 ;
i_crc_ent = 1'b1 ;
 i_crc_in_datat = 8'b11001101 ;


# 10

i_reset = 1'b1 ;
i_crc_ent = 1'b1 ;
 i_crc_in_datat = 8'b10101011 ;
 
 
#20
    if(o_crc_codet == 8'b00010100) 
      $display("X4 with BL16 case is Passed");
    else
      $display("X4 with BL16 case  is Failed");
 
      i_reset = 1'b1 ;
i_crc_ent = 1'b0 ;
 i_crc_in_datat = 8'b10101011 ; 
 
 */


/*
 /////X4 BL8////
# 10

i_reset = 1'b1 ;
i_crc_ent = 1'b1 ;
 i_crc_in_datat = 8'b11111111 ;



# 10

i_reset = 1'b1 ;
i_crc_ent = 1'b1 ;
 i_crc_in_datat = 8'b11111111 ;


# 10

i_reset = 1'b1 ;
i_crc_ent = 1'b1 ;
 i_crc_in_datat = 8'b11111111 ;


# 10

i_reset = 1'b1 ;
i_crc_ent = 1'b1 ;
 i_crc_in_datat = 8'b11111111 ; 
 
 
 #20
    if(o_crc_codet == 8'b01100011) 
      $display("X4 with BL8 case  is Passed");
    else
      $display("X4 with BL8 case  is Failed");
	  
      i_reset = 1'b1 ;
i_crc_ent = 1'b0 ;
 i_crc_in_datat = 8'b10101011 ; 
 
 */
//////////X8//////////////////

/*
# 10

i_reset = 1'b1 ;
i_crc_ent = 1'b1 ;
 i_crc_in_datat = 16'b0011001000010000 ;


# 10

i_reset = 1'b1 ;
i_crc_ent = 1'b1 ;
 i_crc_in_datat = 16'b0111011001010100 ;


# 10

i_reset = 1'b1 ;
i_crc_ent = 1'b1 ;
 i_crc_in_datat = 16'b1110111110011000 ;


# 10

i_reset = 1'b1 ;
i_crc_ent = 1'b1 ;
 i_crc_in_datat = 16'b1100110100010000 ;


# 10

i_reset = 1'b1 ;
i_crc_ent = 1'b1 ;
 i_crc_in_datat = 16'b1010101100110010;



# 10

i_reset = 1'b1 ;
i_crc_ent = 1'b1 ;
 i_crc_in_datat = 16'b1110111101010100 ;


# 10

i_reset = 1'b1 ;
i_crc_ent = 1'b1 ;
i_crc_in_datat = 16'b1100110101110110 ;




# 10

i_reset = 1'b1 ;
i_crc_ent = 1'b1 ;
 i_crc_in_datat = 16'b1010101110011000 ;
 
 #20
    if(o_crc_codet == 16'b0001000110000010) 
      $display("X8 with BL16 case is Passed");
    else
      $display("X8 with BL16 case is Failed");
 
      i_reset = 1'b1 ;
i_crc_ent = 1'b0 ;
 i_crc_in_datat = 8'b10101011 ;
*/


//////////X16/////////////

# 10

i_reset = 1'b1 ;
i_crc_ent = 1'b1 ;
 i_crc_in_datat = 32'b00000000000000000000000000000000 ;


# 10

i_reset = 1'b1 ;
i_crc_ent = 1'b1 ;
 i_crc_in_datat = 32'b10101011101010111010101110101011 ;


# 10

i_reset = 1'b1 ;
i_crc_ent = 1'b1 ;
 i_crc_in_datat = 32'b00000000000000000000000000000000 ;


# 10

i_reset = 1'b1 ;
i_crc_ent = 1'b1 ;
 i_crc_in_datat = 32'b10101011101010111010101110101011 ;


# 10

i_reset = 1'b1 ;
i_crc_ent = 1'b1 ;
 i_crc_in_datat = 32'b00000000000000000000000000000000;



# 10

i_reset = 1'b1 ;
i_crc_ent = 1'b1 ;
 i_crc_in_datat = 32'b10101011101010111010101110101011 ;


# 10

i_reset = 1'b1 ;
i_crc_ent = 1'b1 ;
i_crc_in_datat = 32'b00000000000000000000000000000000 ;




# 10

i_reset = 1'b1 ;
i_crc_ent = 1'b1 ;
 i_crc_in_datat = 32'b10101011101010111010101110101011 ;
 
 #20
    if(o_crc_codet == 32'b01100101011001010110010101100101) 
      $display("X16 with BL16 case is Passed");
    else
      $display("X16 with BL16 case is Failed");
  
      i_reset = 1'b1 ;
i_crc_ent = 1'b0 ;









	 
   #100 $finish;  //finished with simulation 
  end
  

// Clock Generator //
  always
    begin
     i_clkt <= 1 ; #5;
     i_clkt <= 0 ; #5;
   end


endmodule



