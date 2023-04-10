`include "../../rtl/BRG.sv"
`include "../../rtl/UART_RX.sv"
`include "../../rtl/fsm.sv"
`include "../../rtl/UART_TX.sv"

module top_tb(input bit clk,input bit rst,input rx,input rx_enable,output tx,inout i2c_sda,output wire i2c_scl);

wire [7:0] brg0;
wire [7:0] brg1;
wire uart_clk;

wire [7:0] rx_data;
wire rx_valid;

wire [7:0] tx_data;
wire tx_valid;
wire tx_done;

reg [7:0] data;

  // Instantiate Baud Rate Generator
  brg d1(
    .rst_n(rst), 
    .brg0(brg0), 
    .brg1(brg1), 
    .uart_clk(uart_clk)
  );

  // Instantiate UART Receiver
  uart_rx d2(
    .uart_clk(uart_clk),
    .rst_n(rst),
    .rx_enable(rx_enable),
    .rx(rx),
    .rx_data(rx_data),
    .rx_valid(rx_valid)
  );

  i2c_bus d3(
    .rx_data(rx_data),
    .rx_valid(rx_valid),
    .tx_data(tx_data),
    .tx_valid(tx_valid),
	  .tx_done(tx_done),
	  .clk(clk),
	  .rst(rst),
	  .i2c_sda(i2c_sda),
	  .i2c_scl(i2c_scl),
	  .brg0(brg0),
	  .brg1(brg1)
  );

  uart_tx d4(
    .uart_clk(uart_clk),
    .rst_n(rst),
    .tx_data(tx_data),
    .tx_valid(tx_valid),
	  .tx_done(tx_done),
    .tx(tx)
  );

endmodule : top_tb


