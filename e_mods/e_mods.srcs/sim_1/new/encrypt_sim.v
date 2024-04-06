`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.04.2024 21:39:50
// Design Name: 
// Module Name: encrypt_sim
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


module encrypt_sim();
    wire [63:0] data_in = 64'h123456ABCD132536;
    wire [7:0] account_id = 8'b1001_1000;
    reg [63:0] data_out;
    
    encryption encryptor(data_in, account_id, data_out);
endmodule
