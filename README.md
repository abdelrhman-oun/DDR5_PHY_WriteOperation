# Design of the Digital Data-Path of DDR5 PHY 

**Description:** This project aims at designing DDR5 PHY layer supporting write operation, CRC operation and all commands related to it. After understanding the standards governing the DDR PHY Operations (DFI, JEDEC DDR), we designed the PHY and implemented it using System Verilog (SV), we used Design Compiler (DC) to synthesis the block and Formality to make a verification of RTL vs. netlist. Finally we gone through the FPGA flow till downloading the bit file on the kit.

**Supervisor:** Dr. Hesham Omran

## PHY functionality
   The main function of the PHY is passing the commands and data from MC to the DRAM and passing the data from DRAM to MC. Another function of the PHY is generating CRC code and appending it to the data, in addition to generating DQS, pre-amble, inter-amble and post-amble, it also handles the different phases of the inputs in case of frequency ratio.

Signal mapping as shown
  1.	Dfi_address -> CA [13:0]. 
  2.	Dfi_cs_n -> CS. 
  3.	Dfi_wrdata -> DQ. 
  4.	Dfi_wrdata_mask -> DM. 
  5.	Dfi_reset_n -> RESET_n. 
![alt text](https://github.com/abdelrhman-oun/DDR5_PHY_WriteOperation/blob/463e9fb9899962223ebc4ef19872e5007efd7de5/Documentation/pics/PHY.jpg)

## PHY architecture
The proposed design of the PHY consists of 5 main blocks
- FREQUENCY RATIO
- COMMAND ADDRESS
- WRITE DATA
- CRC
- REGISTER FILE

**the PHY block architecture.**
![alt text](https://github.com/abdelrhman-oun/DDR5_PHY_WriteOperation/blob/afdf16c12f79a5e9ba234fbcccdd98ad97188e61/Documentation/pics/architecture.jpg)

## PHY blocks implementation
This section describes the implementation of each of the main 4 blocks.

##### Frequency ratio block
Frequency Ratio Block will be used to convert the signals from the Memory controller interface to the PHY interface according to the dfi_freq_ratio signal.
![alt text](https://github.com/abdelrhman-oun/DDR5_PHY_WriteOperation/blob/afdf16c12f79a5e9ba234fbcccdd98ad97188e61/Documentation/pics/freq.jpg)

##### Command Address block
Command Address Block will receive the dfi_address and dfi_cs from the Frequency ratio Block then sends the dfi_address on the CA bus and the dfi_cs on CS signal.
- In case of the command is Mode Register Write Command, this block will extract the burst length, preamble, postamble and DRAM_CRC_en information from the MRW command.
- In case of the command is Write command the block will determine if the burst length will be the default or the alternative burst (saved value on mode register).
![alt text](https://github.com/abdelrhman-oun/DDR5_PHY_WriteOperation/blob/7a5d9ead0e9410db34cd1439c3533a9bdb900695/Documentation/pics/CA.jpg)

##### Write Manager block
Write Manager is responsible for transmitting the data from the frequency ratio block to the DQ bus, it is also responsible for transmitting the CRC code with the data transmitted, It should check the burst length value and according to this value it should send the data to the CRC Block.

This block is consist of three different blocks, Write FSM, Write shift and Write counters.
![alt text](https://github.com/abdelrhman-oun/DDR5_PHY_WriteOperation/blob/7a5d9ead0e9410db34cd1439c3533a9bdb900695/Documentation/pics/wm.jpg)







