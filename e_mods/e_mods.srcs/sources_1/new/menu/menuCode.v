`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.03.2024 19:46:50
// Design Name: 
// Module Name: menuCode
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


module menuCode(
        input clk, reset,
        input btnC, btnR, btnL, 
        input [15:0] sw,
        input [12:0] oled_pixel_index, output [15:0] oled_pixel_data
    );
    
    constants constant();
    
    wire [12:0] pixel_index = oled_pixel_index;
    reg [15:0] pixel_data;
    assign oled_pixel_data = pixel_data;
    reg [24:0] char;
    always @ (*) begin
        pixel_data <= constant.COLOR_WHITE;
        char <= is_letter(32);
    end
    
    
endmodule
