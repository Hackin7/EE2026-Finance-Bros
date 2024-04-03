`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.03.2024 13:38:47
// Design Name: 
// Module Name: view_packet
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


module view_packet(
    input [47:0] packet,
    /*input [7:0] price, quantity, stock_id, 
    input action,*/
    input [12:0] pixel_index,
    output [15:0] packet_pixel_data
    );
    
    constants constant();
    reg [15:0] pixel_data;
    assign packet_pixel_data = pixel_data;
    reg [7:0] xpos, ypos;
    
    wire [7:0] price, quantity, stock_id, action;
    assign price = packet[15:8];
    assign quantity = packet[23:16];
    assign stock_id = packet[31:24];
    assign action = packet[47:40];
    
    wire [15:0] text_pixel_data;
    text_dynamic #(8) price_module(
            .x(xpos), .y(ypos), 
            .color(constant.WHITE), .background(constant.BLACK), 
            .text_y_pos(ypos < 18 ? 0 : (ypos < 36 ? 18 : 36)), 
            .string(ypos <18 ? "PRICE   " : (ypos < 36 ? "QUANTITY" : "STOCK ID")), 
            .offset(0), .repeat_flag(0), .x_pos_offset(0), .pixel_data(text_pixel_data));
            
    wire [8*4-1:0] price_num;
    wire [15:0] numbers_pixel_data;
    text_num_val_mapping price_num_module(price, price_num);
    wire [8*4-1:0] quantity_num;
    text_num_val_mapping quantity_num_module(quantity, quantity_num);
    wire [8*4-1:0] stock_num;
    text_num_val_mapping stock_num_module(stock_id, stock_num);
    
    text_dynamic #(4) price_num_display_module(
        .x(xpos), .y(ypos), 
        .color(constant.CYAN), .background(constant.BLACK), 
        .text_y_pos(ypos < 25 ? 9 : (ypos < 40 ? 27 : 45)), 
        .string(ypos < 25 ? price_num: (ypos < 40 ? quantity_num : stock_num)), 
        .offset(0), .repeat_flag(0), .x_pos_offset(0), .pixel_data(numbers_pixel_data));
        
    wire [15:0] action_pixel_data;
    text_dynamic #(4) action_module(
        .x(xpos), .y(ypos), 
        .color(constant.WHITE), .background(constant.BLACK), 
        .text_y_pos(54), .string(action == 1 ? "BUY " : "SELL"), .offset(0), //12*6), 
        .repeat_flag(0), .x_pos_offset(0), .pixel_data(action_pixel_data));
            
    always @ (*) begin
        xpos <= pixel_index % 96;
        ypos <= pixel_index / 96;
        
        pixel_data <= text_pixel_data | numbers_pixel_data | action_pixel_data;
    end
    
endmodule
