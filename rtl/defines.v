`define DATA_WIDTH 32 
`define ADDR_WIDTH 2097152 //is it this big? 2MiB

//`define MAIN_LOWER 
`define MAIN_LOWER 32'h0 
`define MAIN_UPPER `MAINLOWER+`ADDR_WIDTH
`define MAIN_DEPTH 131072 //128*1024
`define SUB_NUM 4 
`define LOG_SUB_NUM 2
`define SUB_DEPTH 512 

//SRAM control macros
`define MAIN_CHOSEN 4'b0000
`define SUB0_CHOSEN 4'b0001
`define SUB1_CHOSEN 4'b0010
`define SUB2_CHOSEN 4'b0100
`define SUB3_CHOSEN 4'b1000
/*
`define SUB0_IDX 2'b00 
`define SUB1_IDX 2'b01 
`define SUB2_IDX 2'b10 
`define SUB3_IDX 2'b11 
*/