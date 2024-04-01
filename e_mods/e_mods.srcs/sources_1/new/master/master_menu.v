`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.03.2024 09:47:12
// Design Name: 
// Module Name: masterPageOne
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


module master_menu(
    // Control
    input clk, input reset, 
    // LEDs, Switches, Buttons
    input btnC, btnU, btnL, btnR, btnD, input [15:0] sw,
    input [12:0] pixel_index,
    output [15:0] oled_pixel_data,
    output [6:0] seg, output dp, output [3:0] an,
    output reg [31:0] stock_id, 
    output reg [31:0] price, 
    output reg [31:0] qty, 
    output reg done=0
    );
    
    reg [7:0] xpos, ypos;
    reg [15:0] pixel_data;
    assign oled_pixel_data = pixel_data;
    reg [2:0] button_state;
    
    wire [15:0] all_user_pixel_data;
    text_dynamic #(14) all_user_module(
            .x(xpos), .y(ypos), 
            .color(button_state == 0 ? constant.CYAN : constant.WHITE), .background(constant.BLACK), 
            .text_y_pos(0), .string("VIEW ALL USERS"), .offset(0), //12*6), 
            .repeat_flag(0), .x_pos_offset(0), .pixel_data(all_user_pixel_data));
            
    wire [15:0] all_stock_pixel_data;
    text_dynamic #(15) all_stock_module(
        .x(xpos), .y(ypos), 
        .color(button_state == 1 ? constant.CYAN : constant.WHITE), .background(constant.BLACK), 
        .text_y_pos(10), .string("VIEW ALL STOCKS"), .offset(0), //12*6), 
        .repeat_flag(0), .x_pos_offset(0), .pixel_data(all_stock_pixel_data));

    wire [15:0] all_graph_pixel_data;
    text_dynamic #(15) all_graph_module(
        .x(xpos), .y(ypos), 
        .color(button_state == 2 ? constant.CYAN : constant.WHITE), .background(constant.BLACK), 
        .text_y_pos(20), .string("VIEW ALL GRAPHS"), .offset(0), //12*6), 
        .repeat_flag(0), .x_pos_offset(0), .pixel_data(all_graph_pixel_data));
            
    always @ (*) begin
        xpos <= pixel_index % 96;
        ypos <= pixel_index / 96;
        
        pixel_data <= all_user_pixel_data | all_stock_pixel_data | all_graph_pixel_data;
    end
    
endmodule
