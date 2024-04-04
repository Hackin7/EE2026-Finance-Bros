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
    input [2:0] button_state,
    input [7:0] ypos, 
    // OLED Text Module
    output [15:0]     text_colour, 
    output [8*15*7-1:0] text_lines
    );
    
    constants constant();

    assign text_colour = (
        button_state == 0 && (ypos < 10) ? constant.RED : 
        button_state == 1 && (10 <= ypos && ypos < 20) ? constant.YELLOW : 
        button_state == 2 && (20 <= ypos && ypos < 30) ? constant.GREEN : 
        constant.WHITE
    );
    assign text_lines = {
        "VIEW ALL USERS ",
        "VIEW ALL STOCKS",
        "VIEW ALL GRAPHS",
        "               ", 
        "               ", 
        "               ", 
        "               "
    };
    
endmodule
