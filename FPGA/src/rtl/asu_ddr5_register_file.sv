/***************************************************************************
** File Name   : asu_ddr5_register_file.sv
** Author      : Abdelrahman Oun , Muhammad El-melegy 
** Created on  : Mar 15, 2022
** Edited on   : Apr 21, 2022
** description : REGISTER FILE block that is used to store the programmable
				 parameters like phy_CRC_mode and dfi_freq_ratio
****************************************************************************/

module asu_ddr5_register_file #(
parameter pDATA_WIDTH	= 4,
parameter pADDR_WIDTH	= 1,
parameter reg pCRC_MODE = 1'b1,
parameter reg [1:0] pFREQ_RATIO  = 2'b00
)(

input wire clk_i,
input wire rst_i,
input wire enable_i,


output wire phy_CRC_mode_o,
output wire [1:0] dfi_freq_ratio_o 

);

localparam int NUM_WORDS  = 2**pADDR_WIDTH;

reg [NUM_WORDS-1:0][pDATA_WIDTH-1:0] register;


always_ff  @ (posedge clk_i or negedge rst_i) begin

	if (!rst_i) begin
		for (int i = 0 ; i <  NUM_WORDS ; i++) begin
			register[i] <= {pDATA_WIDTH{1'b0}};
		end
	end
	else if (enable_i) begin
		
		register[0] <= {{(pDATA_WIDTH-1){1'b0}},{pCRC_MODE}};
		register[1] <= {{(pDATA_WIDTH-2){1'b0}},{pFREQ_RATIO}};
	end
end

assign phy_CRC_mode_o = register[0][0];
assign dfi_freq_ratio_o = register[1][1:0];

endmodule