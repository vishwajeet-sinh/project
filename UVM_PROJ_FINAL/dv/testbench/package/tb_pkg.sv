package tb_pkg;
`include "uvm_macros.svh"
import uvm_pkg::*;
  `include "../testbench/sequence_item/i2c_seq_item.sv"
  `include "../testbench/sequence_item/uart_seq_item.sv"
  `include "../testbench/config/I2C_agent_config.sv"
  `include "../testbench/config/UART_agent_config.sv"
  `include "../testbench/config/env_config.sv"
  `include "../testbench/agent/I2C_driver.sv"
  `include "../testbench/agent/I2C_monitor.sv"
  `include "../testbench/agent/I2C_agent.sv"
  `include "../testbench/agent/UART_driver.sv"
  `include "../testbench/agent/UART_monitor.sv"
  `include "../testbench/agent/UART_agent.sv"
  `include "../testbench/scoreboard/scoreboard.sv"
  `include "../testbench/env/env.sv"
  `include "../testbench/seq_lib/base_seq.sv"
endpackage
