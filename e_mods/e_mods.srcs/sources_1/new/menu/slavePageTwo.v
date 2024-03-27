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
    output [6:0] seg, output dp, output [3:0] an,
    output [31:0] qty
    );
    reg [15:0] pixel_data = 16'b0;
    assign oled_pixel_data = pixel_data;
    
    reg [6:0] controlSeg;
    reg controlDp;
    reg [3:0] controlAn;
    assign seg = controlSeg;
    assign dp = controlDp;
    assign an = controlAn;

    reg [31:0] controlQty;
    assign qty = controlQty;
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
    
    reg [4:0] state = 0;
    wire clk_10000hz;    
    clk_counter #(5_000, 30)    clk_100hz_module(clk, clk_10000hz);  // Looks like PWM
    
    always @ (posedge clk_10000hz) begin
        state <= state + 1;
        if (state == 0) begin 
            controlSeg <= constant.num0;
            controlDp <= 0;
            controlAn <= 4'b1110;
        end else if (state == 1) begin 
            controlSeg <= constant.num1;
            controlDp <= 0;
            controlAn <= 4'b1101;
        end else if (state == 2) begin 
            controlSeg <= constant.num2;
            controlDp <= 0;
            controlAn <= 4'b1011;
        end else if (state == 3) begin 
            controlSeg <= constant.num3;
            controlDp <= 0;
            controlAn <= 4'b0111;
            state <= 0; // Reset
        end  
    end
    
    always @ (*) begin
        if ((xpos > 5 && xpos < 11) && (ypos > 29 && ypos < 35)) begin
            pixel_data <= draw_letter(xpos, ypos, 6, 30, constant.charS) ? constant.BLACK : constant.WHITE;
        end else if ((xpos > 11 && xpos < 17) && (ypos > 29 && ypos < 35)) begin
            pixel_data <= draw_letter(xpos, ypos, 12, 30, constant.charE) ? constant.BLACK : constant.WHITE;
        end else if ((xpos > 17 && xpos < 23) && (ypos > 29 && ypos < 35)) begin
            pixel_data <= draw_letter(xpos, ypos, 18, 30, constant.charT) ? constant.BLACK : constant.WHITE;
        end else if ((xpos > 29 && xpos < 35) && (ypos > 29 && ypos < 35)) begin
            pixel_data <= draw_letter(xpos, ypos, 30, 30, constant.charQ) ? constant.BLACK : constant.WHITE;
        end else if ((xpos > 35 && xpos < 41) && (ypos > 29 && ypos < 35)) begin
            pixel_data <= draw_letter(xpos, ypos, 36, 30, constant.charU) ? constant.BLACK : constant.WHITE;
        end else if ((xpos > 41 && xpos < 47) && (ypos > 29 && ypos < 35)) begin
            pixel_data <= draw_letter(xpos, ypos, 42, 30, constant.charA) ? constant.BLACK : constant.WHITE;
        end else if ((xpos > 47 && xpos < 53) && (ypos > 29 && ypos < 35)) begin
            pixel_data <= draw_letter(xpos, ypos, 48, 30, constant.charN) ? constant.BLACK : constant.WHITE;
        end else if ((xpos > 53 && xpos < 59) && (ypos > 29 && ypos < 35)) begin
            pixel_data <= draw_letter(xpos, ypos, 54, 30, constant.charT) ? constant.BLACK : constant.WHITE;
        end else if ((xpos > 59 && xpos < 65) && (ypos > 29 && ypos < 35)) begin
            pixel_data <= draw_letter(xpos, ypos, 60, 30, constant.charI) ? constant.BLACK : constant.WHITE;
        end else if ((xpos > 65 && xpos < 71) && (ypos > 29 && ypos < 35)) begin
            pixel_data <= draw_letter(xpos, ypos, 66, 30, constant.charT) ? constant.BLACK : constant.WHITE;
        end else if ((xpos > 71 && xpos < 77) && (ypos > 29 && ypos < 35)) begin
            pixel_data <= draw_letter(xpos, ypos, 72, 30, constant.charY) ? constant.BLACK : constant.WHITE;
        end else pixel_data <= constant.WHITE;
    end
endmodule
