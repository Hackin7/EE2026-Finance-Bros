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


module slaveMenuPage(
    // Control
    input clk, reset,
    input [3:0] menu_button_state,
    // LEDs, Switches, Buttons
    input btnC, btnU, btnL, btnR, btnD, input [15:0] sw,
    input [12:0] pixel_index,
    output [15:0] oled_pixel_data,
    output [6:0] seg, output dp, output [3:0] an
    );
    
    constants constant();
        
    reg [15:0] pixel_data = constant.YELLOW;
    assign oled_pixel_data = pixel_data;
    
    reg [6:0] controlSeg;
    reg controlDp;
    reg [3:0] controlAn;
    assign seg = controlSeg;
    assign dp = controlDp;
    assign an = controlAn;
    
    reg [7:0] xpos; reg [7:0] ypos;

    
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
    
    wire [15:0] view_info_pixel_data;
    text_dynamic #(9) text_module(
            .x(xpos), .y(ypos), 
            .color(menu_button_state == 0 ? constant.CYAN : constant.WHITE), .background(constant.BLACK), 
            .text_y_pos(10), .string("VIEW INFO"), .offset(0), //9*6), 
            .repeat_flag(0), .x_pos_offset(0), .pixel_data(view_info_pixel_data));
    
    wire [15:0] current_trade_pixel_data;
    text_dynamic #(13) text_module2(
            .x(xpos), .y(ypos), 
            .color(menu_button_state == 1 ? constant.CYAN : constant.WHITE), .background(constant.BLACK), 
            .text_y_pos(20), .string("CURRENT TRADE"), .offset(0), //12*6), 
            .repeat_flag(0), .x_pos_offset(0), .pixel_data(current_trade_pixel_data));

    wire [15:0] start_trade_pixel_data;
    text_dynamic #(11) text_module3(
            .x(xpos), .y(ypos), 
            .color(menu_button_state == 2 ? constant.CYAN : constant.WHITE), .background(constant.BLACK), 
            .text_y_pos(30), .string("START TRADE"), .offset(0), //13*6), 
            .repeat_flag(0), .x_pos_offset(0), .pixel_data(start_trade_pixel_data));
    
    reg [3:0] btnState = 4'd0;
    
    always @ (*) begin
        xpos <= pixel_index % 96;
        ypos <= pixel_index / 96;
        pixel_data <= view_info_pixel_data | start_trade_pixel_data | current_trade_pixel_data;
    /*
        if (is_border(xpos, ypos, 9, 9, 55, 7)) begin
            pixel_data <= btnState == 4'd0 ? constant.GREEN : constant.WHITE;
        end else if (1) begin
            pixel_data <= view_info_pixel_data | start_trade_pixel_data | current_trade_pixel_data ;
        end else if (is_border(xpos, ypos, 9, 19, 86, 7)) begin
            pixel_data <= btnState == 4'd1 ? constant.GREEN : constant.WHITE;
        end else if (is_border(xpos, ypos, 9, 29, 61, 7)) begin
            pixel_data <= btnState == 4'd2 ? constant.GREEN : constant.WHITE;
        end else pixel_data <= constant.BLACK;
        */
    end
endmodule
