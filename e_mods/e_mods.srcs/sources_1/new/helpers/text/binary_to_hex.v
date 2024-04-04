`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.04.2024 11:14:31
// Design Name: 
// Module Name: binary_to_hex
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


module binary_to_hex(
    input [47:0] display_num,
    output [8*12-1:0] string);
    
    wire [3:0] digit1 = display_num[3:0];
    wire [3:0] digit2 = display_num[7:4];
    wire [3:0] digit3 = display_num[11:8];
    wire [3:0] digit4 = display_num[15:12];
    wire [3:0] digit5 = display_num[19:16];
    wire [3:0] digit6 = display_num[23:20];
    wire [3:0] digit7 = display_num[27:24];
    wire [3:0] digit8 = display_num[31:28];
    wire [3:0] digit9 = display_num[35:32];
    wire [3:0] digit10 = display_num[39:36];
    wire [3:0] digit11 = display_num[43:40];
    wire [3:0] digit12 = display_num[47:44];
    
    function [7:0] digitToChar(input [3:0] digit);
        begin
            if (digit == 0) digitToChar = "0";
            else if (digit == 1) digitToChar = "1";
            else if (digit == 2) digitToChar = "2";
            else if (digit == 3) digitToChar = "3";
            else if (digit == 4) digitToChar = "4";
            else if (digit == 5) digitToChar = "5";
            else if (digit == 6) digitToChar = "6";
            else if (digit == 7) digitToChar = "7";
            else if (digit == 8) digitToChar = "8";
            else if (digit == 9) digitToChar = "9";
            else if (digit == 10) digitToChar = "A";
            else if (digit == 11) digitToChar = "B";
            else if (digit == 12) digitToChar = "C";
            else if (digit == 13) digitToChar = "D";
            else if (digit == 14) digitToChar = "E";
            else if (digit == 15) digitToChar = "F";
            else digitToChar = " ";
        end
        endfunction
        
        assign string = {
            digitToChar(digit12), 
            digitToChar(digit11), 
            digitToChar(digit10), 
            digitToChar(digit9),
            digitToChar(digit8), 
            digitToChar(digit7), 
            digitToChar(digit6), 
            digitToChar(digit5),
            digitToChar(digit4), 
            digitToChar(digit3), 
            digitToChar(digit2), 
            digitToChar(digit1)
        };
endmodule
