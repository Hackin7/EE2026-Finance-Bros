`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.03.2024 11:49:57
// Design Name: 
// Module Name: slave_table_view
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


module slave_table_view(
    // Control
    input clk, reset,
    // LEDs, Switches, Buttons
    input [12:0] pixel_index,
    output [15:0] oled_pixel_data
    );
    
    constants constant();
    reg [15:0] pixel_data;
    assign oled_pixel_data = pixel_data;
    
    reg [7:0] xpos, ypos;
    
    wire [15:0] user_pixel_data;
    text_dynamic #(7) text_module(
        .x(xpos), .y(ypos), 
        .color(constant.WHITE), .background(constant.BLACK), 
        .text_y_pos(0), .string("USER ID"), .offset(0), //9*6), 
        .repeat_flag(0), .x_pos_offset(0), .pixel_data(user_pixel_data));
    
    wire [15:0] balance_pixel_data;
    text_dynamic #(7) text_module2(
        .x(xpos), .y(ypos), 
        .color(constant.WHITE), .background(constant.BLACK), 
        .text_y_pos(10), .string("BALANCE"), .offset(0), //9*6), 
        .repeat_flag(0), .x_pos_offset(0), .pixel_data(balance_pixel_data));
    
    wire [15:0] stock_pixel_data;
    text_dynamic #(7) text_module3(
        .x(xpos), .y(ypos), 
        .color(constant.WHITE), .background(constant.BLACK), 
        .text_y_pos(20), .string("STOCK1"), .offset(0), //9*6), 
        .repeat_flag(0), .x_pos_offset(0), .pixel_data(stock_pixel_data));
        
    always @ (*) begin
    xpos = pixel_index % 96;
    ypos = pixel_index / 96;
    
    pixel_data <= user_pixel_data | balance_pixel_data | stock_pixel_data;

    end
    
endmodule
