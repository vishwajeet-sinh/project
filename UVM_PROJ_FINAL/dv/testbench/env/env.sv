//====================================================================================
//                                                                                   
//  Title         : Environment Class                                                 
//  Description   : This file contains definition of Environment Class of UART-to-I2C bridge.This
//                  classs instantiates UART Agent and I2C Agent component.
//                                                                                      
//====================================================================================

`ifndef ENV
`define ENV

class env extends uvm_env;

  //-------------------------------------------------------
  // Factory Registration
  //-------------------------------------------------------

  `uvm_component_utils(env)

  //-------------------------------------------------------
  // Data Members
  //-------------------------------------------------------

  //handle for I2C master agent
  I2C_agent sl_agent_h;

  //handle for UART slave agent
  UART_agent uart_sl_agt_h;

  //handle for env config
  env_config env_cfg;

  //-------------------------------------------------------
  // Methods
  //-------------------------------------------------------

  extern function new(string name="env",uvm_component parent=null);

  extern function void build_phase(uvm_phase phase);

  extern function void connect_phase(uvm_phase phase);
  
  extern function void end_of_elaboration_phase(uvm_phase phase);

endclass : env

//---------------------------------------------------------
// definitions of functions and tasks of env class
//---------------------------------------------------------

  //-------------------------------------------------------
  // Default Constructor
  //-------------------------------------------------------

  function env::new(string name="env",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  //-------------------------------------------------------
  // Build Phase
  //-------------------------------------------------------

  function void env::build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(!uvm_config_db #(env_config)::get(this,"","env_config",env_cfg))
      `uvm_fatal(get_name(),"failed to get config object")

    sl_agent_h = I2C_agent::type_id::create("sl_agent_h",this);
    uart_sl_agt_h = UART_agent::type_id::create("uart_sl_agt_h",this);

    uvm_config_db #(env_config)::set(this,"*","env_config",env_cfg);

  endfunction : build_phase

  //-------------------------------------------------------
  // Connect Phase
  //-------------------------------------------------------

  function void env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction : connect_phase
 
  //-------------------------------------------------------
  // end_of_elaboration_phase Phase
  //-------------------------------------------------------

  function void env::end_of_elaboration_phase(uvm_phase phase);
     uvm_top.print_topology;
  endfunction:end_of_elaboration_phase

`endif

