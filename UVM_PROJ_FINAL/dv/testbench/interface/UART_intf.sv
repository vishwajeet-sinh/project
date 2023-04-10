//====================================================================================
//                                                                                   
//  Title         : UART Interface                                                 
//  Description   : This file contains Interface definition for UART.      
//
//====================================================================================

`ifndef UART_INTERFACE__IF
`define UART_INTERFACE__IF

interface uart_if(input reset);

  logic tx;
  logic rx;
  logic rx_enable;
endinterface
`endif









