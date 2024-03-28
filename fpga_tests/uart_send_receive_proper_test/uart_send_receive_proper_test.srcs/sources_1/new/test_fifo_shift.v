`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.03.2024 16:59:57
// Design Name: 
// Module Name: test_fifo_shift
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module test_fifo_shift();
    // Simulation Inputs
    reg clk;
    reg rst;
    
    // Simulation Outputs
    reg rx_done_tick = 0;
    reg [7:0] rx_data_out = 8'h41; //8'b11000011;
    wire[9*8-1:0] rx_out;
    wire [7:0] read_data_out_last;
    
    
    reg write_batch_trigger = 0;
    // Instantiation of the module to be simulated
    fifo_shift #(
         .DATA_SIZE(8),
         .ADDR_SPACE(9)
      )
    dut(
      .clk(clk), 
      .reset(rst),      
      .write_to_fifo(rx_done_tick),
      .write_data_in(rx_data_out),
      .write_batch_to_fifo(write_batch_trigger),
      .write_batch_data_in(72'h41424344),
      .read_all_data_out(rx_out),
      .read_data_out_last(read_data_out_last)
    );
    
    // Stimuli
    initial begin
	   clk = 0; rst = 1; 
	   #10 clk = 0; #10 clk = 1;
	   #10 clk = 0; #10 clk = 1;
	   rst = 0;
	   
	   write_batch_trigger = 1;
       #10 clk = 0; #10 clk = 1;
       #10 clk = 0; #10 clk = 1;
       write_batch_trigger = 0;
	                    
	   #10 clk = 0; #10 clk = 1;
	                    
	   rx_done_tick = 1;
	   #10 clk = 0; #10 clk = 1;
       #10 clk = 0; #10 clk = 1;
       #10 clk = 0; #10 clk = 1;
       #10 clk = 0; #10 clk = 1;
       #10 clk = 0; #10 clk = 1;
       #10 clk = 0; #10 clk = 1;
       #10 clk = 0; #10 clk = 1;
       #10 clk = 0; #10 clk = 1;
       #10 clk = 0; #10 clk = 1;
	   
	   rst = 0; 
	   #10 clk = 0; #10 clk = 1;
	   #10 clk = 0; #10 clk = 1;
	   #10 clk = 0; #10 clk = 1;
	   #10 clk = 0; #10 clk = 1; 
       #10 clk = 0; #10 clk = 1;
       #10 clk = 0; #10 clk = 1;
       #10 clk = 0; #10 clk = 1;
       #10 clk = 0; #10 clk = 1; 
       #10 clk = 0; #10 clk = 1;
       #10 clk = 0; #10 clk = 1;
       #10 clk = 0; #10 clk = 1;
       #10 clk = 0; #10 clk = 1; 
    end
endmodule
