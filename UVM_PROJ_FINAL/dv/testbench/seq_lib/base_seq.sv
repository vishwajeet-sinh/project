//-------------------------------------------------------------------
 class I2C_sl_sm_7_rx_seq extends uvm_sequence #(I2C_seq_item);

  //factory registration
  `uvm_object_utils(I2C_sl_sm_7_rx_seq)

  //default constructor override
  function new (string name = "I2C_sl_sm_7_rx_seq");
    super.new(name);
  endfunction : new

  //body task
  task body;
   I2C_seq_item req;
   req = I2C_seq_item::type_id::create("req");
   
   start_item(req);
   assert(req.randomize() with {sm_e == SM;
                                op_e == ADDR_7_BIT;
   		      				    no_of_data_byte == 2;});
   req.address  =  'h41; 

   finish_item(req);

  endtask : body

endclass : I2C_sl_sm_7_rx_seq


//-------------------------------------------------------------------
 class I2C_sl_sm_7_tx_seq extends uvm_sequence #(I2C_seq_item);

  //factory registration
  `uvm_object_utils(I2C_sl_sm_7_tx_seq)

  //default constructor override
  function new (string name = "I2C_sl_sm_7_tx_seq");
    super.new(name);
  endfunction : new

  //body task
  task body;
   I2C_seq_item req;
   req = I2C_seq_item::type_id::create("req");
   
   start_item(req);
   assert(req.randomize() with {sm_e == SM;
                                op_e == ADDR_7_BIT;
   		      				    no_of_data_byte == 2;});
   req.address  =  'h41; 

   finish_item(req);

  endtask : body

endclass : I2C_sl_sm_7_tx_seq


//uart sequences
class UART_write_seq extends uvm_sequence #(UART_seq_item);

  //factory registration
  `uvm_object_utils(UART_write_seq)

  //default constructor override
  function new (string name = "UART_write_seq");
    super.new(name);
  endfunction : new

  //body task
  task body;
    UART_seq_item req;
	bit [7:0] dat[];
	dat= new[6];
	dat = '{'h53,'h82,'h02, 'h55, 'h4E, 'h50};
	foreach(dat[i]) begin
	  req= UART_seq_item::type_id::create("req");
	  start_item(req);
	  assert(req.randomize with {req.data==dat[i];});
	  finish_item(req);
	end
  endtask : body

endclass : UART_write_seq

//uart sequences
class UART_read_seq extends uvm_sequence #(UART_seq_item);

  //factory registration
  `uvm_object_utils(UART_read_seq)

  //default constructor override
  function new (string name = "UART_read_seq");
    super.new(name);
  endfunction : new

  //body task
  task body;
    UART_seq_item req;
	bit [7:0] dat[];
	dat= new[6];
	dat = '{'h53,'h83,'h02,'h50};
	foreach(dat[i]) begin
	  req= UART_seq_item::type_id::create("req");
	  start_item(req);
	  assert(req.randomize with {req.data==dat[i];});
	  finish_item(req);
	end
  endtask : body

endclass : UART_read_seq
class UART_write_reg_seq extends uvm_sequence #(UART_seq_item);

  //factory registration
  `uvm_object_utils(UART_write_reg_seq)

  //default constructor override
  function new (string name = "UART_write_reg_seq");
    super.new(name);
  endfunction : new

  //body task
  task body;
    UART_seq_item req;
	bit [7:0] dat[];
	dat= new[6];
	dat = '{'h57,'h00,'h02, 'h01, 'hff, 'h50};
	foreach(dat[i]) begin
	  req= UART_seq_item::type_id::create("req");
	  start_item(req);
	  assert(req.randomize with {req.data==dat[i];});
	  finish_item(req);
	end
  endtask : body

endclass : UART_write_reg_seq

class UART_read_reg_seq extends uvm_sequence #(UART_seq_item);

  //factory registration
  `uvm_object_utils(UART_read_reg_seq)

  //default constructor override
  function new (string name = "UART_read_reg_seq");
    super.new(name);
  endfunction : new

  //body task
  task body;
    UART_seq_item req;
	bit [7:0] dat[];
	dat= new[4];
	dat = '{'h52,'h00,'h01,'h50};
	foreach(dat[i]) begin
	  req= UART_seq_item::type_id::create("req");
	  start_item(req);
	  assert(req.randomize with {req.data==dat[i];});
	  finish_item(req);
	end
  endtask : body

endclass : UART_read_reg_seq

class UART_read_after_write_seq extends uvm_sequence #(UART_seq_item);

  //factory registration
  `uvm_object_utils(UART_read_after_write_seq)

  //default constructor override
  function new (string name = "UART_read_after_write_seq");
    super.new(name);
  endfunction : new

  //body task
  task body;
    UART_seq_item req;
	bit [7:0] dat[];
	dat = '{'h53,'h82,'h02, 'h55, 'h4E,'h53,'h83,'h02,'h50};
	foreach(dat[i]) begin
	  req= UART_seq_item::type_id::create("req");
	  start_item(req);
	  assert(req.randomize with {req.data==dat[i];});
	  finish_item(req);
	end
  endtask : body

endclass : UART_read_after_write_seq

class UART_write_after_write_seq extends uvm_sequence #(UART_seq_item);

  //factory registration
  `uvm_object_utils(UART_write_after_write_seq)

  //default constructor override
  function new (string name = "UART_write_after_write_seq");
    super.new(name);
  endfunction : new

  //body task
  task body;
    UART_seq_item req;
	bit [7:0] dat[];
	dat = '{'h53,'h82,'h02, 'h55, 'h4E,'h53,'h82,'h02,'h66,'h44,'h50};
	foreach(dat[i]) begin
	  req= UART_seq_item::type_id::create("req");
	  start_item(req);
	  assert(req.randomize with {req.data==dat[i];});
	  finish_item(req);
	end
  endtask : body

endclass : UART_write_after_write_seq



