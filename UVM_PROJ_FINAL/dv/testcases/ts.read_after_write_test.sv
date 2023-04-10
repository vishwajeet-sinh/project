`ifndef READ_AFTER_WRITE_TEST
`define READ_AFTER_WRITE_TEST
class read_after_write_test extends base_test;

  //------------------------------------------------------------
  // factory registration
  //------------------------------------------------------------

  `uvm_component_utils(read_after_write_test)
   
  //------------------------------------------------------------
  // Data Members
  //------------------------------------------------------------
  
  I2C_sl_sm_7_rx_seq i2c_rx_seq;
  I2C_sl_sm_7_tx_seq i2c_tx_seq;
  UART_read_after_write_seq uart_seq;

  //------------------------------------------------------------
  // default constructor
  //------------------------------------------------------------

  function new(string name = "read_after_write_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new 

  //------------------------------------------------------------
  // build phase for test
  //------------------------------------------------------------

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    i2c_rx_seq =  I2C_sl_sm_7_rx_seq::type_id::create("i2c_rx_seq");
    i2c_tx_seq =  I2C_sl_sm_7_tx_seq::type_id::create("i2c_tx_seq");
	uart_seq = UART_read_after_write_seq::type_id::create("uart_seq");
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
	fork
	uart_seq.start(env_h.uart_sl_agt_h.uart_sequencer_h);
    uvm_config_db #(int)::set(null,"*","byte_count",2);
	begin
      i2c_rx_seq.start(env_h.sl_agent_h.i2c_sequencer_h);
      i2c_tx_seq.start(env_h.sl_agent_h.i2c_sequencer_h);
	end
	join
	phase.drop_objection(this);

  endtask : run_phase

endclass : read_after_write_test
`endif


