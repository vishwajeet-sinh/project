module brg(

  input rst_n,
  input [7:0] brg0,
  input [7:0] brg1,
  output reg uart_clk
  );

  real sys_clk = 1e9;
  real freq = 7.3728e6;
  real baud_rate, baud_period, baud_delay;
  reg [7:0] baud_reg0;
  reg [7:0] baud_reg1;

  always @(*) begin
    if (rst_n == 0) begin
      baud_rate = freq/(16+{8'h02, 8'hF0});
	  baud_period = 1/baud_rate;
	  baud_delay  = baud_period * sys_clk;
    end
	baud_reg0 = brg0;
	if (brg1 != baud_reg1) begin
      baud_reg1 = brg1;
      baud_rate = freq/(16+{baud_reg1, baud_reg0});
	  baud_period = 1/baud_rate;
	  baud_delay  = baud_period * sys_clk;
   end
  end

  initial begin
    baud_reg0 = 0;
    baud_reg1 = 0;
    forever begin
      uart_clk = 0;
      #(baud_delay/2);
      uart_clk = 1;
      #(baud_delay/2);
    end
  end
      
endmodule : brg	
