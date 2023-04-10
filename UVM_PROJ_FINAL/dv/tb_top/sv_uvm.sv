#!/usr/bin/csh

source /apps/design_environment.csh
setenv UVM_HOME /home/016720418@SJSUAD.SJSU.EDU/uvm-1.2
vcs -sverilog -timescale=1us/1ns +vpi +define+UVM_OBJECT_MUST_HAVE_CONSTRUCTOR +incdir+${UVM_HOME}/src ${UVM_HOME}/src/uvm.sv ${UVM_HOME}/src/dpi/uvm_dpi.cc -CFLAGS -DVCS $argv[1] 
if ($status != 0) exit $status
./simv +UVM_TESTNAME=$argv[2]  +UVM_VERBOSITY=UVM_HIGH

