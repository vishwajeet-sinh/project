//------------------------------------------------------------------------------------------------//
//  
//  Title			: UART driver
//  Description     : This file contains class definition of  Driver of UART. 
//------------------------------------------------------------------------------------------------//
class UART_driver extends uvm_driver #(UART_seq_item);


  //factory registration
	`uvm_component_utils(UART_driver)
  
  //-------------------------------------------------------
  // Data Members
  //-------------------------------------------------------
  
  //interface instance
	virtual uart_if vif;

  //configuration object handle
  UART_agent_config uart_cfg;
  
  //baud_rate time
  real bit_time;
 
  //-------------------------------------------------------
  // Methods
  //-------------------------------------------------------

  extern function new (string name="UART_driver", uvm_component parent);

  extern function void build_phase(uvm_phase phase);

  extern function void connect_phase(uvm_phase phase);

  extern task run_phase(uvm_phase phase);
  
  extern task drive_data(UART_seq_item xtn);
endclass:UART_driver


//-------------------------------------------------------
// Default Constructor
//-------------------------------------------------------

function UART_driver::new(string name = "UART_driver", uvm_component parent);
	super.new(name, parent);
endfunction:new


//-----------------------------------------------------------------------------------------------//
//  Build_phase
//------------------------------------------------------------------------------------------------//
function void UART_driver::build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db #(UART_agent_config)::get(this,"","UART_agent_config",uart_cfg))
	`uvm_fatal("CONFIG","Cannot get() uart_cfg from uvm_config_db. Have you set() it?")
	if(!uvm_config_db#(virtual uart_if)::get(this,"","vif_0",vif))
	`uvm_fatal("inteface","did not get uart interface");
endfunction:build_phase


//------------------------------------------------------------------------------------------------//
//  Connect_phase
//------------------------------------------------------------------------------------------------//
function void UART_driver::connect_phase(uvm_phase phase);
	
endfunction:connect_phase


//-----------------------------------------------------------------------------------------------//
//  Run_phase
//------------------------------------------------------------------------------------------------//
task UART_driver::run_phase(uvm_phase phase);

  //initial reset condition
    @(negedge vif.reset);

  // Driving the reset values
   	vif.tx <= 0;
  //Defining the time period required for each cycle transmission
  	bit_time = (1/(uart_cfg.baud_rate)*1e9);
    
  	forever
  	begin
  	seq_item_port.get_next_item(req);
	if(!uvm_config_db #(UART_agent_config)::get(this,"","UART_agent_config",uart_cfg))
	`uvm_fatal("CONFIG","Cannot get() uart_cfg from uvm_config_db. Have you set() it?")
  	drive_data(req);
  	seq_item_port.item_done();
  	end 
endtask:run_phase

//-----------------------------------------------------------------------------
// Task: drive_data
//-----------------------------------------------------------------------------
task UART_driver::drive_data(UART_seq_item xtn);

  	bit_time = (1/(uart_cfg.baud_rate)*1e9);
// Start condition
    vif.rx_enable<=1;
    vif.tx<=1;
	#(bit_time);
    vif.tx<=1'b0;
    #(bit_time);

// Driving the data
	for(int i=0;i<8;i++)
  	begin
  	vif.tx <= req.data[i];
  	#(bit_time);
  	end

// Stop condition
  	vif.tx<=1'b1;
  	#(bit_time);
    vif.rx_enable<=0;
  	#(bit_time);
endtask: drive_data

