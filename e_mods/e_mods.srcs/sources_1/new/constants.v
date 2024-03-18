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
    parameter COLOR_RED = 16'b11111_000000_00000;
    parameter COLOR_GREEN = 16'b00000_101010_00000;
    parameter COLOR_BLUE = 16'b00000_000000_11111;
    parameter COLOR_YELLOW = 16'b11111_111111_00000;
    parameter COLOR_CYAN = 16'b00000_111111_11111;
    parameter COLOR_MAGENTA = 16'b11111_000000_11111;
    parameter COLOR_ORANGE = 16'b11111_011000_00000;
    parameter COLOR_PURPLE = 16'b01111_000000_11111;
    parameter COLOR_PINK = 16'b11111_010010_10111;
    parameter COLOR_BROWN = 16'b01111_010100_00000;
    parameter COLOR_WHITE = 16'b11111_111111_11111;
    parameter COLOR_GRAY = 16'b01010_010101_01010;
    parameter COLOR_LIGHT_BLUE = 16'b01111_011111_11111;
    parameter COLOR_LIGHT_GREEN = 16'b01000_111111_01000;
    parameter COLOR_LIGHT_YELLOW = 16'b11111_111111_01000;
    parameter COLOR_LIGHT_PURPLE = 16'b10111_010000_10111;
    parameter COLOR_LIGHT_GRAY = 16'b10101_101010_10101;
    parameter COLOR_DARK_GRAY = 16'b00101_001010_00101;
    parameter COLOR_BLACK = 16'd0;

    function [24:0] is_letter(input [7:0] char_code);
        reg [24:0] char_pattern;
        begin
            case (char_code)
                32: begin // 'space'
                    char_pattern = {5'b00000, 
                                    5'b00000,
                                    5'b00000,
                                    5'b00000,
                                    5'b00000};
                end            
                65: begin // 'A'
                    char_pattern = {5'b01110,
                                    5'b10001,
                                    5'b11111,
                                    5'b10001,
                                    5'b10001};
                end
                66: begin // 'B'
                    char_pattern = {5'b11110,
                                    5'b10001,
                                    5'b11110,
                                    5'b10001,
                                    5'b11110};
                end
                67: begin // 'C'
                    char_pattern = {5'b01110,
                                    5'b10001,
                                    5'b10000,
                                    5'b10001,
                                    5'b01110};
                end
                68: begin // 'D'
                    char_pattern = {5'b11110,
                                    5'b10001,
                                    5'b10001,
                                    5'b10001,
                                    5'b11110};
                end
                69: begin // 'E'
                    char_pattern = {5'b11111,
                                    5'b10000,
                                    5'b11110,
                                    5'b10000,
                                    5'b11111};
                end
                70: begin // 'F'
                    char_pattern = {5'b11111,
                                    5'b10000,
                                    5'b11110,
                                    5'b10000,
                                    5'b10000};
                end
                71: begin // 'G'
                    char_pattern = {5'b01111,
                                    5'b10000,
                                    5'b10011,
                                    5'b10001,
                                    5'b01110};
                end
                72: begin // 'H'
                    char_pattern = {5'b10001,
                                    5'b10001,
                                    5'b11111,
                                    5'b10001,
                                    5'b10001};
                end
                73: begin // 'I'
                    char_pattern = {5'b11111,
                                    5'b00100,
                                    5'b00100,
                                    5'b00100,
                                    5'b11111};
                end
                74: begin // 'J'
                    char_pattern = {5'b00111,
                                    5'b00001,
                                    5'b00001,
                                    5'b10001,
                                    5'b01110};
                end
                75: begin // 'K'
                    char_pattern = {5'b10001,
                                    5'b10010,
                                    5'b11100,
                                    5'b10010,
                                    5'b10001};
                end
                76: begin // 'L'
                    char_pattern = {5'b10000,
                                    5'b10000,
                                    5'b10000,
                                    5'b10000,
                                    5'b11111};
                end
                77: begin // 'M'
                    char_pattern = {5'b10001,
                                    5'b11011,
                                    5'b10101,
                                    5'b10001,
                                    5'b10001};
                end
                78: begin // 'N'
                    char_pattern = {5'b10001,
                                    5'b11001,
                                    5'b10101,
                                    5'b10011,
                                    5'b10001};
                end
                79: begin // 'O'
                    char_pattern = {5'b01110,
                                    5'b10001,
                                    5'b10001,
                                    5'b10001,
                                    5'b01110};
                end
                80: begin // 'P'
                    char_pattern = {5'b11110,
                                    5'b10001,
                                    5'b11110,
                                    5'b10000,
                                    5'b10000};
                end
                81: begin // 'Q'
                    char_pattern = {5'b01110,
                                    5'b10001,
                                    5'b10001,
                                    5'b10011,
                                    5'b01111};
                end
                82: begin // 'R'
                    char_pattern = {5'b11110,
                                    5'b10001,
                                    5'b11110,
                                    5'b10010,
                                    5'b10001};
                end
                83: begin // 'S'
                    char_pattern = {5'b01110,
                                    5'b10000,
                                    5'b01110,
                                    5'b00001,
                                    5'b11110};
                end
                84: begin // 'T'
                    char_pattern = {5'b11111,
                                    5'b00100,
                                    5'b00100,
                                    5'b00100,
                                    5'b00100};
                end
                85: begin // 'U'
                    char_pattern = {5'b10001,
                                    5'b10001,
                                    5'b10001,
                                    5'b10001,
                                    5'b01110};
                end
                86: begin // 'V'
                    char_pattern = {5'b10001,
                                    5'b10001,
                                    5'b01010,
                                    5'b01010,
                                    5'b00100};
                end
                87: begin // 'W'
                    char_pattern = {5'b10001,
                                    5'b10001,
                                    5'b10101,
                                    5'b11011,
                                    5'b10001};
                end
                88: begin // 'X'
                    char_pattern = {5'b10001,
                                    5'b01010,
                                    5'b00100,
                                    5'b01010,
                                    5'b10001};
                end
                89: begin // 'Y'
                    char_pattern = {5'b10001,
                                    5'b01010,
                                    5'b00100,
                                    5'b00100,
                                    5'b00100};
                end
                90: begin // 'Z'
                    char_pattern = {5'b11111,
                                    5'b00010,
                                    5'b00100,
                                    5'b01000,
                                    5'b11111};
                end
                default: begin // Default to blank character
                    char_pattern = {5'b00000,
                                    5'b00000,
                                    5'b00000,
                                    5'b00000,
                                    5'b00000};
                end
            endcase
            
            is_letter = char_pattern;

    end
endfunction


endmodule