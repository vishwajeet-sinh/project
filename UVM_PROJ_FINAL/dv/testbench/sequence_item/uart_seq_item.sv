//===================================================================================
//                                                            
//  Title         : UART Sequence Item Class                          
//  Description   : This is Sequence item Class for UART VIP      
//                                                           
//===================================================================================


`ifndef UART_SEQ_ITEM
`define UART_SEQ_ITEM

class UART_seq_item extends uvm_sequence_item;
	
	
  //-------------------------------------------------------
  // Data Memebers
  //-------------------------------------------------------
  rand bit [7:0] data;
  
  //-------------------------------------------------------
  // Factory Registeration
  //-------------------------------------------------------
  `uvm_object_utils_begin(UART_seq_item)
	`uvm_field_int(data,UVM_ALL_ON)
  `uvm_object_utils_end


  //-------------------------------------------------------
  // default constructor override
  //-------------------------------------------------------

  function new(string name = "UART_seq_item");
  	super.new(name);
  endfunction
  
  function string convert2string();
  	return($sformatf("data=%0p\n",data));
  endfunction

endclass: UART_seq_item

`endif



    

  


