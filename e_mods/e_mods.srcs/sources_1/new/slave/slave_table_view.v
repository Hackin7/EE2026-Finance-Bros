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
    output [15:0] oled_pixel_data, 
    input [31:0] num1, 
    input [31:0] num2, 
    input [31:0] num3, 
    input [31:0] num4, 
    input [31:0] num5, 
    input [31:0] num6
    );
    
    wire [8*(4)-1:0] num_string1, num_string2, num_string3, 
                     num_string4, num_string5, num_string6;
    text_num_val_mapping text_num1_module(num1, num_string1);
    text_num_val_mapping text_num2_module(num2, num_string2);
    text_num_val_mapping text_num3_module(num3, num_string3);
    text_num_val_mapping text_num4_module(num4, num_string4);
    text_num_val_mapping text_num5_module(num5, num_string5);
    text_num_val_mapping text_num6_module(num6, num_string6);

    constants constant();
    reg [15:0] pixel_data;
    assign oled_pixel_data = pixel_data;
    
    reg [7:0] xpos, ypos;
    
    /*
    wire [15:0] user_pixel_data;
    text_dynamic #(12) text_module(
        .x(xpos), .y(ypos), 
        .color(constant.WHITE), .background(constant.BLACK), 
        .text_y_pos(0), .string({"USER ID", ":", num_string1}), .offset(0), //9*6), 
        .repeat_flag(0), .x_pos_offset(0), .pixel_data(user_pixel_data));
    
    wire [15:0] balance_pixel_data;
    text_dynamic #(12) text_module2(
        .x(xpos), .y(ypos), 
        .color(constant.WHITE), .background(constant.BLACK), 
        .text_y_pos(10), .string({"BALANCE", ":", num_string2}), .offset(0), //9*6), 
        .repeat_flag(0), .x_pos_offset(0), .pixel_data(balance_pixel_data));
    
    wire [15:0] stock_pixel_data;
    text_dynamic #(12) text_module3(
        .x(xpos), .y(ypos), 
        .color(constant.WHITE), .background(constant.BLACK), 
        .text_y_pos(20), .string({"STOCK1 ", ":", num_string3}), .offset(0), //9*6), 
        .repeat_flag(0), .x_pos_offset(0), .pixel_data(stock_pixel_data));
    
    wire [15:0] stock2_pixel_data;
    text_dynamic #(12) text_module4(
        .x(xpos), .y(ypos), 
        .color(constant.WHITE), .background(constant.BLACK), 
        .text_y_pos(30), .string({"STOCK2 ", ":", num_string4}), .offset(0), //9*6), 
        .repeat_flag(0), .x_pos_offset(0), .pixel_data(stock2_pixel_data));
    
    
    wire [15:0] stock3_pixel_data;
    text_dynamic #(12) text_module5(
        .x(xpos), .y(ypos), 
        .color(constant.WHITE), .background(constant.BLACK), 
        .text_y_pos(40), .string({"STOCK3 ", ":", num_string5}), .offset(0), //9*6), 
        .repeat_flag(0), .x_pos_offset(0), .pixel_data(stock3_pixel_data));
    */

    wire [15:0] header_pixel_data;
    text_dynamic #(7) text_module(
        .x(xpos), .y(ypos), 
        .color(constant.WHITE), .background(constant.BLACK), 
        .text_y_pos(ypos < 10 ? 0 : (ypos < 20 ? 10 : 20)), 
        .string(ypos < 10 ? "USER ID" : (ypos < 20 ? "BALANCE" : "STOCK1 ")), 
        .offset(0), //9*6), 
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
        
        //pixel_data <= user_pixel_data | balance_pixel_data | stock_pixel_data | stock2_pixel_data | stock3_pixel_data;
        pixel_data <= header_pixel_data | account_num_pixel_data |
                    balance_num_pixel_data;
    end
    
endmodule
