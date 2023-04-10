//====================================================================================
//                                                                                   
//  Title         : I2C Scoreboard Predictor Class                                                 
//  Description   : This file contains definition for SCB class.
//                                                                                      
//====================================================================================

`ifndef SCB
`define SCB

class scb extends uvm_component;

  //-------------------------------------------------------
  // Factory Registration
  //-------------------------------------------------------

  `uvm_component_utils(scb)

  //-------------------------------------------------------
  // Data Members
  //-------------------------------------------------------

  uvm_analysis_export #(I2C_seq_item) I2C_mon_in;
  uvm_analysis_export #(UART_seq_item) UART_tx_in;
  uvm_analysis_export #(UART_seq_item) UART_rx_in;

  uvm_tlm_analysis_fifo #(I2C_seq_item) I2C_mon_fifo;
  uvm_tlm_analysis_fifo #(UART_seq_item)UART_tx_fifo;
  uvm_tlm_analysis_fifo #(UART_seq_item)UART_rx_fifo;


  I2C_seq_item i2c_mon_tr;
  UART_seq_item uart_tx_tr, uart_rx_tr;
  //-------------------------------------------------------
  // Methods
  //-------------------------------------------------------

  extern function new(string name="scb",uvm_component parent=null);

  extern function void build_phase(uvm_phase phase);

  extern function void connect_phase(uvm_phase phase);

  extern task run_phase(uvm_phase phase);

  extern task predict_result();

endclass : scb

//--------------------------------------------------------------
// Definition of Methods of scb class
//--------------------------------------------------------------

  //------------------------------------------------------------
  // Default constructor 
  //------------------------------------------------------------

  function scb::new(string name="scb",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  //------------------------------------------------------------
  // build phase
  //------------------------------------------------------------

  function void scb::build_phase(uvm_phase phase);
    super.build_phase(phase);
    I2C_mon_in = new("I2C_mon_in",this);
    UART_tx_in = new("UART_tx_in",this);
    UART_rx_in = new("UART_rx_in",this);
    I2C_mon_fifo = new("I2C_mon_fifo",this);
    UART_tx_fifo = new("UART_tx_fifo",this);
    UART_rx_fifo = new("UART_rx_fifo",this);

  endfunction : build_phase

  //------------------------------------------------------------
  // Connect phase
  //------------------------------------------------------------

  function void scb::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    I2C_mon_in.connect(I2C_mon_fifo.analysis_export);
    UART_tx_in.connect(UART_tx_fifo.analysis_export);
    UART_rx_in.connect(UART_rx_fifo.analysis_export);
  endfunction : connect_phase

  //------------------------------------------------------------
  // Run phase
  //------------------------------------------------------------

  task scb::run_phase(uvm_phase phase);
  fork	
    predict_result(); 
  join
  endtask : run_phase

  task scb::predict_result();
    logic i2c_start,start_flag,r_start,i2c_byte; 
	logic [6:0] addr,addr1;
	logic rw,rw1;
	logic [7:0] pop;
	logic [7:0] write_data[];
	logic [7:0] read_data[];
	int write_cnt,read_cnt;
	logic write_state,read_state;
	int num_bytes,num_bytes_1;
    forever begin
      UART_tx_fifo.get(uart_tx_tr);
	  `uvm_info("SCB",$sformatf("uart_tx_tr=%0s",uart_tx_tr.sprint()),UVM_LOW)
	  case(uart_tx_tr.data)
	    8'h53: begin
		         i2c_start=1;
				 if(start_flag==1) begin
				   addr1= addr;
				   rw1 = rw;
				   r_start=1;
				   num_bytes_1=num_bytes;
				 end
				 start_flag=1;
		       end
	    8'h57: begin
				     `uvm_info(get_type_name(),$sformatf("writing to internal registers"),UVM_LOW)
		       end
	    8'h52: begin
				     `uvm_info(get_type_name(),$sformatf("reading to internal registers"),UVM_LOW)
		       end
        8'h50: begin
                 I2C_mon_fifo.get(i2c_mon_tr);
	        `uvm_info("SCB",$sformatf("i2c_mon_tr=%0s",i2c_mon_tr.sprint()),UVM_LOW)
				  if(r_start==1) begin
			        if(rw1==1) begin

			          if(addr1!=i2c_mon_tr.address)
			            `uvm_error("CMP_FAIL",$sformatf("received addr=%0h while i2c packet addr=%0h",addr1,i2c_mon_tr.address))
                      else 
			            `uvm_info("CMP_PASS",$sformatf("received addr and i2c packet addr matching which is %0h",addr1),UVM_LOW)

			          if(rw1!=i2c_mon_tr.R_W_mode)
			            `uvm_error("CMP_FAIL",$sformatf("received rw=%0d while i2c packet rw=%0d",rw1,i2c_mon_tr.R_W_mode))
                      else 
			            `uvm_info("CMP_PASS",$sformatf("received addr and i2c packet addr matching which is %0d",rw1),UVM_LOW)
			          for(int i=0;i<num_bytes_1;i++)begin
	                    UART_rx_fifo.get(uart_rx_tr);
			            pop= i2c_mon_tr.data_q.pop_front();
			             if(uart_rx_tr.data!=pop)
			               `uvm_error("CMP_FAIL",$sformatf("received data=%0h while i2c packet data=%0h",uart_rx_tr.data,pop))
                         else 
			               `uvm_info("CMP_PASS",$sformatf("received data and i2c packet data matching which is %0h",pop),UVM_LOW)
                         
			          end
                    end
			        else begin
			          if(addr1!=i2c_mon_tr.address)
			            `uvm_error("CMP_FAIL",$sformatf("received addr=%0h while i2c packet addr=%0h",addr1,i2c_mon_tr.address))
                      else 
			            `uvm_info("CMP_PASS",$sformatf("received addr and i2c packet addr matching which is %0h",addr1),UVM_LOW)
			       
			          if(rw1!=i2c_mon_tr.R_W_mode)
			            `uvm_error("CMP_FAIL",$sformatf("received rw=%0d while i2c packet rw=%0d",rw1,i2c_mon_tr.R_W_mode))
                      else 
			            `uvm_info("CMP_PASS",$sformatf("received addr and i2c packet addr matching which is %0d",rw1),UVM_LOW)

			          for(int i=0;i<num_bytes_1;i++)begin
			            pop= i2c_mon_tr.data_q.pop_front();
			             if(write_data[i]!=pop)
			               `uvm_error("CMP_FAIL",$sformatf("received data=%0h while i2c packet data=%0h",write_data[i],pop))
                         else 
			               `uvm_info("CMP_PASS",$sformatf("received data and i2c packet data matching which is %0h",pop),UVM_LOW)
                         
			          end
			        end
                  I2C_mon_fifo.get(i2c_mon_tr);
			      end

				 if(rw==1) begin
				   if(addr!=i2c_mon_tr.address)
				     `uvm_error("CMP_FAIL",$sformatf("received addr=%0h while i2c packet addr=%0h",addr,i2c_mon_tr.address))
                   else 
				     `uvm_info("CMP_PASS",$sformatf("received addr and i2c packet addr matching which is %0h",addr),UVM_LOW)
				   if(rw!=i2c_mon_tr.R_W_mode)
				     `uvm_error("CMP_FAIL",$sformatf("received rw=%0d while i2c packet rw=%0d",rw,i2c_mon_tr.R_W_mode))
                   else 
				     `uvm_info("CMP_PASS",$sformatf("received addr and i2c packet addr matching which is %0d",rw),UVM_LOW)
				   for(int i=0;i<num_bytes;i++)begin
	                 UART_rx_fifo.get(uart_rx_tr);
	                 `uvm_info("SCB",$sformatf("uart_tx_tr=%0s",uart_rx_tr.sprint()),UVM_LOW)
				     pop= i2c_mon_tr.data_q.pop_front();
				      if(uart_rx_tr.data!=pop)
				        `uvm_error("CMP_FAIL",$sformatf("received data=%0h while i2c packet data=%0h",uart_rx_tr.data,pop))
                      else 
				        `uvm_info("CMP_PASS",$sformatf("received data and i2c packet data matching which is %0h",pop),UVM_LOW)
                      
				   end
                 end
				 else begin
				   if(addr!=i2c_mon_tr.address)
				     `uvm_error("CMP_FAIL",$sformatf("received addr=%0h while i2c packet addr=%0h",addr,i2c_mon_tr.address))
                   else 
				     `uvm_info("CMP_PASS",$sformatf("received addr and i2c packet addr matching which is %0h",addr),UVM_LOW)
				
				   if(rw!=i2c_mon_tr.R_W_mode)
				     `uvm_error("CMP_FAIL",$sformatf("received rw=%0d while i2c packet rw=%0d",rw,i2c_mon_tr.R_W_mode))
                   else 
				     `uvm_info("CMP_PASS",$sformatf("received addr and i2c packet addr matching which is %0d",rw),UVM_LOW)

				   for(int i=0;i<num_bytes;i++)begin
				     pop= i2c_mon_tr.data_q.pop_front();
				      if(write_data[i]!=pop)
				        `uvm_error("CMP_FAIL",$sformatf("received data=%0h while i2c packet data=%0h",write_data[i],pop))
                      else 
				        `uvm_info("CMP_PASS",$sformatf("received data and i2c packet data matching which is %0h",pop),UVM_LOW)
                      
				   end
				 end
		           
		       end
	    default:begin
		          if(i2c_start==1) begin
				    addr = uart_tx_tr.data[7:1];
                    rw   = uart_tx_tr.data[0];
					i2c_start=0;
					i2c_byte=1;
				  end
				  else if(i2c_byte==1) begin
				    num_bytes= uart_tx_tr.data;
				    if(rw==0) begin
					  write_data= new[uart_tx_tr.data];
					  write_state=1;
					end
					else begin
					  read_data= new[uart_tx_tr.data];
					  read_state=1;
					end
                    i2c_byte=0;
				  end
				  else if(write_state==1) begin
				     write_data[write_cnt] = uart_tx_tr.data;
					 write_cnt++;
					 if(write_cnt==num_bytes)
					   write_state=0;
				  end
	         	end
	  endcase

	end
  endtask : predict_result
`endif

