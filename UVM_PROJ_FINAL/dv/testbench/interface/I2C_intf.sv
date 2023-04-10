//====================================================================================
//                                                                                   
//  Title         : I2C Interface                                                 
//  Description   : This file contains Interface definition for I2C. I2C interface      
//                  also contains Assertions for checking and reporting protocol 
//                  violation.
//
//====================================================================================

`ifndef I2C_INTERFACE__IF
`define I2C_INTERFACE__IF

  interface I2C_intf(input clk, inout wire scl,sda);
  
    //----------------------------------------------------------
    // Data Members
    //----------------------------------------------------------
  
    int count;   //variable to count clock cycles for UFM NACK check assertion
    bit r_start; //variable to identify start condition as repeated start
  
    enum {FREE,BUSY} bus_stat;
    enum {SM,FM} speed_mode;
  
    //-------------------------------------------------------------------------
    // Description     : This is the assertion for bus free condition check. 
    //                  whenever bus is free scl and sda both should be high. 
  
    always @(sda)
      begin
        if(scl==1)
          begin
            if(sda==0) //sda changed from 1 to 0 i.e. START
              begin
                if(bus_stat==BUSY) //check for repeated start
                  r_start=1;
                else
                  r_start=0;
                bus_stat = BUSY;
              end
            else           //sda changed from 0 to 1 i.e. STOP
              begin
                bus_stat = FREE;
              end
          end
      end 
  
endinterface : I2C_intf

`endif

