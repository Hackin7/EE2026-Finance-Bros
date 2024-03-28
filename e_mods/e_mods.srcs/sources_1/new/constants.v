`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.03.2024 19:54:44
// Design Name: 
// Module Name: constants
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


module constants();
    parameter HEIGHT = 64;
    parameter WIDTH = 96;

    // Color variables
    parameter RED = 16'b11111_000000_00000;
    parameter GREEN = 16'b00000_101010_00000;
    parameter BLUE = 16'b00000_000000_11111;
    parameter YELLOW = 16'b11111_111111_00000;
    parameter CYAN = 16'b00000_111111_11111;
    parameter MAGENTA = 16'b11111_000000_11111;
    parameter ORANGE = 16'b11111_011000_00000;
    parameter PURPLE = 16'b01111_000000_11111;
    parameter PINK = 16'b11111_010010_10111;
    parameter BROWN = 16'b01111_010100_00000;
    parameter WHITE = 16'b11111_111111_11111;
    parameter GRAY = 16'b01010_010101_01010;
    parameter LIGHT_BLUE = 16'b01111_011111_11111;
    parameter LIGHT_GREEN = 16'b01000_111111_01000;
    parameter LIGHT_YELLOW = 16'b11111_111111_01000;
    parameter LIGHT_PURPLE = 16'b10111_010000_10111;
    parameter LIGHT_GRAY = 16'b10101_101010_10101;
    parameter DARK_GRAY = 16'b00101_001010_00101;
    parameter BLACK = 16'd0;
    
    parameter charA = {5'b01110,
                        5'b10001,
                        5'b11111,
                        5'b10001,
                        5'b10001};
    
    parameter charSpace = {5'b00000, 
                            5'b00000,
                            5'b00000,
                            5'b00000,
                            5'b00000};

    parameter charB = {5'b11110,
                        5'b10001,
                        5'b11110,
                        5'b10001,
                        5'b11110};

    parameter charC  = {5'b01110,
            5'b10001,
            5'b10000,
            5'b10001,
            5'b01110};
            
    parameter charD = {5'b11110,
            5'b10001,
            5'b10001,
            5'b10001,
            5'b11110};

    parameter charE = {5'b11111,
            5'b10000,
            5'b11110,
            5'b10000,
            5'b11111};

    parameter charF = {5'b11111,
            5'b10000,
            5'b11110,
            5'b10000,
            5'b10000};

    parameter charG = {5'b01111,
            5'b10000,
            5'b10011,
            5'b10001,
            5'b01110};

    parameter charH = {5'b10001,
            5'b10001,
            5'b11111,
            5'b10001,
            5'b10001};

    parameter charI = {5'b11111,
            5'b00100,
            5'b00100,
            5'b00100,
            5'b11111};

    parameter charJ = {5'b00111,
            5'b00001,
            5'b00001,
            5'b10001,
            5'b01110};

    parameter charK = {5'b10001,
            5'b10010,
            5'b11100,
            5'b10010,
            5'b10001};

    parameter charL = {5'b10000,
            5'b10000,
            5'b10000,
            5'b10000,
            5'b11111};

    parameter charM = {5'b10001,
            5'b11011,
            5'b10101,
            5'b10001,
            5'b10001};

    parameter charN = {5'b10001,
            5'b11001,
            5'b10101,
            5'b10011,
            5'b10001};

    parameter charO = {5'b01110,
            5'b10001,
            5'b10001,
            5'b10001,
            5'b01110};

    parameter charP = {5'b11110,
            5'b10001,
            5'b11110,
            5'b10000,
            5'b10000};

    parameter charQ = {5'b01110,
            5'b10001,
            5'b10001,
            5'b10011,
            5'b01111};

    parameter charR = {5'b11110,
            5'b10001,
            5'b11110,
            5'b10010,
            5'b10001};

    parameter charS = {5'b01110,
            5'b10000,
            5'b01110,
            5'b00001,
            5'b11110};

    parameter charT = {5'b11111,
            5'b00100,
            5'b00100,
            5'b00100,
            5'b00100};

    parameter charU = {5'b10001,
            5'b10001,
            5'b10001,
            5'b10001,
            5'b01110};

    parameter charV = {5'b10001,
            5'b10001,
            5'b01010,
            5'b01010,
            5'b00100};

    parameter charW  = {5'b10001,
            5'b10001,
            5'b10101,
            5'b11011,
            5'b10001};

    parameter charX = {5'b10001,
            5'b01010,
            5'b00100,
            5'b01010,
            5'b10001};

    parameter charY = {5'b10001,
            5'b01010,
            5'b00100,
            5'b00100,
            5'b00100};

    parameter charZ = {5'b11111,
            5'b00010,
            5'b00100,
            5'b01000,
            5'b11111};
    
    parameter num0 = 7'b1000000;
    parameter num1 = 7'b1111001;
    parameter num2 = 7'b0100100;
    parameter num3 = 7'b0110000;
    parameter num4 = 7'b0011001;
    parameter num5 = 7'b0010010;
    parameter num6 = 7'b0000010;
    parameter num7 = 7'b1111000;
    parameter num8 = 7'b0000000;
    parameter num9 = 7'b0010000;

endmodule