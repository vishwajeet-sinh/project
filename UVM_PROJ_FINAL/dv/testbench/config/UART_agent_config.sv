//====================================================================================
//                                                                                   
//  Title         : UART agent config Class                                                 
//  Description   : This file contains configuration based on which agent is configure.
//                                                                                      
//====================================================================================

`ifndef UART_AGT_CONFIG
`define UART_AGT_CONFIG

class UART_agent_config extends uvm_object;
  
  //-------------------------------------------------------
  // Factory Registration
  //-------------------------------------------------------

	`uvm_object_utils(UART_agent_config)
  
  //-------------------------------------------------------
  // Data Members
  //-------------------------------------------------------
  
  //handle of interface
  virtual uart_if vif;
  
  //is_active is decide construction of driver and sequencer
  uvm_active_passive_enum is_active=UVM_ACTIVE;  
  
  real baud_rate=9600;
  
  //-------------------------------------------------------
  // Methods
  //-------------------------------------------------------

  extern function new (string name = "UART_agent_config");

endclass

//-------------------------------------------------------
// Default Constructor
//-------------------------------------------------------

function UART_agent_config::new(string name = "UART_agent_config");
	super.new(name);
endfunction:new

`endif
