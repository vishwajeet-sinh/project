//====================================================================================
//                                                                                   
//  Title         : I2C Monitor Class                                                 
//  Description   : This is Monitor Class for I2C Agent. this class also contains task   
//                  and functions which will check SDA and SCL line and will report   
//                  error for any I2C protocol violation.                             
//                                                                                      
//====================================================================================

`ifndef I2C_MONITOR
`define I2C_MONITOR


class I2C_monitor extends uvm_monitor;

  //----------------------------------------------------------
  // factory registration
  //----------------------------------------------------------

  `uvm_component_utils(I2C_monitor)

  //----------------------------------------------------------
  // Data Members
  //----------------------------------------------------------

  //virtual interface declaration
  virtual I2C_mon_bfm mon_bfm; 

  //analysis port declaration
  uvm_analysis_port #(I2C_seq_item) mon_aport;
  
  int byte_count;
  //----------------------------------------------------------
  // Methods
  //----------------------------------------------------------

  extern function new(string name="I2C_monitor",uvm_component parent=null);

  extern function void build_phase(uvm_phase phase);

  extern task run_phase(uvm_phase phase);

endclass : I2C_monitor

//------------------------------------------------------------
// definitions of task and functions of monitor class
//------------------------------------------------------------

  //----------------------------------------------------------
  // default constructor override
  //----------------------------------------------------------

  function I2C_monitor::new(string name ="I2C_monitor",uvm_component parent = null);
    super.new(name,parent);
  endfunction : new

  //----------------------------------------------------------
  // build phase for Monitor
  //----------------------------------------------------------

  function void I2C_monitor::build_phase(uvm_phase phase);
    super.build_phase(phase);

    //get virtual interface from config_db
    if(!uvm_config_db #(virtual I2C_mon_bfm)::get(this,"","mon_bfm",mon_bfm))
      `uvm_fatal("I2C_MON","failed to get virtual interface")

    mon_aport = new("mon_aport",this);

  endfunction : build_phase

  //----------------------------------------------------------
  // Run phase for Monitor
  //----------------------------------------------------------

  task I2C_monitor::run_phase(uvm_phase phase);
    fork
      mon_bfm.I2C_mon_bus_busy_status();
      mon_bfm.I2C_mon_void_msg_check();
    join_none

    mon_bfm.I2C_mon_wait_for_start_condition();

    forever begin
      I2C_seq_item seq_item_h;
	  int pck_no_write;
      seq_item_h = I2C_seq_item::type_id::create("seq_item_h");
      if(!uvm_config_db #(int)::get(this,"","byte_count",byte_count))
        `uvm_fatal("I2C_MON","failed to get byte count")
		mon_bfm.byte_count=byte_count;
      
        mon_bfm.I2C_mon_main_task(seq_item_h,byte_count);

        foreach(seq_item_h.ack_nack_q[i]) begin
           if(seq_item_h.ack_nack_q[i]==1) begin
		      pck_no_write=1;
              break;
		   end
		end

		if(pck_no_write==0) begin
          mon_aport.write(seq_item_h);
		  mon_bfm.bus_status_e = env_defines::FREE;
		end
    end     

  endtask : run_phase  

`endif


