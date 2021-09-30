///////////////////////////////////////////////////////////////////
//Controller of main SRAM and sub-SRAMs. 
//1. Initializes main SRAM. 
//2. Decides which SRAM to read or write. 
//
//TBD: 
//0. Pipeline design of the mechanism. 
//1. Detailed read and write method process. 
//1.5. Handshake instead of a single write always module? 
//2. Clock bit and clock hand bit. 
//3. grst usage. 
///////////////////////////////////////////////////////////////////

`include "defines.v"

module sram_ctrl( 
  input clk, 
  input grst, 
  
  //CPU 
  input re, 
  input [`ADDR_WIDTH] raddr, 
  
  output rmiss, 
  //outputs reads, 

  //flash 
  input [`DATA_WIDTH-1:0] wdata, 
  input [`ADDR_WIDTH-1:0] waddr//,

  //RAMs
  //inputs reads, 
  //outputs writes 
  ); 
  
  reg [`LOG_SUB_NUM-1:0] ptr_rd; 
  reg [`LOG_SUB_NUM-1:0] ptr_rd_next; 
  
  reg [`ADDR_WIDTH-1:0] sub_addr [`SUB_NUM-1:0]; 
  
  reg clock_bit [`SUB_NUM-1:0]; 
  
  //resetting all
  initial begin 
  	ptr_rd <= `SUB0_IDX; 
  	ptr_rd_next <= ptr_rd+1; 
  	
  	for (i = 0; i < 4; i = i+1) begin 
  		sub_addr[i] <= 32'h0; 
  		clock_bit[i] <= 0; 
  	end 
  	
  end 
  
  //read
  always@(posedge clk) begin 
  	
  	if (`MAIN_LOWER < raddr) && (raddr < `MAIN_UPPER) begin 
  		
  		//read from main 
  		 
  	end else begin 

  		for (i = 0; i < 4; i = i+1) begin 
  			if (sub_addr[i] < raddr) && (raddr < sub_addr[i]+`SUB_DEPTH) begin 
          clock_bit[i] <= 1; 
  				rmiss <= 0; 
  				
  				//read from sub i
  				
  			end else begin 
  				rmiss <= 1; 
  			end 
  		end 
  		
  	end 
  	
  end 
  
  //write 
  initial begin 
  	
  	//read `MAIN_LOWER to `MAIN_UPPER from Flash to main SRAM 
  	
  end 
  
  reg [`LOG_SUB_NUM-1:0] ptr_wr; 
  reg [`LOG_SUB_NUM-1:0] ptr_wr_next; 

  always@(posedge clk) begin 
  	if (`MAIN_LOWER < waddr) && (waddr < `MAIN_UPPER) begin 

      //write main at waddr 

    end else begin 
      while (clock_bit[ptr_wr] != 0) begin 
        clock_bit[ptr_wr] <= 0; 
        ptr_wr <= ptr_wr_next; 
        ptr_wr_next <= (ptr_wr ! 2'b11) ? (ptr_wr+1):2'b00; 
      end 
      
      //write to sub i
      
      sub_addr[ptr_wr] <= waddr; 
    end 
  end 

endmodule