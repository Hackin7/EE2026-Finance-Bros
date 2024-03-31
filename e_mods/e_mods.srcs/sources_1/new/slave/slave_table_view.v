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
    input [31:0] account_id, balance,
    // LEDs, Switches, Buttons
    input [12:0] pixel_index,
    output [15:0] oled_pixel_data
    );
    
    constants constant();
    reg [15:0] pixel_data;
    assign oled_pixel_data = pixel_data;
    
    reg [7:0] xpos, ypos;
    
    wire [15:0] header_pixel_data;
    text_dynamic #(7) text_module(
        .x(xpos), .y(ypos), 
        .color(constant.WHITE), .background(constant.BLACK), 
        .text_y_pos(ypos < 10 ? 0 : (ypos < 20 ? 10 : 20)), .string(ypos < 10 ? "USER ID" : (ypos < 20 ? "BALANCE" : "STOCK1 ")), .offset(0), //9*6), 
        .repeat_flag(0), .x_pos_offset(0), .pixel_data(header_pixel_data));
        
    wire [8*4-1:0] account_num;
    wire [15:0] account_num_pixel_data;
    text_num_val_mapping account_num_module(account_id, account_num);
    text_dynamic #(4) account_num_display_module(
        .x(xpos), .y(ypos), 
        .color(constant.CYAN), .background(constant.BLACK), 
        .text_y_pos(0), .string(account_num), .offset(0), 
        .repeat_flag(0), .x_pos_offset(50), .pixel_data(account_num_pixel_data));
    
    wire [8*4-1:0] balance_num;
    wire [15:0] balance_num_pixel_data;
    text_num_val_mapping balance_num_module(balance, balance_num);
    text_dynamic #(4) text_num_display_module(
        .x(xpos), .y(ypos), 
        .color(constant.CYAN), .background(constant.BLACK), 
        .text_y_pos(10), .string(balance_num), .offset(0), 
        .repeat_flag(0), .x_pos_offset(50), .pixel_data(balance_num_pixel_data));
        
    always @ (*) begin
    xpos = pixel_index % 96;
    ypos = pixel_index / 96;
    
    pixel_data <= header_pixel_data | account_num_pixel_data |
                  balance_num_pixel_data;

    end
    
endmodule
