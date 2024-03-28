`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Incy Tech
// Engineer: Sparsh
// 
// Create Date: 18.03.2024 10:12:35
// Design Name: Text Generator
// Module Name: text
// Project Name: 
// Target Devices: Basys 3
// Tool Versions: 
// Description: 
// 
// Dependencies: clk_counter, Oled_Display
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module text(
    // Control
    input reset, input clk,
    // LEDs, Switches, Buttons
    input btnC, btnU, btnL, btnR, btnD, input [15:0] sw, output [15:0] led,
    // 7 Segment Display
    output [6:0] seg, output dp, output [3:0] an,
    // OLED
    inout [7:0] JB
);

wire [7:0] Jb;
assign JB[7:0] = Jb;

wire clk_6_25mhz;
clk_counter #(16, 5) clk6p25m (clk, clk_6_25mhz);

reg [15:0] oled_pixel_data = 16'h0000;
wire [12:0] oled_pixel_index;
wire [15:0] pixel_data = oled_pixel_data;

Oled_Display display(
    .clk(clk_6_25mhz), .reset(0),
    .frame_begin(), .sending_pixels(), .sample_pixel(), .pixel_index(oled_pixel_index), .pixel_data(pixel_data),
    .cs(Jb[0]), .sdin(Jb[1]), .sclk(Jb[3]), .d_cn(Jb[4]), .resn(Jb[5]), .vccen(Jb[6]), .pmoden(Jb[7])); //to SPI

// Ease of usage
reg [7:0] xpos; // = pixel_index % 96;
reg [7:0] ypos; // = pixel_index / 96;

// Additional variable for the index of the character in the string
reg [3:0] char_index;

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

// Timing and character selection logic
reg [31:0] string_offset = 0;

// Counter for the scrolling speed
reg [31:0] pixel_counter = 0;

localparam STR_LEN = 9; // Set this to the desired string length

// Adjusted string length using STR_LEN
reg [8*STR_LEN:1] my_string;

reg repeat_text = 1; // Set this to 0 to disable text repetition
reg rolling_text_enable = 1; // Set this to 0 to disable rolling text

// Initialize the display_string
initial begin
    my_string = "1234 5678"; // Change this string as needed
end

function [15:0] rolling_text;
        input [31:0] x, y; // Current pixel position
        input [15:0] color; // Color of the character
        input [31:0] text_y_pos; // Y position where the text should start
        input [8*9:1] string; // Character array representing the string
        input [31:0] offset; // Offset index into the string
        input repeat_flag; // Flag to control text repetition
        input [31:0] x_pos_offset; // X position offset for the text
        
        reg [4:0] char_pattern[0:4]; // 5x5 bitmap pattern of the character
        integer idx;
        reg [7:0] char_code;

    begin
        // Calculate the index in the string based on the x position
        if (repeat_flag) begin
            idx = (STR_LEN + (offset / 6) - (x / 6)) % STR_LEN; // each character takes 6 pixels (5 pixels + 1 pixel gap)
        end else begin
            idx = (offset / 6) - (x / 6);
            if (idx < 0 || idx >= STR_LEN) begin
                rolling_text = 16'b0; // Return background color if outside the string range  
            end
        end
        
        char_code = string[(idx+1)*8 -: 8]; // Extract the character from the string
            
        // Define the 5x5 bitmap pattern for the extracted characte
        case (char_code)
            32: begin // ' '
                char_pattern[0] = 5'b00000;
                char_pattern[1] = 5'b00000;
                char_pattern[2] = 5'b00000;
                char_pattern[3] = 5'b00000;
                char_pattern[4] = 5'b00000;
            end            
            48: begin // '0'
                char_pattern[0] = 5'b11111;
                char_pattern[1] = 5'b10001;
                char_pattern[2] = 5'b10001;
                char_pattern[3] = 5'b10001;
                char_pattern[4] = 5'b11111;
            end
            49: begin // '1'
                char_pattern[0] = 5'b00100;
                char_pattern[1] = 5'b01100;
                char_pattern[2] = 5'b00100;
                char_pattern[3] = 5'b00100;
                char_pattern[4] = 5'b01110;
            end
            50: begin // '2'
                char_pattern[0] = 5'b11111;
                char_pattern[1] = 5'b00001;
                char_pattern[2] = 5'b11110;
                char_pattern[3] = 5'b10000;
                char_pattern[4] = 5'b11111;
            end
            51: begin // '3'
                char_pattern[0] = 5'b11110;
                char_pattern[1] = 5'b00001;
                char_pattern[2] = 5'b01110;
                char_pattern[3] = 5'b00001;
                char_pattern[4] = 5'b11110;
            end
            52: begin // '4'
                char_pattern[0] = 5'b00100;
                char_pattern[1] = 5'b01000;
                char_pattern[2] = 5'b11111;
                char_pattern[3] = 5'b00010;
                char_pattern[4] = 5'b00010;
            end
            53: begin // '5'
                char_pattern[0] = 5'b11111;
                char_pattern[1] = 5'b10000;
                char_pattern[2] = 5'b11111;
                char_pattern[3] = 5'b00001;
                char_pattern[4] = 5'b11111;
            end
            54: begin // '6'
                char_pattern[0] = 5'b11110;
                char_pattern[1] = 5'b10000;
                char_pattern[2] = 5'b11111;
                char_pattern[3] = 5'b10001;
                char_pattern[4] = 5'b11111;
            end
            55: begin // '7'
                char_pattern[0] = 5'b11111;
                char_pattern[1] = 5'b00001;
                char_pattern[2] = 5'b00010;
                char_pattern[3] = 5'b00100;
                char_pattern[4] = 5'b00100;
            end
            56: begin // '8'
                char_pattern[0] = 5'b11111;
                char_pattern[1] = 5'b10001;
                char_pattern[2] = 5'b11111;
                char_pattern[3] = 5'b10001;
                char_pattern[4] = 5'b11111;
            end
            57: begin // '9'
                char_pattern[0] = 5'b11110;
                char_pattern[1] = 5'b10001;
                char_pattern[2] = 5'b11111;
                char_pattern[3] = 5'b00001;
                char_pattern[4] = 5'b11111;
            end
            65: begin // 'A'
                char_pattern[0] = 5'b01110;
                char_pattern[1] = 5'b10001;
                char_pattern[2] = 5'b11111;
                char_pattern[3] = 5'b10001;
                char_pattern[4] = 5'b10001;
            end
            66: begin // 'B'
                char_pattern[0] = 5'b11110;
                char_pattern[1] = 5'b10001;
                char_pattern[2] = 5'b11110;
                char_pattern[3] = 5'b10001;
                char_pattern[4] = 5'b11110;
            end
            67: begin // 'C'
                char_pattern[0] = 5'b01110;
                char_pattern[1] = 5'b10001;
                char_pattern[2] = 5'b10000;
                char_pattern[3] = 5'b10001;
                char_pattern[4] = 5'b01110;
            end
            68: begin // 'D'
                char_pattern[0] = 5'b11110;
                char_pattern[1] = 5'b10001;
                char_pattern[2] = 5'b10001;
                char_pattern[3] = 5'b10001;
                char_pattern[4] = 5'b11110;
            end
            69: begin // 'E'
                char_pattern[0] = 5'b11111;
                char_pattern[1] = 5'b10000;
                char_pattern[2] = 5'b11110;
                char_pattern[3] = 5'b10000;
                char_pattern[4] = 5'b11111;
            end
            70: begin // 'F'
                char_pattern[0] = 5'b11111;
                char_pattern[1] = 5'b10000;
                char_pattern[2] = 5'b11110;
                char_pattern[3] = 5'b10000;
                char_pattern[4] = 5'b10000;
            end
            71: begin // 'G'
                char_pattern[0] = 5'b01111;
                char_pattern[1] = 5'b10000;
                char_pattern[2] = 5'b10011;
                char_pattern[3] = 5'b10001;
                char_pattern[4] = 5'b01110;
            end
            72: begin // 'H'
                char_pattern[0] = 5'b10001;
                char_pattern[1] = 5'b10001;
                char_pattern[2] = 5'b11111;
                char_pattern[3] = 5'b10001;
                char_pattern[4] = 5'b10001;
            end
            73: begin // 'I'
                char_pattern[0] = 5'b11111;
                char_pattern[1] = 5'b00100;
                char_pattern[2] = 5'b00100;
                char_pattern[3] = 5'b00100;
                char_pattern[4] = 5'b11111;
            end
            74: begin // 'J'
                char_pattern[0] = 5'b00111;
                char_pattern[1] = 5'b00001;
                char_pattern[2] = 5'b00001;
                char_pattern[3] = 5'b10001;
                char_pattern[4] = 5'b01110;
            end
            75: begin // 'K'
                char_pattern[0] = 5'b10001;
                char_pattern[1] = 5'b10010;
                char_pattern[2] = 5'b11100;
                char_pattern[3] = 5'b10010;
                char_pattern[4] = 5'b10001;
            end
            76: begin // 'L'
                char_pattern[0] = 5'b10000;
                char_pattern[1] = 5'b10000;
                char_pattern[2] = 5'b10000;
                char_pattern[3] = 5'b10000;
                char_pattern[4] = 5'b11111;
            end
            77: begin // 'M'
                char_pattern[0] = 5'b10001;
                char_pattern[1] = 5'b11011;
                char_pattern[2] = 5'b10101;
                char_pattern[3] = 5'b10001;
                char_pattern[4] = 5'b10001;
            end
            78: begin // 'N'
                char_pattern[0] = 5'b10001;
                char_pattern[1] = 5'b11001;
                char_pattern[2] = 5'b10101;
                char_pattern[3] = 5'b10011;
                char_pattern[4] = 5'b10001;
            end
            79: begin // 'O'
                char_pattern[0] = 5'b01110;
                char_pattern[1] = 5'b10001;
                char_pattern[2] = 5'b10001;
                char_pattern[3] = 5'b10001;
                char_pattern[4] = 5'b01110;
            end
            80: begin // 'P'
                char_pattern[0] = 5'b11110;
                char_pattern[1] = 5'b10001;
                char_pattern[2] = 5'b11110;
                char_pattern[3] = 5'b10000;
                char_pattern[4] = 5'b10000;
            end
            81: begin // 'Q'
                char_pattern[0] = 5'b01110;
                char_pattern[1] = 5'b10001;
                char_pattern[2] = 5'b10001;
                char_pattern[3] = 5'b10011;
                char_pattern[4] = 5'b01111;
            end
            82: begin // 'R'
                char_pattern[0] = 5'b11110;
                char_pattern[1] = 5'b10001;
                char_pattern[2] = 5'b11110;
                char_pattern[3] = 5'b10010;
                char_pattern[4] = 5'b10001;
            end
            83: begin // 'S'
                char_pattern[0] = 5'b01110;
                char_pattern[1] = 5'b10000;
                char_pattern[2] = 5'b01110;
                char_pattern[3] = 5'b00001;
                char_pattern[4] = 5'b11110;
            end
            84: begin // 'T'
                char_pattern[0] = 5'b11111;
                char_pattern[1] = 5'b00100;
                char_pattern[2] = 5'b00100;
                char_pattern[3] = 5'b00100;
                char_pattern[4] = 5'b00100;
            end
            85: begin // 'U'
                char_pattern[0] = 5'b10001;
                char_pattern[1] = 5'b10001;
                char_pattern[2] = 5'b10001;
                char_pattern[3] = 5'b10001;
                char_pattern[4] = 5'b01110;
            end
            86: begin // 'V'
                char_pattern[0] = 5'b10001;
                char_pattern[1] = 5'b10001;
                char_pattern[2] = 5'b01010;
                char_pattern[3] = 5'b01010;
                char_pattern[4] = 5'b00100;
            end
            87: begin // 'W'
                char_pattern[0] = 5'b10001;
                char_pattern[1] = 5'b10001;
                char_pattern[2] = 5'b10101;
                char_pattern[3] = 5'b11011;
                char_pattern[4] = 5'b10001;
            end
            88: begin // 'X'
                char_pattern[0] = 5'b10001;
                char_pattern[1] = 5'b01010;
                char_pattern[2] = 5'b00100;
                char_pattern[3] = 5'b01010;
                char_pattern[4] = 5'b10001;
            end
            89: begin // 'Y'
                char_pattern[0] = 5'b10001;
                char_pattern[1] = 5'b01010;
                char_pattern[2] = 5'b00100;
                char_pattern[3] = 5'b00100;
                char_pattern[4] = 5'b00100;
            end
            90: begin // 'Z'
                char_pattern[0] = 5'b11111;
                char_pattern[1] = 5'b00010;
                char_pattern[2] = 5'b00100;
                char_pattern[3] = 5'b01000;
                char_pattern[4] = 5'b11111;
            end
            
            default: begin // Default to blank character
                char_pattern[0] = 5'b00000;
                char_pattern[1] = 5'b00000;
                char_pattern[2] = 5'b00000;
                char_pattern[3] = 5'b00000;
                char_pattern[4] = 5'b00000;
            end
        endcase

    // Check if the current y position is within the range of the character bitmap
    if (y >= text_y_pos && y < text_y_pos + 5) begin
        // Calculate the effective x position, accounting for a 6-pixel width per character (5 for the character and 1 for the gap)
        // This ensures that every 6th pixel horizontally is a gap
        if ((x - x_pos_offset) % 6 < 5) begin
            // Access the bits in reverse order to un-flip the horizontal
            if (char_pattern[y - text_y_pos][4 - ((x - x_pos_offset) % 6)]) begin
                rolling_text = color; // Pixel is part of the character
            end else begin
                rolling_text = 16'b0; // Pixel is part of the background
            end
        end else begin
            // Check if it's the space character after the string repetition
            if ((x - x_pos_offset) % (STR_LEN * 6 + 1) == (STR_LEN * 6)) begin
                rolling_text = color; // Print a space character
            end else begin
                rolling_text = 16'b0; // This is the gap pixel
            end
        end
    end else begin
        rolling_text = 16'b0; // Pixel is part of the background
    end
end
endfunction


always @(posedge clk) begin
    if (rolling_text_enable) begin
        if (pixel_counter < 5_000_000) begin
            pixel_counter <= pixel_counter + 1;
        end else begin
            pixel_counter <= 0; // Reset the counter
            // Update offset for the string length using STR_LEN
            string_offset <= (string_offset + 1) % (STR_LEN * 6); 
        end
        // Reset the string offset if it goes beyond the string length
        if (string_offset >= (STR_LEN * 6)) begin
            string_offset <= 0;
        end
    end else begin
        string_offset <= 0; // Reset the offset if rolling text is disabled
    end
    xpos = oled_pixel_index % 96;
    ypos = oled_pixel_index / 96;
    
    // Call rolling_text with my_string, the current offset, and the x_pos_offset
    oled_pixel_data = rolling_text(xpos, ypos, COLOR_CYAN, 56, my_string, string_offset, repeat_text, 0);
end

endmodule
