//===================================================================================
//                                                                                   
//  Title         : Env Configuration Class                                     
//  Description   : This is Configuration Class for env          
//                                                                                      
//===================================================================================

`ifndef ENV_CONFIG
`define ENV_CONFIG

class env_config extends uvm_object;

  //-------------------------------------------------------
  // Data Members
  //-------------------------------------------------------
  
  //I2C members

  //variable for scoreboard enable
  bit scoreboard_en = 1;

  bit [9:0] slave_address;

  //variable for specifying addressing mode of slave
  rand env_defines::slave_addr_mode sl_addr_mode_e;

  //UART configs 
  UART_agent_config uart_agt_cfg;
  
  real baud_rate=9600;

  //-------------------------------------------------------
  // Constraints
  //-------------------------------------------------------

  //-------------------------------------------------------
  // Factory Registration
  //-------------------------------------------------------

    `uvm_object_utils_begin(env_config)
       `uvm_field_int(scoreboard_en, UVM_ALL_ON)
       `uvm_field_enum(env_defines::slave_addr_mode, sl_addr_mode_e, UVM_ALL_ON)
    `uvm_object_utils_end

  //-------------------------------------------------------
  // Methods
  //-------------------------------------------------------

  extern function new(string name = "env_config");

endclass : env_config

//---------------------------------------------------------
// definition of function and task of env_config class
//---------------------------------------------------------
 
  //-------------------------------------------------------
  // Default constructor
  //-------------------------------------------------------

  function env_config::new(string name = "env_config");
    super.new(name);
  endfunction : new

`endif

