`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.01.2024 22:55:44
// Design Name: 
// Module Name: my_control_module_simulation
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


module test_trade_parser();
    // Simulation Inputs
    reg A;
    reg B;
    
    // Simulation Outputs
    wire [7:0] type; // Not working properly
    wire [7:0] account_id;
    wire [7:0] stock_id;
    wire [7:0] qty;
    wire [7:0] price;

    // Instantiation of the module to be simulated
    trade_packet_parser dut(
        {"[", ~8'b0, 8'b1, 8'b1, 8'b1, 8'b1, 8'b0, "]"},
         type, account_id, stock_id, qty, price
    );
    
    // Stimuli
    initial begin
        A = 0; B = 0; #10;
        A = 0; B = 1; #10;
        A = 1; B = 0; #10;
        A = 1; B = 1; #10;
    end
endmodule