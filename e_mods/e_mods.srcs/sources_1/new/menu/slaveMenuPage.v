`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.03.2024 21:31:32
// Design Name: 
// Module Name: slavePageTwo
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


module slaveMenuPage(
    // Control
    //input clk, reset,
    input [3:0] menu_button_state,
    // LEDs, Switches, Buttons
    //input btnC, btnU, btnL, btnR, btnD, input [15:0] sw,
    // OLED Text Module
    input [7:0] ypos,
    output [12:0] text_colour, 
    output [8*15*5-1:0] text_lines
    // Others
    //output [6:0] seg, output dp, output [3:0] an
);
    
    constants constant();
    assign text_colour = (
        menu_button_state == 0 && (ypos < 10) ? constant.CYAN : 
        menu_button_state == 1 && (10 < ypos && ypos < 20) ? constant.CYAN : 
        menu_button_state == 2 && (20 < ypos && ypos < 30) ? constant.CYAN : 
        menu_button_state == 3 && (30 < ypos && ypos < 40) ? constant.CYAN : 
        menu_button_state == 4 && (40 < ypos && ypos < 50) ? constant.CYAN : 
        constant.WHITE
    );
    assign text_lines = {
        "VIEW INFO      ",
        "CURRENT TRADE  ",
        "START TRADE    ",
        "SET ACCOUNT ID ", 
        "VIEW ENCRYPTION"
    };
endmodule
