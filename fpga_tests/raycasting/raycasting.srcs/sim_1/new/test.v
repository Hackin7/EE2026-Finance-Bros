`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.03.2024 00:06:33
// Design Name: 
// Module Name: test
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


module test();
    
    reg [15:0] sin_array [15:0];
    reg a;
    initial begin
        //$display("Loading rom.");
        $readmemh("sin.mem", sin_array);
        #10 a = 1;
        #10 a = 0;
    end
    
endmodule
