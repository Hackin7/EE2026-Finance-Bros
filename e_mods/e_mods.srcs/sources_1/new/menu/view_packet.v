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


module view_packet(input [7:0] price, quantity, stock_id, 
    input action,
    input [12:0] pixel_index,
    output [15:0] packet_pixel_data
    );
    
    constants constant();
    
    reg [15:0] pixel_data;
    assign packet_pixel_data = pixel_data;
    
    reg [7:0] xpos, ypos;
    
    wire [15:0] price_pixel_data;
    text_dynamic #(5) price_module(
            .x(xpos), .y(ypos), 
            .color(constant.WHITE), .background(constant.BLACK), 
            .text_y_pos(0), .string("PRICE"), .offset(0), //12*6), 
            .repeat_flag(0), .x_pos_offset(0), .pixel_data(price_pixel_data));
            
    wire [8*4-1:0] price_num;
    wire [15:0] price_num_pixel_data;
    text_num_val_mapping price_num_module(price, price_num);
    text_dynamic #(4) price_num_display_module(
        .x(xpos), .y(ypos), 
        .color(constant.CYAN), .background(constant.BLACK), 
        .text_y_pos(9), .string(price_num), .offset(0), 
        .repeat_flag(0), .x_pos_offset(0), .pixel_data(price_num_pixel_data));
            
    wire [15:0] quantity_pixel_data;
    text_dynamic #(8) quantity_module(
        .x(xpos), .y(ypos), 
        .color(constant.WHITE), .background(constant.BLACK), 
        .text_y_pos(18), .string("QUANTITY"), .offset(0), //12*6), 
        .repeat_flag(0), .x_pos_offset(0), .pixel_data(quantity_pixel_data));
        
    wire [8*4-1:0] quantity_num;
    wire [15:0] quantity_num_pixel_data;
    text_num_val_mapping quantity_num_module(quantity, quantity_num);
    text_dynamic #(4) quantity_num_display_module(
        .x(xpos), .y(ypos), 
        .color(constant.CYAN), .background(constant.BLACK), 
        .text_y_pos(27), .string(quantity_num), .offset(0), 
        .repeat_flag(0), .x_pos_offset(0), .pixel_data(quantity_num_pixel_data));
                
    wire [15:0] stock_id_pixel_data;
    text_dynamic #(8) stock_module(
        .x(xpos), .y(ypos), 
        .color(constant.WHITE), .background(constant.BLACK), 
        .text_y_pos(36), .string("STOCK ID"), .offset(0), //12*6), 
        .repeat_flag(0), .x_pos_offset(0), .pixel_data(stock_id_pixel_data));
        
    wire [8*4-1:0] stock_num;
    wire [15:0] stock_num_pixel_data;
    text_num_val_mapping stock_num_module(stock_id, stock_num);
    text_dynamic #(4) stock_num_display_module(
        .x(xpos), .y(ypos), 
        .color(constant.CYAN), .background(constant.BLACK), 
        .text_y_pos(45), .string(stock_num), .offset(0), 
        .repeat_flag(0), .x_pos_offset(0), .pixel_data(stock_num_pixel_data));
        
    wire [15:0] action_pixel_data;
    text_dynamic #(4) action_module(
        .x(xpos), .y(ypos), 
        .color(constant.WHITE), .background(constant.BLACK), 
        .text_y_pos(54), .string(action == 0 ? "BUY " : "SELL"), .offset(0), //12*6), 
        .repeat_flag(0), .x_pos_offset(0), .pixel_data(action_pixel_data));
            
    always @ (*) begin
        xpos <= pixel_index % 96;
        ypos <= pixel_index / 96;
        
        pixel_data <= price_pixel_data | price_num_pixel_data |
                      quantity_pixel_data | quantity_num_pixel_data |
                      stock_id_pixel_data | stock_num_pixel_data |
                      action_pixel_data;
    end
    
endmodule
