module text_dynamic #(
    parameter STR_LEN=9
)(
    input [31:0] x, y, // Current pixel position
    input [15:0] color, // Color of the character
    input [15:0] background, // Color of the character
    input [31:0] text_y_pos, // Y position where the text should start
    input [8*STR_LEN:1] string, // Character array representing the string
    input [31:0] offset, // Offset index into the string (shift text left)
    input repeat_flag, // Flag to control text repetition
    input signed [31:0] x_pos_offset, // X position offset for the text

    output [15:0] pixel_data
);

function [15:0] rolling_text;
        input [31:0] x, y; // Current pixel position
        input [15:0] color; // Color of the character
        input [31:0] text_y_pos; // Y position where the text should start
        input [8*STR_LEN:1] string; // Character array representing the string
        input [31:0] offset; // Offset index into the string
        input repeat_flag; // Flag to control text repetition
        input signed [31:0] x_pos_offset; // X position offset for the text
        
        reg [4:0] char_pattern[0:4]; // 5x5 bitmap pattern of the character
        integer idx;
        reg [7:0] char_code;

    begin
        // Calculate the index in the string based on the x position
        if (repeat_flag) begin
            idx = (STR_LEN + (offset / 6) - ((x-x_pos_offset) / 6)) % STR_LEN; // each character takes 6 pixels (5 pixels + 1 pixel gap)
        end else begin
            idx = STR_LEN - ((offset / 6) + ((x-x_pos_offset) / 6)) - 1;
            if (idx < 0 || idx >= STR_LEN) begin
                rolling_text = background; // Return background color if outside the string range  
            end else begin
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
                        rolling_text = background; // Pixel is part of the background
                    end
                end else begin
                    // Check if it's the space character after the string repetition
                    if ((x - x_pos_offset) % (STR_LEN * 6 + 1) == (STR_LEN * 6)) begin
                        rolling_text = color; // Print a space character
                    end else begin
                        rolling_text = background; // This is the gap pixel
                    end
                end
            end else begin
                rolling_text = 16'b0; // Pixel is part of the background
            end
            end
        end
end
endfunction
assign pixel_data = rolling_text(x, y, color, text_y_pos, string, offset, repeat_flag, x_pos_offset);

endmodule