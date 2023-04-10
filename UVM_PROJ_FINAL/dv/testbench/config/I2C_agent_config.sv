//====================================================================================
//                                                                                   
//  Title         : I2C agent config Class                                                 
//  Description   : This file contains configuration based on which agent is configure.
//                                                                                      
//====================================================================================

`ifndef I2C_AGT_CONFIG
`define I2C_AGT_CONFIG
class I2C_agent_config extends uvm_object;
  
  //-------------------------------------------------------
  // Factory Registration
  //-------------------------------------------------------

	`uvm_object_utils(I2C_agent_config)
  
  //-------------------------------------------------------
  // Data Members
  //-------------------------------------------------------
  
  //handle of interface
  virtual I2C_intf vif;
  
  //is_active is decide construction of driver and sequencer
  uvm_active_passive_enum is_active=UVM_ACTIVE;  
  rand env_defines::slave_addr_mode sl_addr_mode_e;
  bit [9:0] slave_address;
  
  //-------------------------------------------------------
  // Methods
  //-------------------------------------------------------

  extern function new (string name = "I2C_agent_config");

endclass

//-------------------------------------------------------
// Default Constructor
//-------------------------------------------------------

function I2C_agent_config::new(string name = "I2C_agent_config");
	super.new(name);
endfunction:new

`endif

