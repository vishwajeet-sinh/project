//====================================================================================
//                                                                                   
//  Title         : UART Agent Class                                                 
//  Description   : This file contains definition of Agent Class of UART VIP.This class 
//                  instantiates Master/Slave Driver based on configuration, Sequencer and Monitor component.
//                                                                                      
//====================================================================================

`ifndef UART_AGENT
`define UART_AGENT

class UART_agent extends uvm_agent;

  //-------------------------------------------------------
  // Factory Registration
  //-------------------------------------------------------
 	`uvm_component_utils(UART_agent)
	
  //-------------------------------------------------------
  // Data Members
  //-------------------------------------------------------
  
  typedef uvm_sequencer #(UART_seq_item) UART_sequencer;
  
  //handle for  sequencer
  UART_sequencer uart_sequencer_h;

  //handle of agent configuration class.
  UART_agent_config uart_agt_cfg;

  //handle for  driver
  UART_driver uart_drv_h;
  

  //handle for  monitor
  UART_monitor uart_mon_h;  
 
  //-------------------------------------------------------
  // Methods
  //-------------------------------------------------------
  
  extern function new(string name="UART_agent", uvm_component parent);
  
  extern function void build_phase(uvm_phase phase);
  
  extern function void connect_phase (uvm_phase phase);

endclass : UART_agent


//---------------------------------------------------------
// definitions of functions and tasks of I2C_agent class
//---------------------------------------------------------

  //-------------------------------------------------------
  // Default Constructor
  //-------------------------------------------------------
  function UART_agent::new(string name="UART_agent", uvm_component parent);
	super.new(name, parent);
  endfunction:new


  //-------------------------------------------------------
  // Build Phase
  //-------------------------------------------------------
  
  function void UART_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);
  
 	if(!uvm_config_db #(UART_agent_config)::get(this,"","UART_agent_config",uart_agt_cfg))
	`uvm_fatal("CONFIG", "cannot get() uart_agt_cfg from uvm_config_db. Have you set it?")

	uart_mon_h=UART_monitor::type_id::create("uart_mon_h", this);
	
	if(uart_agt_cfg.is_active==UVM_ACTIVE)
	begin
	  uart_drv_h = UART_driver::type_id::create("uart_drv_h", this);
	  uart_sequencer_h = UART_sequencer::type_id::create("uart_sequencer_h", this);
    end

  endfunction:build_phase


  //-------------------------------------------------------
  // Connect Phase
  //-------------------------------------------------------
  
  function void UART_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
	if(uart_agt_cfg.is_active==UVM_ACTIVE)
     uart_drv_h.seq_item_port.connect(uart_sequencer_h.seq_item_export);
  endfunction:connect_phase

`endif
