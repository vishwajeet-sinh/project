
module uart_rx(

  input uart_clk,
  input rst_n,
  input rx_enable,
  input rx,
  output reg [7:0] rx_data,
  output reg rx_valid
  );
  
  reg [7:0] uart_data;
  
  // UART Receiver
  task func_rx();      
      uart_data = 0; 				     // Initialize input data to 0
      rx_data = 0;
      @(posedge uart_clk);
      @(negedge uart_clk);				 // Delay to center of signal
      if (rx == 0) begin				 // Sample Start bit
        $display("Start Bit Detected .. %0t/ %0m/ L24", $time);
        for (int i = 0; i<8; i+=1) begin // UART receives LSB bit first
          @(negedge uart_clk); 		     // Delay to center of signal
          uart_data[i] = rx; 	         // Sample Data bit
        end
        @(negedge uart_clk);			 // Delay to center of signal
        if (rx == 1) begin		         // Sample Stop bit
          rx_data = uart_data;		   	 // Output received data to FSM
          $display("Data Received: %0h .. %0t/ %0m/ L37", rx_data, $time);
          rx_valid = 1;					 // Set Rx Data Valid Flag
          @(posedge uart_clk);
          rx_valid = 0; end				 // Disable Rx Data Valid Flag
        else $display("Did not receive Stop bit .. %0t/ %0m/ L39", $time);
      end
      else $display("Did not receive Start bit .. %0t/ %0m/ L42", $time);
  endtask : func_rx
  
  // Always Block
  always @(*) begin
    if (rx_enable) begin    // Rx block must be enabled
	  if (rst_n == 0) begin // When Reset, set stored data to 0
	    rx_data = 0; end
	  else begin
	    func_rx();			// Run function
	  end
	end
  end
	    
endmodule : uart_rx     
