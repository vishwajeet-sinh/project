module uart_tx(

  input uart_clk,
  input rst_n,
  input [7:0] tx_data,
  input tx_valid,
  output reg tx_done,
  output reg tx
  );
  
  initial begin
   tx_done=0;
  end
  // UART Transceiver
  task func_tx();
    @(posedge uart_clk);
    tx = 1;						   // Initiate output data to 1
    @(posedge uart_clk);
    tx = 0; 					   // Send Start bit
    $display("Start Bit: %0b .. %0t/ %0m/ L108", tx, $time);
    for (int i=0; i<8; i+=1) begin // UART transmits LSB bit first
      @(posedge uart_clk);			
      tx = tx_data[i];			   // Output received data from FSM
    end
    @(posedge uart_clk);
    tx = 1; 					   // Send Stop bit
    $display("Stop Bit: %0b .. %0t/ %0m/ L117", tx, $time);
	  tx_done=1;
    @(posedge uart_clk);
	  tx_done=0;
  endtask : func_tx

  // Always Block
  always @(*) begin
    if (rst_n == 0) 
    begin
      tx = 1; 
    end            // When Reset, set output data to 0
    else if (tx_valid) begin // Tx block must be enabled
      func_tx();             // Run function
    end
  end
endmodule : uart_tx
