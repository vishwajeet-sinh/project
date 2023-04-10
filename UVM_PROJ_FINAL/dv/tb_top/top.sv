//====================================================================================
//                                                                                   
//  Title         : Top Module                                                
//  Description   : This is the top module for UART to I2C bridge.
//                                                                                      
//====================================================================================

`ifndef TB__TOP
`define TB__TOP

`timescale 10ps/1ps

//include design files here
`include "../../rtl/TB.sv"
`include "../testbench/defines/env_defines.sv"
`include "../testbench/package/tb_pkg.sv"
`include "../testcases/test_pkg.sv"
`include "uvm_macros.svh"
import uvm_pkg::*;
import env_defines::*;
import tb_pkg::*;
import test_pkg::*;
`include "../testbench/interface/I2C_intf.sv" 
`include "../testbench/interface/UART_intf.sv"
`include "../testbench/bfm/I2C_bfm.sv"
`include "../testbench/bfm/I2C_mon_bfm.sv"

module top;
  timeunit 1us;
  timeprecision 1ns;
  bit clk;
  logic reset_n;
  logic rst;
  wand scl,sda;
  reg i2c_sda_o;
  wire rx,tx;
  always
  #5ns clk=~clk;
  
  pullup (strong1) p1 (scl);
  pullup (strong1) p2 (sda);

 assign i2c_sda = vif.sda ? 1'bZ : 1'b0;
 assign rst = ~reset_n;
  I2C_intf vif (.clk(clk),
                .scl(scl),
		.sda(sda));

  uart_if intf(.reset(reset_n));

  I2C_sl_dri_bfm sl(.scl(vif.scl),
		    .sda(vif.sda));
  
  top_tb top_design(.clk(clk),.rst(rst),.rx(intf.tx),.rx_enable(intf.rx_enable),.tx(intf.rx),.i2c_sda(sda),.i2c_scl(scl));
  
  I2C_mon_bfm mon(.clk(vif.clk),
                 .scl(vif.scl),
	             .sda(vif.sda));


  initial begin
    uvm_config_db #(virtual I2C_sl_dri_bfm)::set(null,"*","sl_bfm",sl);
    
    uvm_config_db #(virtual I2C_mon_bfm)::set(null,"*","mon_bfm",mon);

	  uvm_config_db #(virtual uart_if)::set(null,"*","vif_0",intf);

    run_test("base_test");
  end

  initial begin
    $dumpfile("top.vcd");
    $dumpvars();
  end
  
 initial begin
   reset_n = 1;
   #2ns reset_n = ~reset_n;
 end

endmodule : top

`endif
