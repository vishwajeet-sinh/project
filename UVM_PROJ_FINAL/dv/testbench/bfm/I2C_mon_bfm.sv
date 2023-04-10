//====================================================================================
//                                                                                   
//  Title         : I2C Monitor BFM                                                 
//  Description   : This file contains definition of Bus Functional Model(BFM) for
//                  Monitor of I2C AGENT.
//                                                                                      
//====================================================================================

`ifndef I2C_MON__BFM
`define I2C_MON__BFM

`include "uvm_macros.svh"
//--------------------------------------------------------------
// BFM definition for Monitor
//--------------------------------------------------------------

interface I2C_mon_bfm (
  input clk,
  inout scl,sda
    );

  
  //------------------------------------------------------------
  // Signal Declaration & Assignment
  //------------------------------------------------------------

  logic scl_in,sda_in;

  assign scl_in = scl;
  assign sda_in = sda;
  int byte_count;
  //------------------------------------------------------------
  // Data Members
  //------------------------------------------------------------

    //enum variable to specify bus busy status
    bfm_stat bus_status_e;

    //start and stop detect events
    event start_detect,stop_detect;

    bit prev_wr;

  //------------------------------------------------------------
  // Methods
  //------------------------------------------------------------

    //----------------------------------------------------------
    //Description : task for checking bus status
    //----------------------------------------------------------

    task I2C_mon_bus_busy_status();
      forever
        begin
          @(sda_in);
          if(scl_in==1)
            begin
              if(sda_in==0) //sda changed from 1 to 0
                begin
                  ->start_detect;
                  bus_status_e = env_defines::BUSY;
                end
              else           //sda changed from 0 to 1
                begin
                  ->stop_detect;
                  bus_status_e = env_defines::FREE;
                end
            end
        end 
    endtask : I2C_mon_bus_busy_status

    //----------------------------------------------------------
    //Description : task to wait for start condition
    //----------------------------------------------------------

    task I2C_mon_wait_for_start_condition();
      @(start_detect);
      `uvm_info("I2C_MON","start condition detected",UVM_HIGH)
    endtask : I2C_mon_wait_for_start_condition

    //----------------------------------------------------------
    //Description : task to wait for stop condition
    //----------------------------------------------------------

    task I2C_mon_wait_for_stop_condition();
      @(stop_detect);
      `uvm_info("I2C_MON","stop condition detected",UVM_HIGH)
    endtask : I2C_mon_wait_for_stop_condition

    //----------------------------------------------------------
    //Description    : function to print error message
    //----------------------------------------------------------

    function void I2C_mon_err_msg_print(int err_id);
      if(err_id==1)
        begin
	  `uvm_error("I2C_MON","ERROR : Protocol violation")
          `uvm_error("I2C_MON","Expected STOP condition after NACK")
          `uvm_error("I2C_MON","Refer to section 3.1.6 of I2C Specification")
        end
      else if(err_id==6)
        begin
	  `uvm_error("I2C_MON","ERROR : Protocol violation for gen call")
          `uvm_error("I2C_MON","8'h00 as 2nd byte of general call is not allowed")
          `uvm_error("I2C_MON","Refer to section 3.1.13 of I2C Specification") 
        end
      else if(err_id==8)
        begin
          `uvm_warning("I2C_MON","ERROR : Void Message is Received")
          `uvm_warning("I2C_MON","Refer to section 3.1.10 of I2C Specification")
        end
    endfunction : I2C_mon_err_msg_print

    //----------------------------------------------------------
    //Description : task for monitoring and checking 7bit slave 
    //              addr rd or wr operation
    //----------------------------------------------------------

    task I2C_mon_7bit_trans_check(inout I2C_seq_item seq_item);
      @(posedge scl_in);
            
      if(!sda_in)
        begin
	  `uvm_info("I2C_MON","got ACK for 7 bit addr",UVM_HIGH)
          seq_item.ack_nack_q.push_back(1'b0);
          I2C_mon_data_trans_check(seq_item);
        end
      else
        begin
          `uvm_info("I2C_MON","got NACK for 7 bit addr",UVM_HIGH)
          seq_item.ack_nack_q.push_back(1'b1);
        end
    endtask:I2C_mon_7bit_trans_check

    //----------------------------------------------------------
    //Description : task for monitoring and checking general 
    //              call transfer
    //----------------------------------------------------------
  
    task I2C_mon_gen_call_second_byte_check(inout I2C_seq_item seq_item);
   
      //declaration of variables
      bit [7:0] gen_call_2nd_byte;
      `uvm_info("I2C_MON","inside general call second byte check task",UVM_HIGH)
        
      for(int i=7;i>=0;i--)
        begin
          @(posedge scl_in)
          gen_call_2nd_byte[i] = sda_in;
        end
      
      seq_item.data_q.push_back(gen_call_2nd_byte);
      seq_item.no_of_data_byte++;

      if(gen_call_2nd_byte[0]==0)
        begin
          if(gen_call_2nd_byte == 'h00)
            begin
              I2C_mon_err_msg_print(6);
            end
          
	  else if(gen_call_2nd_byte == 'h06 || gen_call_2nd_byte == 'h04)
            begin
              @(posedge scl_in)
              if(sda_in)
                begin
                  `uvm_info("I2C_MON","got NACK",UVM_HIGH)
		  seq_item.ack_nack_q.push_back(1'b1);
                  
                      @(posedge scl_in); //this clk may come due to setup for R_START or STOP
                      @(posedge scl_in)
                      I2C_mon_err_msg_print(1);
		end
	      else
	        begin
	          `uvm_info("I2C_MON","got ACK",UVM_HIGH)
		  seq_item.ack_nack_q.push_back(1'b0);
		end
            end
          
	  else
            begin
	      `uvm_error("I2C_MON","unspecified general call")
              `uvm_error("I2C_MON","2nd byte is ignored")
	      @(posedge scl_in);
	      seq_item.ack_nack_q.push_back(sda_in);
            end
        end
      
      else
        begin
	  `uvm_info("I2C_MON","got HW gen call",UVM_HIGH)
          @(posedge scl_in)
          if(!sda_in)
            begin
	      `uvm_info("I2C_MON","got ACK",UVM_HIGH)
	      seq_item.ack_nack_q.push_back(1'b0);
              
	     	          `uvm_info("I2C_MON","data transfer task is called",UVM_HIGH)
                  I2C_mon_data_trans_check(seq_item);
            end
          
	  else
            begin
	      `uvm_info("I2C_MON","got NACK",UVM_HIGH)
              seq_item.ack_nack_q.push_back(1'b1);
              
                  @(posedge scl_in); //this clk may come due to setup for R_START or STOP
                  @(posedge scl_in)
                  I2C_mon_err_msg_print(1);
	        end    
        end
    endtask : I2C_mon_gen_call_second_byte_check

    //----------------------------------------------------------
    //Description : task for monitoring and checking data trans
    //              sequence for 7bit as well 10bit
    //----------------------------------------------------------
    
    task I2C_mon_data_trans_check(inout I2C_seq_item seq_item);
      bit [7:0] data;

      forever
        begin
          for(int i=7;i>=0;i--)
	    begin
              @(posedge scl_in);
	      data[i] = sda_in;
	    end

          seq_item.data_q.push_back(data);
	  seq_item.no_of_data_byte++;
        
          @(posedge scl_in);

	

             if(sda_in)
               begin
	          seq_item.ack_nack_q.push_back(1'b1);
              
                  @(posedge scl_in); //this clk may come due to setup for R_START or STOP
                  @(posedge scl_in);
                  return;
               end
             else
	       begin
	         seq_item.ack_nack_q.push_back(1'b0);
	       end
		   if(seq_item.no_of_data_byte==byte_count) begin
		     break;

			 end
        end
    endtask : I2C_mon_data_trans_check

    //----------------------------------------------------------
    //Description : task for monitoring and checking first byte 
    //              after start
    //----------------------------------------------------------
  
    task I2C_mon_first_byte_check(inout I2C_seq_item seq_item);

      bit [7:0] first_byte;

      `uvm_info("I2C_MON","inside first byte check task",UVM_HIGH)

      for(int i=7; i>=0; i--)
        begin
          @(posedge scl_in)
	  first_byte[i] = sda_in;
        end

      casex(first_byte)
      8'b0000_0000 : 
                    begin
                      `uvm_info("I2C_MON","first byte detected as gen call",UVM_HIGH)
                      seq_item.op_e = I2C_seq_item::GEN_CALL;
                      seq_item.address = first_byte;

                      @(posedge scl_in);

                      
			  if(!sda_in)
                            begin
			      `uvm_info("I2C_MON","got ACK on gen call",UVM_HIGH)
                              seq_item.ack_nack_q.push_back(1'b0);
                              I2C_mon_gen_call_second_byte_check(seq_item);
                            end
                          else
                            begin
                              `uvm_info("I2C_MON","got NACK on gen call",UVM_HIGH)
                              seq_item.ack_nack_q.push_back(1'b1);
                          
                              @(posedge scl_in); //this clk may come due to setup for R_START or STOP
                              @(posedge scl_in);
                              I2C_mon_err_msg_print(1);
                            end
                    end
     
     
      8'b0000_01XX : 
                    begin
		      `uvm_error("I2C_MON","ERROR: Invalid slave address")
                      `uvm_error("I2C_MON","this address is reserved for future use")
                    end
      
      default : 
                    begin
		      `uvm_info("I2C_MON","first byte detected as 7 bit addr",UVM_HIGH)
		      seq_item.op_e = I2C_seq_item::ADDR_7_BIT;
                      seq_item.address[6:0] = first_byte[7:1];
		      seq_item.R_W_mode = first_byte[0];

                        I2C_mon_7bit_trans_check(seq_item);
                    end
      endcase
    endtask : I2C_mon_first_byte_check


    //----------------------------------------------------------
    //Description : task for void message check
    //----------------------------------------------------------
    
    task I2C_mon_void_msg_check();
      bit msg;
      forever
        begin
          @(start_detect);
          msg=0;
          fork
            begin
              @(posedge scl_in);
              msg=1;
            end
          
            begin
              @(stop_detect);
            end
          join_any
        
          if(msg==0)
	    I2C_mon_err_msg_print(8);
        end
    endtask : I2C_mon_void_msg_check

    //----------------------------------------------------------
    //Description : task for different mode speed check
    //----------------------------------------------------------
 
    task I2C_mon_speed_mode_check(inout I2C_seq_item seq_item);
      realtime t0,t1,period;
      
      @(posedge scl_in);
      t0=$realtime;
      @(posedge scl_in);
      t1=$realtime;
      period=(t1-t0);
     
        if(period >= 9us)
	  begin
            `uvm_info("I2C_MON","Speed Mode is Standard Mode",UVM_HIGH)
	    seq_item.sm_e = I2C_seq_item::SM;
          end 
        
	else if(period >= 2.4us)
	  begin
            `uvm_info("I2C_MON","Speed Mode is Fast Mode",UVM_HIGH)
            seq_item.sm_e = I2C_seq_item::FM;
          end
        
	else
	  `uvm_info("I2C_MON","speed mode error",UVM_HIGH)
     
    endtask: I2C_mon_speed_mode_check

    //----------------------------------------------------------
    //Description : Main task for monitor
    //----------------------------------------------------------

    task I2C_mon_main_task(inout I2C_seq_item seq_item,input int byte_count);
      `uvm_info("I2C_MON","inside main task",UVM_HIGH)
        byte_count = byte_count; 
        if(bus_status_e == env_defines::FREE)
	  begin
	    `uvm_info("I2C_MON","waiting for START",UVM_HIGH)
	    I2C_mon_wait_for_start_condition();
	  end

        `uvm_info("I2C_MON","forking first byte task",UVM_HIGH)
          I2C_mon_first_byte_check(seq_item);

    endtask : I2C_mon_main_task

endinterface : I2C_mon_bfm

`endif


