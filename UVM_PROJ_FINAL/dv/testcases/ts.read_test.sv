`ifndef READ_TEST
`define READ_TEST
class read_test extends base_test;

  //------------------------------------------------------------
  // factory registration
  //------------------------------------------------------------

  `uvm_component_utils(read_test)
   
  //------------------------------------------------------------
  // Data Members
  //------------------------------------------------------------
  
  I2C_sl_sm_7_tx_seq i2c_seq;
  UART_read_seq uart_seq;

  //------------------------------------------------------------
  // default constructor
  //------------------------------------------------------------

  function new(string name = "read_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new 

  //------------------------------------------------------------
  // build phase for test
  //------------------------------------------------------------

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    i2c_seq =  I2C_sl_sm_7_tx_seq::type_id::create("i2c_seq");
	uart_seq = UART_read_seq::type_id::create("uart_seq");
  endfunction : build_phase

  //------------------------------------------------------------
  // Connect Phase for test
  //------------------------------------------------------------

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

  endfunction : connect_phase

  //------------------------------------------------------------
  // run phase for test
  //------------------------------------------------------------
 
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
	phase.phase_done.set_drain_time(this,100000ps);
    uvm_config_db #(int)::set(null,"*","byte_count",2);
	fork
	uart_seq.start(env_h.uart_sl_agt_h.uart_sequencer_h);
    i2c_seq.start(env_h.sl_agent_h.i2c_sequencer_h);
	join
	phase.drop_objection(this);

  endtask : run_phase

endclass : read_test
`endif


