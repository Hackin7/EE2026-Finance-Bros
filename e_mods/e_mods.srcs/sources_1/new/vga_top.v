`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.04.2024 15:11:07
// Design Name: 
// Module Name: vga_top
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


module vga_top(

    input clk,       // from Basys 3

    input reset,     // btnC on Basys 3

    output hsync,    // to VGA connector

    output vsync,    // to VGA connector

    output [11:0] rgb  // to DAC, 3 RGB bits to VGA connector

    );

    

    wire w_video_on;

    wire [10:0] w_x, w_y;

    reg [11:0] rgb_reg;

    

    vga_controller vc(

        .clk(clk),

        .reset(reset),

        .video_on(w_video_on),

        .hsync(hsync),

        .vsync(vsync),

        .p_tick(),

        .x(w_x),

        .y(w_y)

    );

    

    // RGB Color Values

    parameter RED    = 12'h00F;

    parameter GREEN  = 12'h0F0;

    parameter BLUE   = 12'hF00;

    parameter YELLOW = 12'h0FF;     // RED and GREEN

    parameter AQUA   = 12'hFF0;     // GREEN and BLUE

    parameter VIOLET = 12'hF0F;     // RED and BLUE

    parameter WHITE  = 12'hFFF;     // all ON

    parameter BLACK  = 12'h000;     // all OFF

    parameter GRAY   = 12'hAAA;     // some of each color

    

    // Pixel Location Status Signals

    wire u_white_on, u_yellow_on, u_aqua_on, u_green_on, u_violet_on, u_red_on, u_blue_on;

    wire l_blue_on, l_black1_on, l_violet_on, l_gray_on, l_aqua_on, l_black2_on, l_white_on;

    

    // Drivers for Status Signals

    // Upper Sections

    assign u_white_on  = ((w_x >= 0)   && (w_x < 114)  &&  (w_y >= 0) && (w_y < 515));

    assign u_yellow_on = ((w_x >= 114) && (w_x < 228)  &&  (w_y >= 0) && (w_y < 515));

    assign u_aqua_on   = ((w_x >= 228) && (w_x < 342)  &&  (w_y >= 0) && (w_y < 515));

    assign u_green_on  = ((w_x >= 342) && (w_x < 456)  &&  (w_y >= 0) && (w_y < 515));

    assign u_violet_on = ((w_x >= 456) && (w_x < 570)  &&  (w_y >= 0) && (w_y < 515));

    assign u_red_on    = ((w_x >= 570) && (w_x < 684)  &&  (w_y >= 0) && (w_y < 515));

    assign u_blue_on   = ((w_x >= 684) && (w_x < 800)  &&  (w_y >= 0) && (w_y < 515));

    // Lower Sections

    assign l_blue_on   = ((w_x >= 0)   && (w_x < 114)  &&  (w_y >= 515) && (w_y < 600));

    assign l_black1_on = ((w_x >= 114) && (w_x < 228)  &&  (w_y >= 515) && (w_y < 600));

    assign l_violet_on = ((w_x >= 228) && (w_x < 342)  &&  (w_y >= 515) && (w_y < 600));

    assign l_gray_on   = ((w_x >= 342) && (w_x < 456)  &&  (w_y >= 515) && (w_y < 600));

    assign l_aqua_on   = ((w_x >= 456) && (w_x < 570)  &&  (w_y >= 515) && (w_y < 600));

    assign l_black2_on = ((w_x >= 570) && (w_x < 684)  &&  (w_y >= 515) && (w_y < 600));

    assign l_white_on  = ((w_x >= 684) && (w_x < 800)  &&  (w_y >= 515) && (w_y < 600));

    

    // Set RGB output value based on status signals

    always @(posedge clk)

        if(~w_video_on)

            rgb_reg <= BLACK;

        else

            if(u_white_on)

                rgb_reg <= WHITE;

            else if(u_yellow_on)

                rgb_reg <= YELLOW;

            else if(u_aqua_on)

                rgb_reg <= AQUA;

            else if(u_green_on)

                rgb_reg <= GREEN;

            else if(u_violet_on)

                rgb_reg <= VIOLET;

            else if(u_red_on)

                rgb_reg <= RED;

            else if(u_blue_on)

                rgb_reg <= BLUE;

            else if(l_blue_on)

                rgb_reg <= BLUE;

            else if(l_black1_on)

                rgb_reg <= BLACK;

            else if(l_violet_on)

                rgb_reg <= VIOLET;

            else if(l_gray_on)

                rgb_reg <= GRAY;

            else if(l_aqua_on)

                rgb_reg <= AQUA;

            else if(l_black2_on)

                rgb_reg <= BLACK;

            else if(l_white_on)

                rgb_reg <= WHITE;

            

    assign rgb = rgb_reg;

    

endmodule