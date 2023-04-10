class UART_monitor extends uvm_monitor;

  `uvm_component_utils(UART_monitor)
  
  virtual uart_if vif;
  UART_agent_config w_cfg;
  real bit_time;
   
  uvm_analysis_port #(UART_seq_item) tx_monitor_port;
  uvm_analysis_port #(UART_seq_item) rx_monitor_port;


  //-----------------------------------------------------------------------------------------------
  //Defining external tasks and functions
  //-----------------------------------------------------------------------------------------------
	extern function new(string name = "UART_monitor", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase (uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task collect_rx_data();
	extern task collect_tx_data();

endclass

 function UART_monitor :: new(string name ="UART_monitor",uvm_component parent);
 	super.new(name, parent);
 	tx_monitor_port = new("tx_monitor_port", this);
 	rx_monitor_port = new("rx_monitor_port", this);
 endfunction:new
 
 
 function void UART_monitor::build_phase(uvm_phase phase);
 	super.build_phase(phase);
 	if(!uvm_config_db #(UART_agent_config)::get(this,"","UART_agent_config",w_cfg))
 	`uvm_fatal("CONFIG","Cannot get() w_cfg from uvm_config_db. Have you set() it?")
 endfunction:build_phase
 
 
 function void UART_monitor::connect_phase(uvm_phase phase);
	if(!uvm_config_db#(virtual uart_if)::get(this,"","vif_0",vif))
	`uvm_fatal("inteface","did not get uart interface");
 endfunction:connect_phase
 
 
 task UART_monitor::run_phase(uvm_phase phase);
 fork
   collect_rx_data();
   collect_tx_data();
 join
 endtask
 
 
 task UART_monitor::collect_rx_data();
@(negedge vif.reset);
#(bit_time/2);
 forever begin
 	UART_seq_item data_sent;
  	bit_time = (1/(w_cfg.baud_rate)*1e9);
 	data_sent=UART_seq_item::type_id::create("data_sent");
	while(vif.rx!=0)
      #(bit_time/2);
    for(int i=0;i<8;i++)
    begin
      #(bit_time);
      data_sent.data[i]=vif.rx;
    end
	#(bit_time);
	while(vif.rx!=1)
      #(bit_time);
    rx_monitor_port.write(data_sent);
 end
 endtask:collect_rx_data 

task UART_monitor::collect_tx_data();
wait(vif.tx==1);
#(bit_time/2);
forever begin
 	UART_seq_item data_sent;
  	bit_time = (1/(w_cfg.baud_rate)*1e9);
 	data_sent=UART_seq_item::type_id::create("data_sent");

	while(vif.tx!=0)
      #(bit_time);
    for(int i=0;i<8;i++)
    begin
      #(bit_time);
      data_sent.data[i]=vif.tx;
    end
	#(bit_time);
	while(vif.tx!=1)
      #(bit_time/2);
    tx_monitor_port.write(data_sent);
end
 endtask:collect_tx_data 

