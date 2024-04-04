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
    input [63:0] packet,
    input [12:0] pixel_index,
    output [15:0] packet_pixel_data,
    // OLED Text Module
    output [15:0]     text_colour, 
    output [8*15*7-1:0] text_lines
    );
    

    constants constant();
    wire [7:0] xpos = pixel_index % 96;
    wire [7:0] ypos = pixel_index / 96;
    wire [7:0] account_id, price, quantity, stock_id, action, open_packet, close_packet;
    assign close_packet = packet[7:0];
    assign price = packet[23:16];
    assign quantity = packet[31:24];
    assign stock_id = packet[39:32];
    assign account_id = packet[47:40];
    assign action = packet[55:48];
    assign open_packet = packet[63:56];
    
/*    wire [8*12-1:0] unencrypted_string;
    binary_to_hex num_module(unencrypted_packet[55:8], unencrypted_string);
    wire [8*12-1:0] encrypted_string;
    binary_to_hex num_module2(encrypted_packet[55:8], encrypted_string);
    wire [8*12-1:0] decrypted_string;
    binary_to_hex num_module3(decrypted_packet[55:8], decrypted_string);*/
    wire [8*4-1:0] price_num;
    wire [15:0] numbers_pixel_data;
    text_num_val_mapping price_num_module(price, price_num);
    wire [8*4-1:0] quantity_num;
    text_num_val_mapping quantity_num_module(quantity, quantity_num);
    wire [8*4-1:0] stock_num;
    text_num_val_mapping stock_num_module(stock_id, stock_num);
    
    assign text_colour = (
            action == 0 ? constant.RED : 
            (xpos >= 49 ? constant.CYAN : constant.WHITE )
    );
<<<<<<< HEAD
    
    wire [8*15*7-1:0] text_lines_view =
                        {
                            "STOCK ID   ", stock_num,
                            "QUANTITY   ", quantity_num, 
                            "PRICE      ", price_num,
                            "ACTION     ", (action == 1 ? "BUY " :  action == 2 ? "SELL" : "----"), 
                            "               ",
                            "               ",
                            "               "
                        };
=======
    wire [8*15*7-1:0] text_lines_view = (encrypted_packet == 0) ? 
        {
            "STOCK ID   ", stock_num,
            "QUANTITY   ", quantity_num, 
            "PRICE      ", price_num,
            "ACTION     ", (action == 1 ? "BUY " :  action == 2 ? "SELL" : "----"), 
            "               ",
            "               ",
            "               "
        }: 
        { "UNCRYPTED      ", 
            unencrypted_string, "   ",
            "ENCRYPTED      ", 
            encrypted_string, "   ",
            "DECRYPTED      ", 
            decrypted_string, "   ",
            "               "
        };
>>>>>>> 621cd37cd6273c848552d3c9d4c57ab5594119ed
    
    assign text_lines = (
        action == 0 ? {
            "NOTHING IS     ",
            "BEING SENT     ",
            "               ",
            "               ",
            "               ",
            "               ",
            "               "
        } : 
        text_lines_view
    );
endmodule
