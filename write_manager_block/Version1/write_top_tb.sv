`timescale 1ns/1ns

module write_data_top_module_tb  ;
			

			 logic 							i_clkt ;
  			 logic 							i_rstt ;
			 logic 							i_enablet ;
			
  			
  			 logic  [7: 0]			i_crc_in_data ;
  
  			 logic  [7: 0]			o_crc_data ;
  			 logic  					o_crc_en;  
			  logic 						i_wr_ent;
			  logic     					i_phy_crc_modet ;
			  logic     					i_DRAM_crc_ent ;
			 
			  logic      [2:0]              i_precyclet;
			  logic      [1:0]              i_postcyclet;
			 
			  logic  	[7: 0]				i_Wr_datat ;
			  logic  						i_Wr_datamaskt;
			 
			  logic  [7: 0]					i_pre_patternt ;
			  logic  [3:0]      			 i_post_patternt ;
			 
			 logic [1:0]                   i_burstlength;
			  logic [7:0] 					o_DQt ;
			  logic  						o_DQ_validt ;
			  logic        					o_DMt ;
			 
			  logic [1:0]					o_DQSt ;
			  logic     			   		 o_DQS_validt ; 
 
  

// parameters
 
  
// instantiate Design Unit
write_manager DUT (
.i_clk(i_clkt), 
.i_rst(i_rstt),
.i_enable(i_enablet),

.i_wr_en(i_wr_ent), 
.i_phy_crc_mode(i_phy_crc_modet),
.i_DRAM_crc_en(i_DRAM_crc_ent),

.i_precycle(i_precyclet), 
.i_postcycle(i_postcyclet),
.i_crc_code(i_crc_in_data),

.i_Wr_data(i_Wr_datat),
.i_Wr_datamask(i_Wr_datamaskt), 
. i_burstlength ( i_burstlength ),

.i_pre_pattern(i_pre_patternt),
.i_post_pattern(i_post_patternt),

.o_DQ(o_DQt),
.o_DQ_valid(o_DQ_validt),
.o_crc_data(o_crc_data),
.o_crc_enable (o_crc_en) , 
.o_DM(o_DMt),
.o_DQS(o_DQSt),
.o_DQS_valid(o_DQS_validt)


);  

 
initial
  begin



 i_rstt = 1'b0 ; 
# 10 // 1- reset cycle




i_rstt = 1'b1  ;
i_enablet = 1'b1 ;
i_wr_ent =1'b0 ;
i_phy_crc_modet = 1'b1 ;
i_DRAM_crc_ent = 1'b1;
i_burstlength = 2'b00;		 
i_precyclet = 3'b100;
i_postcyclet = 2'b10;
			 
i_Wr_datat = 8'b00000000;
i_Wr_datamaskt = 8'b0 ;
			 
i_pre_patternt = 8'b00001010;
i_post_patternt = 4'b0000; 
# 10 // 2- enable cycle



i_rstt = 1'b1  ;
i_enablet = 1'b1 ;
i_wr_ent =1'b1 ;


			 
i_Wr_datat = 8'b00000000;
i_Wr_datamaskt = 8'b0 ;
			 

# 80  // 3,4,5,6,7- write enable five cycle


i_rstt = 1'b1  ;
i_enablet = 1'b1 ;
i_wr_ent =1'b0 ;

			 
i_Wr_datat = 8'b10101010;
i_Wr_datamaskt = 8'b11000000 ;

#50		 




i_rstt = 1'b1  ;
i_enablet = 1'b1 ;
i_wr_ent =1'b1 ;


			 
i_Wr_datat = 8'b10101010;
i_Wr_datamaskt = 8'b0 ;
			 


# 80  //9- data2



i_rstt = 1'b1  ;
i_enablet = 1'b1 ;
i_wr_ent =1'b0 ;


			 
i_Wr_datat = 8'b00001100;
i_Wr_datamaskt = 8'b0 ;
			 

#10  // 10- data3



i_rstt = 1'b1  ;
i_enablet = 1'b1 ;
i_wr_ent = 1'b0 ;

i_Wr_datat = 8'b00000000;
i_Wr_datamaskt = 8'b0 ;
			 

# 20       // gap

i_rstt = 1'b1  ;
i_enablet = 1'b1 ;
i_wr_ent = 1'b0 ;


			 
i_Wr_datat = 8'b00000011;
i_Wr_datamaskt = 8'b0 ;
			 

#10 // 14,15 - data state  and write enable is high


i_rstt = 1'b1  ;
i_enablet = 1'b1 ;
i_wr_ent = 1'b0 ;
			 
i_Wr_datat = 8'b00001111;
i_Wr_datamaskt = 8'b0 ;
			 


#30 
i_wr_ent = 1'b0 ;

	 
   #200 $finish;  //finished with simulation 
  end
  

// Clock Generator with 100 KHz (10 us)
  always
    begin
     i_clkt <= 1 ; #5;
     i_clkt <= 0 ; #5;
   end


endmodule


















