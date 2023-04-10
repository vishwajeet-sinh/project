package test_pkg;
     `include "uvm_macros.svh"
     import uvm_pkg::*;
	 import tb_pkg::*;
	`include "../testcases/ts.base_test.sv"
	`include "../testcases/ts.write_test.sv"
	`include "../testcases/ts.read_test.sv"
	`include "../testcases/ts.write_reg_test.sv"
	`include "../testcases/ts.read_reg_test.sv"
	`include "../testcases/ts.read_after_write_test.sv"
	`include "../testcases/ts.write_after_write_test.sv"
endpackage
