`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.03.2024 21:31:32
// Design Name: 
// Module Name: slavePageTwo
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


module slavePageTwo(
    // Control
    input clk,
    // LEDs, Switches, Buttons
    input btnC, btnU, btnL, btnR, btnD, input [15:0] sw,
    input [12:0] pixel_index,
    output [15:0] oled_pixel_data,
    output [6:0] seg, output dp, output [3:0] an
    );
    reg [15:0] pixel_data = 16'b0;
    assign oled_pixel_data = pixel_data;
    
    reg [6:0] controlSeg;
    reg controlDp;
    reg [3:0] controlAn;
    assign seg = controlSeg;
    assign dp = controlDp;
    assign an = controlAn;
    
    reg [7:0] xpos; reg [7:0] ypos;
    constants constant();
    
    function is_border(
        input [7:0] x, input [7:0] y,
        input [7:0] x_start, input [7:0] y_start,
        input [7:0] x_len, input [7:0] y_len
   );
        reg long_range, short_range;
             
        begin
            long_range = (((x_start <= x) && (x < x_start + x_len + 1)) && 
                ((y_start == y)||((y_start + y_len) == y)));
            short_range = ( ((x_start == x)||(x_start + x_len == x)) && 
                (y_start <= y && y < y_start + y_len));
            is_border = long_range || short_range;
        end
    endfunction

    function draw_letter(
            input [7:0] x, input [7:0] y, 
            input [7:0] x_start, input [7:0] y_start,
            input [24:0] char_pattern); begin
        if ((x >= x_start && (x - x_start < 5)) //within x range
        && (y >= y_start && (y - y_start < 5)) //within y range
        ) begin
            draw_letter = char_pattern[24 - ((x - x_start) + (5 * (y - y_start)))];
            end 
        end
    endfunction
    
    reg [3:0] btnState = 4'd0;
    
    always @ (*) begin
        if (is_border(xpos, ypos, 9, 9, 55, 7)) begin
            pixel_data <= btnState == 4'd0 ? constant.GREEN : constant.BLACK;
        end else if ((xpos > 10 && xpos < 16) && (ypos > 10 && ypos < 16)) begin
            pixel_data <= draw_letter(xpos, ypos, 11, 11, constant.charV) ? constant.BLACK : constant.WHITE;
        end else if ((xpos > 16 && xpos < 22) && (ypos > 10 && ypos < 16)) begin
            pixel_data <= draw_letter(xpos, ypos, 17, 11, constant.charI) ? constant.BLACK : constant.WHITE;
        end else if ((xpos > 22 && xpos < 28) && (ypos > 10 && ypos < 16)) begin
            pixel_data <= draw_letter(xpos, ypos, 23, 11, constant.charE) ? constant.BLACK : constant.WHITE;
        end else if ((xpos > 28 && xpos < 34) && (ypos > 10 && ypos < 16)) begin
            pixel_data <= draw_letter(xpos, ypos, 29, 11, constant.charW) ? constant.BLACK : constant.WHITE;
        end else if ((xpos > 40 && xpos < 46) && (ypos > 10 && ypos < 16)) begin
            pixel_data <= draw_letter(xpos, ypos, 41, 11, constant.charI) ? constant.BLACK : constant.WHITE;
        end else if ((xpos > 46 && xpos < 52) && (ypos > 10 && ypos < 16)) begin
            pixel_data <= draw_letter(xpos, ypos, 47, 11, constant.charN) ? constant.BLACK : constant.WHITE;
        end else if ((xpos > 52 && xpos < 58) && (ypos > 10 && ypos < 16)) begin
            pixel_data <= draw_letter(xpos, ypos, 53, 11, constant.charF) ? constant.BLACK : constant.WHITE;
        end else if ((xpos > 58 && xpos < 64) && (ypos > 10 && ypos < 16)) begin
            pixel_data <= draw_letter(xpos, ypos, 59, 11, constant.charO) ? constant.BLACK : constant.WHITE;
        end else if (is_border(xpos, ypos, 9, 19, 86, 7)) begin
            pixel_data <= btnState == 4'd1 ? constant.GREEN : constant.BLACK;
        end else if ((xpos > 10 && xpos < 16) && (ypos > 20 && ypos < 26)) begin
            pixel_data <= draw_letter(xpos, ypos, 11, 21, constant.charC) ? constant.BLACK : constant.WHITE;
        end else if ((xpos > 16 && xpos < 22) && (ypos > 20 && ypos < 26)) begin
            pixel_data <= draw_letter(xpos, ypos, 17, 21, constant.charU) ? constant.BLACK : constant.WHITE;
        end else if ((xpos > 22 && xpos < 28) && (ypos > 20 && ypos < 26)) begin
            pixel_data <= draw_letter(xpos, ypos, 23, 21, constant.charR) ? constant.BLACK : constant.WHITE;
        end else if ((xpos > 28 && xpos < 34) && (ypos > 20 && ypos < 26)) begin
            pixel_data <= draw_letter(xpos, ypos, 29, 21, constant.charR) ? constant.BLACK : constant.WHITE;
        end else if ((xpos > 34 && xpos < 40) && (ypos > 20 && ypos < 26)) begin
            pixel_data <= draw_letter(xpos, ypos, 35, 21, constant.charE) ? constant.BLACK : constant.WHITE;
        end else if ((xpos > 40 && xpos < 46) && (ypos > 20 && ypos < 26)) begin
            pixel_data <= draw_letter(xpos, ypos, 41, 21, constant.charN) ? constant.BLACK : constant.WHITE;
        end else if ((xpos > 46 && xpos < 52) && (ypos > 20 && ypos < 26)) begin
            pixel_data <= draw_letter(xpos, ypos, 47, 21, constant.charT) ? constant.BLACK : constant.WHITE;
        end else if ((xpos > 58 && xpos < 64) && (ypos > 20 && ypos < 26)) begin
            pixel_data <= draw_letter(xpos, ypos, 59, 21, constant.charT) ? constant.BLACK : constant.WHITE;
        end else if ((xpos > 64 && xpos < 70) && (ypos > 20 && ypos < 26)) begin
            pixel_data <= draw_letter(xpos, ypos, 65, 21, constant.charR) ? constant.BLACK : constant.WHITE;
        end else if ((xpos > 70 && xpos < 76) && (ypos > 20 && ypos < 26)) begin
            pixel_data <= draw_letter(xpos, ypos, 71, 21, constant.charA) ? constant.BLACK : constant.WHITE;
        end else if ((xpos > 76 && xpos < 82) && (ypos > 20 && ypos < 26)) begin
            pixel_data <= draw_letter(xpos, ypos, 77, 21, constant.charD) ? constant.BLACK : constant.WHITE;
        end else if ((xpos > 82 && xpos < 88) && (ypos > 20 && ypos < 26)) begin
            pixel_data <= draw_letter(xpos, ypos, 83, 21, constant.charE) ? constant.BLACK : constant.WHITE;
        end else if ((xpos > 88 && xpos < 94) && (ypos > 20 && ypos < 26)) begin
            pixel_data <= draw_letter(xpos, ypos, 89, 21, constant.charS) ? constant.BLACK : constant.WHITE;
        end else if (is_border(xpos, ypos, 9, 29, 61, 7)) begin
            pixel_data <= btnState == 4'd2 ? constant.GREEN : constant.BLACK;
        end else if ((xpos > 10 && xpos < 16) && (ypos > 30 && ypos < 36)) begin
            pixel_data <= draw_letter(xpos, ypos, 11, 31, constant.charS) ? constant.BLACK : constant.WHITE;
        end else if ((xpos > 16 && xpos < 22) && (ypos > 30 && ypos < 36)) begin
            pixel_data <= draw_letter(xpos, ypos, 17, 31, constant.charT) ? constant.BLACK : constant.WHITE;
        end else if ((xpos > 22 && xpos < 28) && (ypos > 30 && ypos < 36)) begin
            pixel_data <= draw_letter(xpos, ypos, 23, 31, constant.charA) ? constant.BLACK : constant.WHITE;
        end else if ((xpos > 28 && xpos < 34) && (ypos > 30 && ypos < 36)) begin
            pixel_data <= draw_letter(xpos, ypos, 29, 31, constant.charR) ? constant.BLACK : constant.WHITE;
        end else if ((xpos > 40 && xpos < 46) && (ypos > 30 && ypos < 36)) begin
            pixel_data <= draw_letter(xpos, ypos, 41, 31, constant.charT) ? constant.BLACK : constant.WHITE;
        end else if ((xpos > 46 && xpos < 52) && (ypos > 30 && ypos < 36)) begin
            pixel_data <= draw_letter(xpos, ypos, 47, 31, constant.charR) ? constant.BLACK : constant.WHITE;
        end else if ((xpos > 52 && xpos < 58) && (ypos > 30 && ypos < 36)) begin
            pixel_data <= draw_letter(xpos, ypos, 53, 31, constant.charA) ? constant.BLACK : constant.WHITE;
        end else if ((xpos > 58 && xpos < 64) && (ypos > 30 && ypos < 36)) begin
            pixel_data <= draw_letter(xpos, ypos, 59, 31, constant.charP) ? constant.BLACK : constant.WHITE;
        end else if ((xpos > 64 && xpos < 70) && (ypos > 30 && ypos < 36)) begin
            pixel_data <= draw_letter(xpos, ypos, 65, 31, constant.charH) ? constant.BLACK : constant.WHITE;
        end else pixel_data <= constant.WHITE;
    end
endmodule
