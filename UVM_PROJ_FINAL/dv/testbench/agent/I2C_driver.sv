//====================================================================================
//                                                                                   
//  Title         : I2C Master Driver Class                                                 
//  Description   : This file contains class definition of Master Driver of I2C.
//                                                                                      
//====================================================================================

`ifndef I2C_SL_DRI
`define I2C_SL_DRI

class I2C_sl_dri extends uvm_driver #(I2C_seq_item);

  //factory registration
  `uvm_component_utils(I2C_sl_dri)

  //BFM declaration
  virtual I2C_sl_dri_bfm sl_bfm;

  //configuration object handle
   I2C_agent_config sl_cfg;

  static int id;

  int inst_id;
  

  //string inst_name;

  //-------------------------------------------------------
  // Methods
  //-------------------------------------------------------

  extern function new(string name = "I2C_sl_dri",uvm_component parent = null);

  extern function void build_phase(uvm_phase phase);

  extern task run_phase(uvm_phase phase);

endclass : I2C_sl_dri


//---------------------------------------------------------
// definitions of tasks and functions of I2C_sl_dri class
//---------------------------------------------------------

  //-------------------------------------------------------
  // Default Constructor
  //-------------------------------------------------------

  function I2C_sl_dri::new(string name="I2C_sl_dri",uvm_component parent=null);
    super.new(name,parent);
    inst_id = id;
    id++;
  endfunction : new

  //-------------------------------------------------------
  //Description    : build phase for master driver
  //-------------------------------------------------------

  function void I2C_sl_dri::build_phase(uvm_phase phase);
    super.build_phase(phase);
    

    if(!uvm_config_db #(virtual I2C_sl_dri_bfm)::get(this,"","sl_bfm",sl_bfm))
      `uvm_fatal(get_name(),"Failed to get virtual interface")

    if(!uvm_config_db #(I2C_agent_config)::get(this,"","I2C_config",sl_cfg))
      `uvm_fatal(get_name(),"Failed to get configuration object")

  endfunction : build_phase

  //-------------------------------------------------------
  //Description : run phase for Master Driver
  //-------------------------------------------------------

  task I2C_sl_dri::run_phase(uvm_phase phase);
  
    sl_bfm.I2C_sl_dri_initial(inst_id);

    fork
      sl_bfm.I2C_sl_dri_bus_busy_status();
    join_none
    
    forever begin
      I2C_seq_item req;
      req = I2C_seq_item::type_id::create("req");

      seq_item_port.get_next_item(req);
      sl_bfm.I2C_sl_dri_main_task(req,sl_cfg);
      seq_item_port.item_done();
    end

  endtask : run_phase
  
`endif

