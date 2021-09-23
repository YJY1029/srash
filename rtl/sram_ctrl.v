`include "defines.v"

module sram_ctrl( 
  input clk, 
  input grst, 
  
  //AHB and CPU (dunno using what protocol)
  input re, 
  input [`ADDR_WIDTH-1:0] raddr, 
  
  output rmiss, 
  output [`DATA_WIDTH-1:0] rdata, 
  
  //flash
  input [`DATA_WIDTH-1:0] wdata, 
  //input [`ADDR_WIDTH-1:0] waddr, //use AHB addr instead? 
  
  //rams, shared by all SRAMs
  input [`DATA_WIDTH-1:0] ram_rdata, 
  
  output [`SUB_NUM:0] ram_sel, 
  //output [(`DATA_WIDTH/8)-1:0] byte_sel, //to be implemented
  output [`ADDR_WIDTH-1:0] ram_raddr, //mapped according to each SRAM module
  output [`DATA_WIDTH-1:0] ram_wdata 
  ); 
  
  /*
  use re or other indicators
  raddr compared with main addr
  raddr compared with subs addr, following designed rule
  hit, output to rdata, rmiss = 0
  miss, rdata = 0, rmiss = 1, wait for flash to write and output
  */
  reg [`ADDR_WIDTH-1:0] sub_addr [`SUB_NUM-1:0]; //origins to be implemented
  
  always@(posedge re) begin //responding to read req 
  	if ((`MAIN_LOWER < raddr)&&(raddr < `MAIN_UPPER)) begin 
  		ram_sel <= `MAIN_CHOSEN; 
  		rmiss <= 0; 
  	end else if ((sub_addr[0] < raddr)&&(raddr < (sub_addr[0]+`SUB_DEPTH))) begin 
  		ram_sel <= `SUB0_CHOSEN; 
  		rmiss <= 0; 
  	end else if ((sub_addr[1] < raddr)&&(raddr < (sub_addr[1]+`SUB_DEPTH))) begin 
  		ram_sel <= `SUB1_CHOSEN; 
  		rmiss <= 0; 
  	end else if ((sub_addr[2] < raddr)&&(raddr < (sub_addr[2]+`SUB_DEPTH))) begin 
  		ram_sel <= `SUB2_CHOSEN; 
  		rmiss <= 0; 
  	end else if ((sub_addr[3] < raddr)&&(raddr < (sub_addr[3]+`SUB_DEPTH))) begin 
  		ram_sel <= `SUB3_CHOSEN; 
  		rmiss <= 0; 
  	end else begin 
  		rmiss <= 1; 
  	end 
  end 
  
  //LRU Sub-SRAMs clock 
  