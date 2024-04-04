`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.04.2024 20:03:10
// Design Name: 
// Module Name: adaptor_test
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


module adaptor_test(
    input clk,
    input reset,
    inout [7:0] JB,
    output hsync,
    output vsync,
    output [11:0] rgb
);

wire [12:0] oled_pixel_index;
wire [15:0] oled_pixel_data;

// Instantiate the vga_oled_adaptor module
vga_oled_adaptor adaptor(
    .clk(clk),
    .reset(reset),
    .JB(JB),
    .pixel_index(oled_pixel_index),
    .pixel_data(oled_pixel_data),
    .hsync(hsync),
    .vsync(vsync),
    .rgb(rgb)
);

// OLED pixel coordinates
wire [7:0] xpos = oled_pixel_index % 96;
wire [7:0] ypos = oled_pixel_index / 96;

// Color parameters
parameter COLOR_WHITE = 16'hFFFF;
parameter COLOR_YELLOW = 16'hFFE0;
parameter COLOR_AQUA = 16'h07FF;
parameter COLOR_GREEN = 16'h07E0;
parameter COLOR_VIOLET = 16'hF81F;
parameter COLOR_RED = 16'hF800;
parameter COLOR_BLUE = 16'h001F;
parameter COLOR_BLACK = 16'h0000;
parameter COLOR_GRAY = 16'hD6BA;

// Pixel location status signals
wire u_white_on, u_yellow_on, u_aqua_on, u_green_on, u_violet_on, u_red_on, u_blue_on;
wire l_blue_on, l_black1_on, l_violet_on, l_gray_on, l_aqua_on, l_black2_on, l_white_on;

// Drivers for status signals
assign u_white_on  = (xpos >= 0   && xpos < 14  && ypos >= 0 && ypos < 52);
assign u_yellow_on = (xpos >= 14  && xpos < 28  && ypos >= 0 && ypos < 52);
assign u_aqua_on   = (xpos >= 28  && xpos < 42  && ypos >= 0 && ypos < 52);
assign u_green_on  = (xpos >= 42  && xpos < 56  && ypos >= 0 && ypos < 52);
assign u_violet_on = (xpos >= 56  && xpos < 70  && ypos >= 0 && ypos < 52);
assign u_red_on    = (xpos >= 70  && xpos < 84  && ypos >= 0 && ypos < 52);
assign u_blue_on   = (xpos >= 84  && xpos < 96  && ypos >= 0 && ypos < 52);

assign l_blue_on   = (xpos >= 0   && xpos < 14  && ypos >= 52 && ypos < 64);
assign l_black1_on = (xpos >= 14  && xpos < 28  && ypos >= 52 && ypos < 64);
assign l_violet_on = (xpos >= 28  && xpos < 42  && ypos >= 52 && ypos < 64);
assign l_gray_on   = (xpos >= 42  && xpos < 56  && ypos >= 52 && ypos < 64);
assign l_aqua_on   = (xpos >= 56  && xpos < 70  && ypos >= 52 && ypos < 64);
assign l_black2_on = (xpos >= 70  && xpos < 84  && ypos >= 52 && ypos < 64);
assign l_white_on  = (xpos >= 84  && xpos < 96  && ypos >= 52 && ypos < 64);

// Set OLED pixel data based on status signals
assign oled_pixel_data = u_white_on  ? COLOR_WHITE  :
                         u_yellow_on ? COLOR_YELLOW :
                         u_aqua_on   ? COLOR_AQUA   :
                         u_green_on  ? COLOR_GREEN  :
                         u_violet_on ? COLOR_VIOLET :
                         u_red_on    ? COLOR_RED    :
                         u_blue_on   ? COLOR_BLUE   :
                         l_blue_on   ? COLOR_BLUE   :
                         l_black1_on ? COLOR_BLACK  :
                         l_violet_on ? COLOR_VIOLET :
                         l_gray_on   ? COLOR_GRAY   :
                         l_aqua_on   ? COLOR_AQUA   :
                         l_black2_on ? COLOR_BLACK  :
                         l_white_on  ? COLOR_WHITE  :
                                       COLOR_BLACK;

endmodule
