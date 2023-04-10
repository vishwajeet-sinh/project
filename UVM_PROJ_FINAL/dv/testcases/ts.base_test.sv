`ifndef TEST
`define TEST
class base_test extends uvm_test;

  //------------------------------------------------------------
  // factory registration
  //------------------------------------------------------------

  `uvm_component_utils(base_test)
   
  //------------------------------------------------------------
  // Data Members
  //------------------------------------------------------------
  
  //handle declaration for environment
  env env_h;
  scb scb_h;
  env_config env_cfg_h;
  I2C_agent_config i2c_agt_h;
  UART_agent_config uart_agt_h;

  //------------------------------------------------------------
  // default constructor
  //------------------------------------------------------------

  function new(string name = "base_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new 

  //------------------------------------------------------------
  // build phase for test
  //------------------------------------------------------------

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    env_h = env::type_id::create("env_h",this);
    env_cfg_h = env_config::type_id::create("env_cfg_h");

    scb_h = scb::type_id::create("scb_h",this);
    
    i2c_agt_h = I2C_agent_config::type_id::create("i2c_agt_h");
    uart_agt_h = UART_agent_config::type_id::create("uart_agt_h");

   env_cfg_h.slave_address =  'h41;

    uart_agt_h.baud_rate= env_cfg_h.baud_rate;
    i2c_agt_h.slave_address= env_cfg_h.slave_address;
    uvm_config_db #(I2C_agent_config)::set(null,"","I2C_config",i2c_agt_h);
    uvm_config_db #(UART_agent_config)::set(null,"","UART_agent_config",uart_agt_h);
    uvm_config_db #(env_config)::set(null,"*","env_config",env_cfg_h);

  endfunction : build_phase

  //------------------------------------------------------------
  // Connect Phase for test
  //------------------------------------------------------------

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

     env_h.sl_agent_h.I2C_mon_h.mon_aport.connect(scb_h.I2C_mon_in); 
     env_h.uart_sl_agt_h.uart_mon_h.tx_monitor_port.connect(scb_h.UART_tx_in);                
     env_h.uart_sl_agt_h.uart_mon_h.rx_monitor_port.connect(scb_h.UART_rx_in);                

  endfunction : connect_phase

  //------------------------------------------------------------
  // run phase for test
  //------------------------------------------------------------
 
  task run_phase(uvm_phase phase);
    //empty for now
    phase.raise_objection(this);
    `uvm_info(get_type_name(),$sformatf("%0t:base_test waiting started",$realtime),UVM_LOW);
	#2ns;
    `uvm_info(get_type_name(),$sformatf("%0t:base_test waiting ended",$realtime),UVM_LOW);
	phase.drop_objection(this);

  endtask : run_phase

endclass : base_test
`endif
