//====================================================================================
//                                                                                   
//  Title         : I2C Slave Driver BFM                                                 
//  Description   : This file contains definition of Bus Functional Model(BFM) for
//                  Slave driver of I2C.
//                                                                                      
//====================================================================================

`ifndef I2C_SL_DRI_BFM
`define I2C_SL_DRI_BFM

`include "uvm_macros.svh"


//---------------------------------------------------------
// BFM definition for Slave Driver
//---------------------------------------------------------

interface I2C_sl_dri_bfm (
   inout scl,sda
    );
    timeunit 10ps;
	timeprecision 1ps;
    logic scl_in;  //signal to sample scl
    logic scl_out; //signal to drive scl
    logic sda_in;  //signal to sample sda
    logic sda_out; //signal to drive sda

    assign scl = scl_out ? 1'bz : scl_out; //if scl_out==1 then register pull up
                                           //else pass the value of scl_out to scl
    assign scl_in = scl; //assign value of scl to scl_in
  
    assign sda = sda_out ? 1'bz : sda_out; //if sda_out==1 then register pull up
                                           //else pass the value of sda_out to sda
    assign sda_in = sda; //assign value of sda to sda_in

  //-------------------------------------------------------
  // Data Members
  //-------------------------------------------------------

  event start_detect,stop_detect;  //event variables to detect START and STOP
 
  enum {FREE,BUSY} bus_status_e;   //enum variable to update bus status
  bit start_detect_sgl;

  bit dev_id_addr_match;           //variable to identify device id
  
  bit [7:0] data_byte_q[$];        //data queue 
  
  int comp_id;

  bit prev_wr;

  bit data_tran;

  bit [7:0] sl_data_q[$];
   
  //-------------------------------------------------------
  // Methods
  //-------------------------------------------------------
  

  function void I2C_sl_dri_initial(int inst_id);
    scl_out=1; //enabling pull-up
    sda_out=1; //enabling pull-up
    comp_id=inst_id;
  endfunction : I2C_sl_dri_initial
 
  //-------------------------------------------------------
  //Description : task for checking bus status
  //-------------------------------------------------------

  task I2C_sl_dri_bus_busy_status();
   forever 
      begin
        @(sda);
		
         if(scl_in==1)
          begin
            if(sda==0) //sda changed from 1 to 0
              begin
                ->start_detect;
				start_detect_sgl=1;
                bus_status_e = BUSY;
              end
            else           //sda changed from 0 to 1
              begin
                ->stop_detect;
				start_detect_sgl=0;
                bus_status_e = FREE;
              end
          end
      end 
  endtask : I2C_sl_dri_bus_busy_status
  
  //----------------------------------------------------------
  //Description : task for checking first byte transmitted on SDA after start condition.
  //----------------------------------------------------------

  task I2C_sl_dri_first_byte_check(I2C_seq_item req,I2C_agent_config cfg);
    bit [7:0] first_byte,second_byte,data;
   
    `uvm_info($sformatf("I2C_SL_DRI[%0d]",comp_id),"inside first byte check task",UVM_HIGH)
    for(int i=7;i>=0;i--)
      begin
        @(posedge scl_in);
        first_byte[i] = sda_in; //sampling addr bit from SDA
      end
    
    if((cfg.sl_addr_mode_e==env_defines::ADDR_7_BIT) && (first_byte[7:1]== req.address[6:0]))  //check for 7 bit addr match 
      begin
        `uvm_info($sformatf("I2C_SL_DRI[%0d]",comp_id),"address matched",UVM_HIGH)
        
          @(negedge scl_in);
          sda_out = 0; //giving ACK
          `uvm_info($sformatf("I2C_SL_DRI[%0d]",comp_id),"giving ACK",UVM_HIGH)


        @(negedge scl_in);
        sda_out=1;  //enabling pull-up

	      if(first_byte[0]==0) //checking R/W bit
	        begin
	          `uvm_info($sformatf("I2C_SL_DRI[%0d]",comp_id),"Calling Slave RX task",UVM_HIGH)
	           I2C_sl_dri_rx_mode(req.ack_nack_q,sl_data_q,req.sm_e);
	        end

	      else if(first_byte[0]==1 )
	        begin
	          `uvm_info($sformatf("I2C_SL_DRI[%0d]",comp_id),"Calling Slave TX task",UVM_HIGH)
	          I2C_sl_dri_tx_mode(req.data_q);
	        end
      end
    
    else if(first_byte==8'h00) //check for general call
      begin
        `uvm_info($sformatf("I2C_SL_DRI[%0d]",comp_id),"got General Call Address",UVM_HIGH)

        @(negedge scl_in);
        sda_out = req.ack_nack_q.pop_front(); 
       
        @(negedge scl_in);
        sda_out=1;  //enabling pull-up
            
        for(int i=7;i>=0;i--)
          begin
            @(posedge scl_in);
            data[i] = sda_in;
          end
      
        if(data[0]==0)
          begin
           
           if(data=='h06 || data=='h04)
             begin

                 @(negedge scl_in);
                 sda_out = req.ack_nack_q.pop_front(); 

               @(negedge scl_in);
               sda_out = 1; //enabling pull-up

             end
           
           else if(data=='h00)
             begin
               `uvm_info($sformatf("I2C_SL_DRI[%0d]",comp_id),"invalid 2nd byte: set as 8'h00",UVM_HIGH)
               
               @(negedge scl_in);
               sda_out = 1; 
        
               @(negedge scl_in);
               sda_out = 1; //enabling pull-up

             end

           else
             begin
               `uvm_info($sformatf("I2C_SL_DRI[%0d]",comp_id),"ignoring unspecified 2nd byte",UVM_HIGH)
               
               @(negedge scl_in);
               sda_out = 1; 
        
               @(negedge scl_in);
                sda_out = 1; //enabling pull-up

              end
          end
        else if(data[0]==1 )
          begin
            `uvm_info($sformatf("I2C_SL_DRI[%0d]",comp_id),"calling gen call 2nd byte check task",UVM_HIGH)
 	           I2C_sl_dri_gen_call_2nd_byte_check(req.ack_nack_q,req.data_q,req.sm_e); 
          end
      end 

    else
      begin
        @(negedge scl_in);
	      sda_out=1;
        `uvm_info($sformatf("I2C_SL_DRI[%0d]",comp_id),"giving NACK",UVM_HIGH)
      end
    
  endtask : I2C_sl_dri_first_byte_check
  
  //---------------------------------------------------------
  //Description : task for Slave Receive mode. 
  //---------------------------------------------------------
  
  task I2C_sl_dri_rx_mode(input bit ack_nack[$],output bit [7:0] sl_data_q[$],input I2C_seq_item::speed_mode sm_e);
    bit [7:0] data;
    
    `uvm_info($sformatf("I2C_SL_DRI[%0d]",comp_id),"inside RX mode task",UVM_HIGH) 
    data_tran = 0;
    
    forever begin
      for(int i=7;i>=0;i--)
        begin
          @(posedge scl_in);
	  data[i] = sda_in;   //sampling data bit from SDA
        end
      
      data_tran = 1;
      sl_data_q.push_back(data);
        @(negedge scl_in);
        sda_out = ack_nack.pop_front();
      
      @(negedge scl_in);
      sda_out=1;  //enabling pull-up
	 if(ack_nack.size()==0) begin
	    break;
		end

    end

  endtask : I2C_sl_dri_rx_mode
  
  //---------------------------------------------------------
  //Description : task for transmit mode
  //---------------------------------------------------------
  
  task I2C_sl_dri_tx_mode(input bit [7:0] data_byte_q[$]);
    bit [7:0] data;
    
    `uvm_info($sformatf("I2C_SL_DRI[%0d]",comp_id),"inside TX mode task",UVM_HIGH)
    
    forever begin
      data = data_byte_q.pop_front();
    
      for(int i=7;i>=0;i--)
        begin
          sda_out = data[i];
          @(negedge scl_in);
        end
    
      sda_out = 1;  //enabling pull-up
    
      @(posedge scl_in); //waiting for ACK or NACK from Master
      if(sda_in) 
        begin
	  `uvm_info($sformatf("I2C_SL_DRI[%0d]",comp_id),"got NACK from Master",UVM_HIGH)
	  return;
        end

      else
        begin
	   `uvm_info($sformatf("I2C_SL_DRI[%0d]",comp_id),"got ACK from Master",UVM_HIGH)
	end

      @(negedge scl_in); //waiting for negative edge of 9th clock
	  if(data_byte_q.size()==0)
	    break;
    end
    
  endtask : I2C_sl_dri_tx_mode
  
  //----------------------------------------------------------
  //Description : task for gen call 2nd byte
  //----------------------------------------------------------
  
  task I2C_sl_dri_gen_call_2nd_byte_check(input bit ack_nack[$],output bit [7:0] data_q[$],input I2C_seq_item::speed_mode sm_e);
    
    @(negedge scl_in);
    sda_out = ack_nack.pop_front(); 
      
    @(negedge scl_in);
    sda_out = 1; //enabling pull-up
    
    `uvm_info($sformatf("I2C_SL_DRI[%0d]",comp_id),"got HW Gen Call",UVM_HIGH)
    `uvm_info($sformatf("I2C_SL_DRI[%0d]",comp_id),"calling RX Mode Task",UVM_HIGH)
    
    I2C_sl_dri_rx_mode(ack_nack,data_q,sm_e);
    
  endtask : I2C_sl_dri_gen_call_2nd_byte_check

  //------------------------------------------------------
  //Description : task for waiting till start condition detect
  //------------------------------------------------------

  task I2C_sl_dri_wait_for_start_detect();
    @(start_detect);
    `uvm_info($sformatf("I2C_SL_DRI[%0d]",comp_id),"start condition detected",UVM_HIGH)
  endtask : I2C_sl_dri_wait_for_start_detect

  //------------------------------------------------------
  //Description : task for waiting till stop condition detect
  //------------------------------------------------------

  task I2C_sl_dri_wait_for_stop_detect();
    @(stop_detect);
    `uvm_info($sformatf("I2C_SL_DRI[%0d]",comp_id),"stop condition detected",UVM_HIGH)
  endtask : I2C_sl_dri_wait_for_stop_detect
  
  //-------------------------------------------------------
  //Description : Main task for I2C Slave Driver
  //-------------------------------------------------------

  task I2C_sl_dri_main_task(I2C_seq_item req,I2C_agent_config cfg);
    
    if(bus_status_e==FREE)
      begin
        @(start_detect);
        `uvm_info($sformatf("I2C_SL_DRI[%0d]",comp_id),"start condition detected",UVM_HIGH)
      end
      
    I2C_sl_dri_first_byte_check(req,cfg);
  endtask : I2C_sl_dri_main_task

endinterface: I2C_sl_dri_bfm
`endif

