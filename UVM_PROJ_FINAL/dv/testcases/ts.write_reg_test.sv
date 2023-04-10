`ifndef WRITE_REG_TEST
`define WRITE_REG_TEST
class write_reg_test extends base_test;

  //------------------------------------------------------------
  // factory registration
  //------------------------------------------------------------

  `uvm_component_utils(write_reg_test)
   
  //------------------------------------------------------------
  // Data Members
  //------------------------------------------------------------
  
  I2C_sl_sm_7_rx_seq i2c_seq;
  UART_write_reg_seq uart_seq;
  UART_write_seq uart_wr_seq;

  //------------------------------------------------------------
  // default constructor
  //------------------------------------------------------------

  function new(string name = "write_reg_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new 

  //------------------------------------------------------------
  // build phase for test
  //------------------------------------------------------------

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    i2c_seq =  I2C_sl_sm_7_rx_seq::type_id::create("i2c_seq");
	uart_seq = UART_write_reg_seq::type_id::create("uart_seq");
	uart_wr_seq = UART_write_seq::type_id::create("uart_wr_seq");
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
    real freq = 7.3728e6;
    phase.raise_objection(this);
    uvm_config_db #(int)::set(null,"*","byte_count",2);

	uart_seq.start(env_h.uart_sl_agt_h.uart_sequencer_h);
    uart_agt_h.baud_rate = freq/(16+{8'hff, 8'h02});
    env_cfg_h.baud_rate = uart_agt_h.baud_rate;
    `uvm_info(get_type_name(),$sformatf("baud_rate=%0f",env_cfg_h.baud_rate),UVM_LOW)
    uvm_config_db #(UART_agent_config)::set(null,"","UART_agent_config",uart_agt_h);
    uvm_config_db #(env_config)::set(null,"*","env_config",env_cfg_h);
	fork
      uart_wr_seq.start(env_h.uart_sl_agt_h.uart_sequencer_h);
      i2c_seq.start(env_h.sl_agent_h.i2c_sequencer_h);
	join

	phase.drop_objection(this);

  endtask : run_phase

endclass : write_reg_test
`endif


