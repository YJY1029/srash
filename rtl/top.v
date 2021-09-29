//////////////////////////////////////////////////////////////////////////
//This is the top module for a hierarchical flash-SRAM storage mechanism. 
//Its front module is CPU, connecting directly to a serial flash chip 
//through SPI protocol. 
//The rear module is AHB, connecting back to the CPU. 
//////////////////////////////////////////////////////////////////////////

`include "defines.v"

module top(
  input grst, 
  
  input cpu_flash_cs, 
  input cpu_flash_sck, 
  input cpu_flash_si, 
  
  //AHB outputs to be added
  );

  flash flash(     
    .cs(cpu_flash_cs), 
    .sck(cpu_flash_sck), 
    .si(cpu_flash_si), 
    
    .so(flash_sram_so)
  ); 
  
  sram_ctrl ctrl( 
    .clk(clk), 
    .rst(grst), 
    
    .re(ahb_sram_re), 
    .raddr(ahb_sram_raddr), 
    .rmiss(sram_ahb_rmiss), 
    .rdata(sram_ahb_rdata), 
    
    .wdata(flash_sram_so), 
    
    .ram_rdata(sram_rams_rdata), 
    .ram_sel(sram_rams_sel), 
    .ram_raddr(sram_rams_raddr), 
    .ram_wdata(sram_rams_wdata) 
  ); 
  
  fake_ahb ahb( 
    .clk(clk), 
    .rst(grst), 
    
    .rdata(sram_ahb_rdata), 
    .re(ahb_srm_re), 
    .raddr(ahb_sram_raddr)//no w-related I guess
  ); 
  
  mainsram main #(`MAIN_DEPTH) ( 
    .clk(clk), 
    
    .we(sram_main_we), 
    .addr(sram_main_addr), 
    .din(sram_main_wdata), 
    
    .dout(main_sram_rdata)
  ); 
  
  genvar i; 
  generate 
  	for (i = 0; i < (`SUB_NUM-1); i++) 
  	begin: subGen
  		subSram subs #(`SUB_DEPTH) (clk, sram_sub_we[i], sram_sub_addr, sram_sub_wdata, sub_sram_rdata); 
  	end 
  endgenerate 