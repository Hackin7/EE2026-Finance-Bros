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
    output [15:0] packet_pixel_data,
    // OLED Text Module
    output [15:0]     text_colour, 
    output [8*15*5-1:0] text_lines
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
            
    wire [8*4-1:0] price_num;
    wire [15:0] numbers_pixel_data;
    text_num_val_mapping price_num_module(price, price_num);
    wire [8*4-1:0] quantity_num;
    text_num_val_mapping quantity_num_module(quantity, quantity_num);
    wire [8*4-1:0] stock_num;
    text_num_val_mapping stock_num_module(stock_id, stock_num);
    
    assign text_colour = (xpos >= 49 ? constant.CYAN : constant.WHITE);

    assign text_lines = {
        {"PRICE   ", ":", price_num,    "  "},
        {"QUANTITY", ":", quantity_num, "  "},
        {"STOCK ID", ":", stock_num,    "  "},
        {"TYPE    ", ":", (action == 1 ? "BUY " : "SELL"), "  "}, 
        "               "
    };

    always @ (*) begin
        xpos <= pixel_index % 96;
        ypos <= pixel_index / 96;
        
        pixel_data <= 0;
    end
    
endmodule
