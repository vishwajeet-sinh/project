//====================================================================================
//                                                                                   
//  Title         : I2C Agent Class                                                 
//  Description   : This file contains definition of Agent Class of I2C VIP.This class 
//                  instantiates Master/Slave Driver based on configuration, Sequencer and Monitor component.
//                                                                                      
//====================================================================================

`ifndef I2C_AGENT
`define I2C_AGENT

class I2C_agent extends uvm_agent;

  //-------------------------------------------------------
  // Factory Registration
  //-------------------------------------------------------

  `uvm_component_utils(I2C_agent);

  //-------------------------------------------------------
  // Data Members
  //-------------------------------------------------------

  typedef uvm_sequencer #(I2C_seq_item) I2C_sequencer;

  //handle for  sequencer
  I2C_sequencer i2c_sequencer_h;

  //handle of agent configuration class.
  I2C_agent_config i2c_agt_cfg;

  //handle for  driver
  I2C_sl_dri i2c_dri_h;

  //handle for  monitor
  I2C_monitor I2C_mon_h;

  //analysis port declaration
  uvm_analysis_port #(I2C_seq_item) ms_aport;

  //-------------------------------------------------------
  // Methods
  //-------------------------------------------------------

  extern function new(string name="I2C_agent",uvm_component parent=null);

  extern function void build_phase(uvm_phase phase);

  extern function void connect_phase(uvm_phase phase);

endclass : I2C_agent

//---------------------------------------------------------
// definitions of functions and tasks of I2C_agent class
//---------------------------------------------------------

  //-------------------------------------------------------
  // Default Constructor
  //-------------------------------------------------------

  function I2C_agent::new(string name="I2C_agent",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  //-------------------------------------------------------
  // Build Phase
  //-------------------------------------------------------

  function void I2C_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);

 	if(!uvm_config_db #(I2C_agent_config)::get(this,"","I2C_config",i2c_agt_cfg))
	`uvm_fatal("CONFIG", "cannot get() i2c_agt_cfg from uvm_config_db. Have you set it?")
	
    I2C_mon_h = I2C_monitor::type_id::create("I2C_mon_h",this);

	if(i2c_agt_cfg.is_active==UVM_ACTIVE) begin
    i2c_sequencer_h = I2C_sequencer::type_id::create("i2c_sequencer_h",this);
    i2c_dri_h = I2C_sl_dri::type_id::create("i2c_dri_h",this);
    end
    ms_aport=new("ms_aport",this);

  endfunction : build_phase

  //-------------------------------------------------------
  // Connect Phase
  //-------------------------------------------------------

  function void I2C_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    //connect driver and sequencer
	if(i2c_agt_cfg.is_active==UVM_ACTIVE)
    i2c_dri_h.seq_item_port.connect(
             i2c_sequencer_h.seq_item_export);
    
  endfunction : connect_phase

`endif

