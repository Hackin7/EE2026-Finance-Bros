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
    input [31:0] num6, 

    // OLED Text Module
    input [7:0] xpos,
    input [7:0] ypos,
    output [15:0] text_colour, 
    output [8*15*5-1:0] text_lines
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
    
    assign text_colour = (
        (xpos > 49 ? constant.CYAN : constant.WHITE)
    );
    assign text_lines = {
        {"USER ID", ":", num_string1, "   "},
        {"BALANCE", ":", num_string2, "   "},
        {"AAPL   ", ":", num_string3, "   "},
        {"GOOG   ", ":", num_string4, "   "}, 
        {"BABA   ", ":", num_string5, "   "}
    };
    
    
    reg [15:0] pixel_data;
    assign oled_pixel_data = pixel_data;
    
    //reg [7:0] xpos, ypos;
        
    always @ (*) begin
        //xpos = pixel_index % 96;
        //ypos = pixel_index / 96;
        
        pixel_data <= 0; //user_pixel_data | balance_pixel_data | stock_pixel_data | stock2_pixel_data | stock3_pixel_data;
    end
    
endmodule
