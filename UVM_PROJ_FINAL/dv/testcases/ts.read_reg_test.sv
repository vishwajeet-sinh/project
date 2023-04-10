`ifndef READ_REG_TEST
`define READ_REG_TEST
class read_reg_test extends base_test;

  //------------------------------------------------------------
  // factory registration
  //------------------------------------------------------------

  `uvm_component_utils(read_reg_test)
   
  //------------------------------------------------------------
  // Data Members
  //------------------------------------------------------------
  
  UART_write_reg_seq uart_wr_seq;
  UART_read_reg_seq uart_rd_seq;

  //------------------------------------------------------------
  // default constructor
  //------------------------------------------------------------

  function new(string name = "read_reg_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new 

  //------------------------------------------------------------
  // build phase for test
  //------------------------------------------------------------

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

	uart_wr_seq = UART_write_reg_seq::type_id::create("uart_wr_seq");
	uart_rd_seq = UART_read_reg_seq::type_id::create("uart_rd_seq");
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
	phase.phase_done.set_drain_time(this,100000ps);

	uart_wr_seq.start(env_h.uart_sl_agt_h.uart_sequencer_h);
    uart_agt_h.baud_rate = freq/(16+{8'hff, 8'h02});
    env_cfg_h.baud_rate = uart_agt_h.baud_rate;
    `uvm_info(get_type_name(),$sformatf("baud_rate=%0f",env_cfg_h.baud_rate),UVM_LOW)
    uvm_config_db #(UART_agent_config)::set(null,"","UART_agent_config",uart_agt_h);
    uvm_config_db #(env_config)::set(null,"*","env_config",env_cfg_h);
    uart_rd_seq.start(env_h.uart_sl_agt_h.uart_sequencer_h);

	phase.drop_objection(this);

  endtask : run_phase

endclass : read_reg_test
`endif



