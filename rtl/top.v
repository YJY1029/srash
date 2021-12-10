///////////////////////////////////////////////////////////////////
//This is the top module for a hierarchical flash-SRAM storage 
//mechanism. 
//Its front module is CPU, connecting directly to a serial 
//flash chip through SPI protocol. 
//The rear module is AHB, connecting back to the CPU. 
///////////////////////////////////////////////////////////////////

`include "defines.v"

module top(
  input grst, 
  
  input cpu_flash_cs, 
  input cpu_flash_sck, 
  input cpu_flash_si, 
  
  //AHB outputs to be added
  output rmiss
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
  
  fake_ahb cmsdk_ahb_to_flash32 #(
    // Parameters
    parameter AW       = 16,// Address width
    parameter WS       = 1) // Flash access wait state (0 to 3)
    (
      input  wire          HCLK,    // Clockinput  wire          HRESETn, // Reset
      input  wire          HSEL,    // Device select
      input  wire [AW-1:0] HADDR,   // Address
      input  wire    [1:0] HTRANS,  // Transfer control
      input  wire    [2:0] HSIZE,   // Transfer size
      input  wire    [3:0] HPROT,   // Protection
      input  wire          HWRITE,  // Write control
      input  wire   [31:0] HWDATA,  // Write data - not used
      input  wire          HREADY,  // Transfer phase done
      output wire          HREADYOUT, // Device ready
      output wire   [31:0] HRDATA,  // Read data output
      output wire          HRESP,   // Device response (always OKAY)
      output wire [AW-3:0] FLASHADDR, // Flash address
      input  wire   [31:0] FLASHRDATA  // Flash read data
);
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