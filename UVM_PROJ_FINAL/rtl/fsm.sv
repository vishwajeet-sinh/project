module i2c_bus(

  // Signals from UART to I2C
  input [7:0] rx_data,
  input  reg  rx_valid,
  
  // Signals from I2C to UART
  output reg [7:0] tx_data,
  output reg tx_valid,
  input tx_done,

  //Signals of I2C
  input wire clk,
  input wire rst,
  inout i2c_sda,
  output wire i2c_scl,
  
  //Internal Register Signals
  output reg [7:0] brg0,
  output reg [7:0] brg1
  );

  
  //signals for i2c bus
  reg start;
  reg [7:1] trgt_addr,trgt_addr_1;
  reg r_o_w,r_o_w_1;
  reg [7:0] num_bytes;
  reg stop;
  
  // Internal Signals
  logic [7:0] uart_bus_in[$];  // Queue for input data from UART and I2C
  logic [7:0] i2c_bus_out[],i2c_bus_out_1[]; 
  logic [7:0] pop,pop_1;      // Popping bytes from queue
  logic       start_sig;	  // I2C start signals
  logic       r_reg;		 
  logic       w_reg;
  logic 	  read_state;	  // Read Flag
  logic 	  write_state;	  // Write Flag
  logic       byte_sig;	      // Number of Bytes Flag
  int		  count;		  // Count Signal
  int         write_count;
  logic       read_done,read_done_1; 	  // Read Done Signal
  logic       write_done,write_done_1;	  // Write Done Signal
  logic 	  wait_for_i2c;	  // Wait for I2C Flag
  logic 	  enable;
  logic [6:0] addr,addr1;
  bit r_start;
  logic       rw,rw1;
  logic [7:0] data_write_i2c_bus[],data_write_i2c_bus1[];
  logic [7:0] data_read_i2c_bus[$]; 

  // Internal Register Signals
  logic		  r_reg_sig;
  logic		  w_reg_sig;
  logic [7:0] reg_addr;
  logic 	  reg_data_sig;
  logic [7:0] reg_data;

  //I2C internal variables

	localparam IDLE = 0;
	localparam START = 1;
	localparam ADDRESS = 2;
	localparam READ_ACK = 3;
	localparam WRITE_DATA = 4;
	localparam WRITE_ACK = 5;
	localparam READ_DATA = 6;
	localparam READ_ACK2 = 7;
	localparam STOP = 8; 	
	localparam DIVIDE_BY = 4;

	reg [7:0] state;
	reg [7:0] saved_addr;
	reg [7:0] saved_data;
	reg [7:0] counter;
	reg [7:0] counter2 = 0;
	reg write_enable;
	reg sda_out;
	reg i2c_scl_enable = 0;
	reg i2c_clk = 1;
    int write_cnt,read_cnt;
    reg [7:0] data_out;

	assign i2c_scl = (i2c_scl_enable == 0 ) ? 1 : i2c_clk;
	assign i2c_sda = (write_enable == 1) ? sda_out : 'bz;

	//I2C logic

	always @(posedge clk) begin
		if (counter2 == (DIVIDE_BY/2) - 1) begin
			i2c_clk <= ~i2c_clk;
			counter2 <= 0;
		end
		else counter2 <= counter2 + 1;
	end 
	
	always @(negedge i2c_clk, negedge rst) begin
		if(rst == 0) begin
			i2c_scl_enable <= 0;
		end else begin
			if ((state == IDLE) || (state == START) || (state == STOP)) begin
				i2c_scl_enable <= 0;
			end else begin
				i2c_scl_enable <= 1;
			end
		end
	
	end
	always @(posedge i2c_clk, negedge rst) begin
		if(rst == 0) begin
			state <= IDLE;
		end		
		else begin
			case(state)
			
				IDLE: begin
					if (enable) begin
						state <= START;
						saved_addr <= {addr, rw};
						saved_data <= data_write_i2c_bus[0];
						write_cnt<=0;
					end
					else state <= IDLE;
				end

				START: begin
					counter <= 7;
					state <= ADDRESS;
				end

				ADDRESS: begin
					if (counter == 0) begin 
						state <= READ_ACK;
					end else counter <= counter - 1;
				end

				READ_ACK: begin
					if (i2c_sda == 0) begin
						counter <= 7;
						if(saved_addr[0] == 0 && rw==0) state <= WRITE_DATA;
						else if(rw==1) 
						       	state <= READ_DATA;
					end else 
						state <= STOP;
				end

				WRITE_DATA: begin
					if(counter == 0) begin
					 write_cnt++;
					 if(write_cnt!=data_write_i2c_bus.size()) begin
					    saved_data<= data_write_i2c_bus[write_cnt];
					 end
					    
						  state <= READ_ACK2;
					end else counter <= counter - 1;
				end
				
				READ_ACK2: begin
					if (i2c_sda == 0 && write_cnt!=data_write_i2c_bus.size())  begin state <= WRITE_DATA; counter<=7; end
					else if(r_start==1) begin state<= IDLE; r_start<=0; end
					else state <= STOP;
				end
				
				READ_DATA: begin
					data_out[counter] <= i2c_sda;
					if (counter == 0) begin state <= WRITE_ACK;  end
					else counter <= counter - 1;
				end
				
				WRITE_ACK: begin
					if(i2c_sda == 0 && read_cnt!= data_read_i2c_bus.size()) begin 
					  data_read_i2c_bus.push_back(data_out); 
				      
					  if(read_cnt == data_read_i2c_bus.size()) begin
					    wait_for_i2c<=1;
					    state<=STOP;
					  end
					  else begin
					    state <= READ_DATA; 
					    counter<=7; 
					  
					  end
					end
					else state <= STOP;
				end

				STOP: begin
					if(sda_out==1)begin 
					   state <= IDLE;
					   enable<=0;
					end
				end
			endcase
		end
	end
	
	always @(negedge i2c_clk, negedge rst) begin
		if(rst == 0) begin
			write_enable <= 1;
			sda_out <= 1;
		end 
		
		else begin
			case(state)
				
				START: begin
					write_enable <= 1;
					sda_out <= 0;
				end
				
				ADDRESS: begin
					sda_out <= saved_addr[counter];
				end
				
				READ_ACK: begin
					write_enable <= 0;

				end
			    READ_ACK2: begin
					write_enable <= 0;

				end
				WRITE_DATA: begin 
					write_enable <= 1;
					sda_out <= saved_data[counter];
				end
				
				WRITE_ACK: begin
					write_enable <= 1;
					if(data_read_i2c_bus.size() < read_cnt)
					  sda_out <= 0;
					else
					  sda_out <= 1;
				end
				
				READ_DATA: begin
					write_enable <= 0;				
				end
				
				STOP: begin
				  	write_enable <= 1;
					if(sda_out==1) 
					   sda_out<=0;
					else begin
					  sda_out <= 1;
					end
				end
			endcase
		end
	  end

  task read_reg();
    while(data_read_i2c_bus.size()!=0) begin
          pop_1 = data_read_i2c_bus.pop_front();
          tx_data = pop_1;
          tx_valid = 1;
	      wait(tx_done==1);
		  tx_valid=0;
		  wait(tx_done==0);
	    end
  endtask : read_reg

  task internal_regs();
      case(reg_addr)
        8'h00   : begin 
					if (w_reg == 1) begin brg0 = reg_data; $display("BRGO Value: %0h\n", brg0); w_reg_sig = 1; end
					else if (r_reg == 1) data_read_i2c_bus.push_back(brg0); end
        8'h01   : begin
					if (w_reg == 1) begin brg1 = reg_data; $display("BRG1 Value: %0h\n", brg1); w_reg_sig = 1; end
					else if (r_reg == 1) data_read_i2c_bus.push_back(brg1); end			
        8'h02   : $display("GPIO not supported");
        8'h03   : $display("GPIO not supported");
        8'h04   : $display("GPIO not supported");
        8'h05   : $display("Register Reserved");
        8'h06   : $display("This will be for I2CAdr");
        8'h07   : $display("This will be for I2CClkL");
        8'h08   : $display("This will be for I2CClkH");
        8'h09   : $display("This will be for I2CCTO");
        8'h0A   : $display("This will be for I2CStat");
        default : $display("ERROR: NO SUCH REGISTER");
      endcase
    //w_reg_sig = 1; // move this into if statement
  endtask : internal_regs

  task uart_r_done();
    $display("Data for I2C is Ready (Read)");
	fork
	  begin
        wait(wait_for_i2c==1); // Set waiting for I2C flag high
	    while(data_read_i2c_bus.size()!=0) begin
          pop_1 = data_read_i2c_bus.pop_front();
          tx_data = pop_1;
          tx_valid = 1;
	      wait(tx_done==1);
		  tx_valid=0;
		  wait(tx_done==0);
	    end
	  end
	join_none
  endtask : uart_r_done 
  
  initial begin
    start_sig = 0;
    stop  = 0;
    r_reg_sig = 0;
    r_reg = 0;
    w_reg_sig = 0;
    w_reg = 0;
    reg_data_sig = 0;
    byte_sig = 0;
    count = 0;
    read_done = 0;
    read_done_1 = 0;
    write_done = 0;
    write_done_1 = 0;
    wait_for_i2c = 0;
    tx_valid = 0;

    forever begin
      wait(uart_bus_in.size() > 0);
        pop = uart_bus_in.pop_front();
        case(pop)
          8'h53   : begin // I2C Bus Start (ASCII Command: S)
					  start_sig = 1;
					  if(start==1) begin
					    trgt_addr_1= trgt_addr;
					    r_o_w_1=r_o_w;
						r_start=1;
					    if (read_done == 1) begin
					      read_done_1 = 1;
						end
					    else if (write_done == 1) begin
					      write_done_1 = 1;
						  write_count=0;
						  i2c_bus_out_1=i2c_bus_out;
					    end
					  end
					  start = 1;
					end 
          8'h50   : begin // I2C Bus Stop (ASCII Command: P)
					  stop = 1;
					  if (r_reg == 1) begin
					    r_reg_sig = 0;
					    r_reg = 0;
					    read_reg();
					  end
					  //for writing to register
					  if (reg_data_sig == 1) begin
					    reg_data_sig = 0;
					    internal_regs();
					  end
					  w_reg = 0;
                      if(r_start==1) begin
                         addr=trgt_addr_1;
					     rw=r_o_w_1;
					     if (read_done_1 == 1) begin
					       read_done_1 = 0;
					       uart_r_done(); 
					       enable=1;end
					     else if (write_done_1 == 1) begin
					       write_done_1 = 0;
					       data_write_i2c_bus=i2c_bus_out_1;
					       enable=1;
					     end
					  end
					  wait(r_start==0);
					  addr=trgt_addr;
					  rw=r_o_w;
					  if (read_done == 1) begin
					    read_done = 0;
					    uart_r_done(); 
						enable=1;end
					  else if (write_done == 1) begin
					    write_done = 0;
						data_write_i2c_bus=i2c_bus_out;
					    enable=1;
					  end
					  // Do we need delay?
					  stop = 0;
					end
          8'h52   : begin // Read Internal Registers (ASCII Command: R)
					  r_reg_sig = 1;
					  r_reg = 1;
					  $display("Read Internal Registers\n");
					end
          8'h57   : begin // Write to Internal Registers (ASCII Command: W)
					  w_reg_sig = 1;
					  w_reg = 1;
					  $display("Write to Internal Registers\n");
					end
          default : begin
					  if (start_sig == 1) begin 
						trgt_addr = pop[7:1]; // Decode Target Address
						r_o_w = pop[0]; 	  // Read : 1 and Write : 0
						start_sig = 0;
						byte_sig = 1;
					  end     
					  else if (byte_sig == 1) begin
						num_bytes = pop;
						$display("Number of Bytes: %0h", num_bytes);
						i2c_bus_out = new[num_bytes]; // Create indexes
						count = num_bytes; 			  // Keep count of instances in the array
						byte_sig = 0;
						if (r_o_w == 0) begin 		   // Write state
						  write_state = 1; end
						else if (r_o_w == 1) begin    // Read state
						  read_done = 1; read_cnt=num_bytes; end
					  end
					  else if (write_state == 1) begin
					    i2c_bus_out[write_count] = pop;
						write_count++;
					    $display("Written Data: %0h", pop);
					    count -= 1;
					    if (count == 0) begin
					      write_state = 0; 
					      write_done = 1;
						end
					  end
					  else if (r_reg_sig == 1) begin
					    reg_addr = pop;
					    $display("Register Address: %0h\n", reg_addr);
					    internal_regs();
					  end
					  else if (w_reg_sig == 1) begin
					    reg_addr = pop;
					    $display("Register Address: %0h\n", reg_addr);
					    w_reg_sig = 0;
					    reg_data_sig = 1;
					  end
					  else if (reg_data_sig == 1) begin
					    reg_data = pop;
						if(reg_addr!='h1) begin
					      reg_data_sig = 0;
					      internal_regs();
						end
					  end
					  else begin
					      $display("Data for UART is Ready"); 
					  end
					end
		endcase
	end
  end

 always@(rx_valid) begin
   if(rx_valid) begin
     uart_bus_in.push_back(rx_data);
   end
 end

endmodule : i2c_bus
