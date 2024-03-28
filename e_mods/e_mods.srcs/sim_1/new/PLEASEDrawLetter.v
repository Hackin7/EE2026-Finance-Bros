`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.03.2024 10:05:25
// Design Name: 
// Module Name: PLEASEDrawLetter
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


module PLEASEDrawLetter();
    reg [7:0] char;
    wire [24:0] char_code;
    drawLetter draw(char, char_code);
    reg clk, reset, btnC, btnR, btnL;
    reg [15:0] sw;
    reg [12:0] oled_pixel_index;
    wire [15:0] oled_pixel_data;
    
    menuCode menu(clk, reset,
            btnC, btnR, btnL, 
            sw,
            oled_pixel_index, oled_pixel_data);

    initial begin
    oled_pixel_index = 0;
    char = 8'd32; #15;
    oled_pixel_index = oled_pixel_index + 1;
    oled_pixel_index = oled_pixel_index + 1;
    oled_pixel_index = oled_pixel_index + 1;
    oled_pixel_index = oled_pixel_index + 1;
    oled_pixel_index = oled_pixel_index + 1;
    oled_pixel_index = oled_pixel_index + 1;
    oled_pixel_index = oled_pixel_index + 1;
    oled_pixel_index = oled_pixel_index + 1;
    oled_pixel_index = oled_pixel_index + 1;
    oled_pixel_index = oled_pixel_index + 1;
    oled_pixel_index = oled_pixel_index + 1;
    oled_pixel_index = oled_pixel_index + 1;
    oled_pixel_index = oled_pixel_index + 1;
    oled_pixel_index = oled_pixel_index + 1;
    oled_pixel_index = oled_pixel_index + 1;
    oled_pixel_index = oled_pixel_index + 1;
    oled_pixel_index = oled_pixel_index + 1;
    oled_pixel_index = oled_pixel_index + 1;
    oled_pixel_index = oled_pixel_index + 1;
    oled_pixel_index = oled_pixel_index + 1;
    oled_pixel_index = oled_pixel_index + 1;
    oled_pixel_index = oled_pixel_index + 1;
    oled_pixel_index = oled_pixel_index + 1;
    oled_pixel_index = oled_pixel_index + 1;
    oled_pixel_index = oled_pixel_index + 1;
    oled_pixel_index = oled_pixel_index + 1;
    oled_pixel_index = oled_pixel_index + 1;
    oled_pixel_index = oled_pixel_index + 1;
    oled_pixel_index = oled_pixel_index + 1;
    oled_pixel_index = oled_pixel_index + 1;
    char = 8'd65; #15;
    oled_pixel_index = oled_pixel_index + 1;
        oled_pixel_index = oled_pixel_index + 1;
        oled_pixel_index = oled_pixel_index + 1;
        oled_pixel_index = oled_pixel_index + 1;
        oled_pixel_index = oled_pixel_index + 1;
        oled_pixel_index = oled_pixel_index + 1;
        oled_pixel_index = oled_pixel_index + 1;
        oled_pixel_index = oled_pixel_index + 1;
        oled_pixel_index = oled_pixel_index + 1;
        oled_pixel_index = oled_pixel_index + 1;
        oled_pixel_index = oled_pixel_index + 1;
        oled_pixel_index = oled_pixel_index + 1;
        oled_pixel_index = oled_pixel_index + 1;
        oled_pixel_index = oled_pixel_index + 1;
        oled_pixel_index = oled_pixel_index + 1;
        oled_pixel_index = oled_pixel_index + 1;
        oled_pixel_index = oled_pixel_index + 1;
        oled_pixel_index = oled_pixel_index + 1;
        oled_pixel_index = oled_pixel_index + 1;
        oled_pixel_index = oled_pixel_index + 1;
        oled_pixel_index = oled_pixel_index + 1;
        oled_pixel_index = oled_pixel_index + 1;
        oled_pixel_index = oled_pixel_index + 1;
        oled_pixel_index = oled_pixel_index + 1;
        oled_pixel_index = oled_pixel_index + 1;
        oled_pixel_index = oled_pixel_index + 1;
        oled_pixel_index = oled_pixel_index + 1;
        oled_pixel_index = oled_pixel_index + 1;
        oled_pixel_index = oled_pixel_index + 1;
        oled_pixel_index = oled_pixel_index + 1;oled_pixel_index = oled_pixel_index + 1;
            oled_pixel_index = oled_pixel_index + 1;
            oled_pixel_index = oled_pixel_index + 1;
            oled_pixel_index = oled_pixel_index + 1;
            oled_pixel_index = oled_pixel_index + 1;
            oled_pixel_index = oled_pixel_index + 1;
            oled_pixel_index = oled_pixel_index + 1;
            oled_pixel_index = oled_pixel_index + 1;
            oled_pixel_index = oled_pixel_index + 1;
            oled_pixel_index = oled_pixel_index + 1;
            oled_pixel_index = oled_pixel_index + 1;
            oled_pixel_index = oled_pixel_index + 1;
            oled_pixel_index = oled_pixel_index + 1;
            oled_pixel_index = oled_pixel_index + 1;
            oled_pixel_index = oled_pixel_index + 1;
            oled_pixel_index = oled_pixel_index + 1;
            oled_pixel_index = oled_pixel_index + 1;
            oled_pixel_index = oled_pixel_index + 1;
            oled_pixel_index = oled_pixel_index + 1;
            oled_pixel_index = oled_pixel_index + 1;
            oled_pixel_index = oled_pixel_index + 1;
            oled_pixel_index = oled_pixel_index + 1;
            oled_pixel_index = oled_pixel_index + 1;
            oled_pixel_index = oled_pixel_index + 1;
            oled_pixel_index = oled_pixel_index + 1;
            oled_pixel_index = oled_pixel_index + 1;
            oled_pixel_index = oled_pixel_index + 1;
            oled_pixel_index = oled_pixel_index + 1;
            oled_pixel_index = oled_pixel_index + 1;
            oled_pixel_index = oled_pixel_index + 1;
            oled_pixel_index = oled_pixel_index + 1;
                oled_pixel_index = oled_pixel_index + 1;
                oled_pixel_index = oled_pixel_index + 1;
                oled_pixel_index = oled_pixel_index + 1;
                oled_pixel_index = oled_pixel_index + 1;
                oled_pixel_index = oled_pixel_index + 1;
                oled_pixel_index = oled_pixel_index + 1;
                oled_pixel_index = oled_pixel_index + 1;
                oled_pixel_index = oled_pixel_index + 1;
                oled_pixel_index = oled_pixel_index + 1;
                oled_pixel_index = oled_pixel_index + 1;
                oled_pixel_index = oled_pixel_index + 1;
                oled_pixel_index = oled_pixel_index + 1;
                oled_pixel_index = oled_pixel_index + 1;
                oled_pixel_index = oled_pixel_index + 1;
                oled_pixel_index = oled_pixel_index + 1;
                oled_pixel_index = oled_pixel_index + 1;
                oled_pixel_index = oled_pixel_index + 1;
                oled_pixel_index = oled_pixel_index + 1;
                oled_pixel_index = oled_pixel_index + 1;
                oled_pixel_index = oled_pixel_index + 1;
                oled_pixel_index = oled_pixel_index + 1;
                oled_pixel_index = oled_pixel_index + 1;
                oled_pixel_index = oled_pixel_index + 1;
                oled_pixel_index = oled_pixel_index + 1;
                oled_pixel_index = oled_pixel_index + 1;
                oled_pixel_index = oled_pixel_index + 1;
                oled_pixel_index = oled_pixel_index + 1;
                oled_pixel_index = oled_pixel_index + 1;
                oled_pixel_index = oled_pixel_index + 1;
                oled_pixel_index = oled_pixel_index + 1;
                    oled_pixel_index = oled_pixel_index + 1;
                    oled_pixel_index = oled_pixel_index + 1;
                    oled_pixel_index = oled_pixel_index + 1;
                    oled_pixel_index = oled_pixel_index + 1;
                    oled_pixel_index = oled_pixel_index + 1;
                    oled_pixel_index = oled_pixel_index + 1;
                    oled_pixel_index = oled_pixel_index + 1;
                    oled_pixel_index = oled_pixel_index + 1;
                    oled_pixel_index = oled_pixel_index + 1;
                    oled_pixel_index = oled_pixel_index + 1;
                    oled_pixel_index = oled_pixel_index + 1;
                    oled_pixel_index = oled_pixel_index + 1;
                    oled_pixel_index = oled_pixel_index + 1;
                    oled_pixel_index = oled_pixel_index + 1;
                    oled_pixel_index = oled_pixel_index + 1;
                    oled_pixel_index = oled_pixel_index + 1;
                    oled_pixel_index = oled_pixel_index + 1;
                    oled_pixel_index = oled_pixel_index + 1;
                    oled_pixel_index = oled_pixel_index + 1;
                    oled_pixel_index = oled_pixel_index + 1;
                    oled_pixel_index = oled_pixel_index + 1;
                    oled_pixel_index = oled_pixel_index + 1;
                    oled_pixel_index = oled_pixel_index + 1;
                    oled_pixel_index = oled_pixel_index + 1;
                    oled_pixel_index = oled_pixel_index + 1;
                    oled_pixel_index = oled_pixel_index + 1;
                    oled_pixel_index = oled_pixel_index + 1;
                    oled_pixel_index = oled_pixel_index + 1;
                    oled_pixel_index = oled_pixel_index + 1;
                    oled_pixel_index = oled_pixel_index + 1;
                        oled_pixel_index = oled_pixel_index + 1;
                        oled_pixel_index = oled_pixel_index + 1;
                        oled_pixel_index = oled_pixel_index + 1;
                        oled_pixel_index = oled_pixel_index + 1;
                        oled_pixel_index = oled_pixel_index + 1;
                        oled_pixel_index = oled_pixel_index + 1;
                        oled_pixel_index = oled_pixel_index + 1;
                        oled_pixel_index = oled_pixel_index + 1;
                        oled_pixel_index = oled_pixel_index + 1;
                        oled_pixel_index = oled_pixel_index + 1;
                        oled_pixel_index = oled_pixel_index + 1;
                        oled_pixel_index = oled_pixel_index + 1;
                        oled_pixel_index = oled_pixel_index + 1;
                        oled_pixel_index = oled_pixel_index + 1;
                        oled_pixel_index = oled_pixel_index + 1;
                        oled_pixel_index = oled_pixel_index + 1;
                        oled_pixel_index = oled_pixel_index + 1;
                        oled_pixel_index = oled_pixel_index + 1;
                        oled_pixel_index = oled_pixel_index + 1;
                        oled_pixel_index = oled_pixel_index + 1;
                        oled_pixel_index = oled_pixel_index + 1;
                        oled_pixel_index = oled_pixel_index + 1;
                        oled_pixel_index = oled_pixel_index + 1;
                        oled_pixel_index = oled_pixel_index + 1;
                        oled_pixel_index = oled_pixel_index + 1;
                        oled_pixel_index = oled_pixel_index + 1;
                        oled_pixel_index = oled_pixel_index + 1;
                        oled_pixel_index = oled_pixel_index + 1;
                        oled_pixel_index = oled_pixel_index + 1;
                        oled_pixel_index = oled_pixel_index + 1;
                            oled_pixel_index = oled_pixel_index + 1;
                            oled_pixel_index = oled_pixel_index + 1;
                            oled_pixel_index = oled_pixel_index + 1;
                            oled_pixel_index = oled_pixel_index + 1;
                            oled_pixel_index = oled_pixel_index + 1;
                            oled_pixel_index = oled_pixel_index + 1;
                            oled_pixel_index = oled_pixel_index + 1;
                            oled_pixel_index = oled_pixel_index + 1;
                            oled_pixel_index = oled_pixel_index + 1;
                            oled_pixel_index = oled_pixel_index + 1;
                            oled_pixel_index = oled_pixel_index + 1;
                            oled_pixel_index = oled_pixel_index + 1;
                            oled_pixel_index = oled_pixel_index + 1;
                            oled_pixel_index = oled_pixel_index + 1;
                            oled_pixel_index = oled_pixel_index + 1;
                            oled_pixel_index = oled_pixel_index + 1;
                            oled_pixel_index = oled_pixel_index + 1;
                            oled_pixel_index = oled_pixel_index + 1;
                            oled_pixel_index = oled_pixel_index + 1;
                            oled_pixel_index = oled_pixel_index + 1;
                            oled_pixel_index = oled_pixel_index + 1;
                            oled_pixel_index = oled_pixel_index + 1;
                            oled_pixel_index = oled_pixel_index + 1;
                            oled_pixel_index = oled_pixel_index + 1;
                            oled_pixel_index = oled_pixel_index + 1;
                            oled_pixel_index = oled_pixel_index + 1;
                            oled_pixel_index = oled_pixel_index + 1;
                            oled_pixel_index = oled_pixel_index + 1;
                            oled_pixel_index = oled_pixel_index + 1;
                            oled_pixel_index = oled_pixel_index + 1;
                                oled_pixel_index = oled_pixel_index + 1;
                                oled_pixel_index = oled_pixel_index + 1;
                                oled_pixel_index = oled_pixel_index + 1;
                                oled_pixel_index = oled_pixel_index + 1;
                                oled_pixel_index = oled_pixel_index + 1;
                                oled_pixel_index = oled_pixel_index + 1;
                                oled_pixel_index = oled_pixel_index + 1;
                                oled_pixel_index = oled_pixel_index + 1;
                                oled_pixel_index = oled_pixel_index + 1;
                                oled_pixel_index = oled_pixel_index + 1;
                                oled_pixel_index = oled_pixel_index + 1;
                                oled_pixel_index = oled_pixel_index + 1;
                                oled_pixel_index = oled_pixel_index + 1;
                                oled_pixel_index = oled_pixel_index + 1;
                                oled_pixel_index = oled_pixel_index + 1;
                                oled_pixel_index = oled_pixel_index + 1;
                                oled_pixel_index = oled_pixel_index + 1;
                                oled_pixel_index = oled_pixel_index + 1;
                                oled_pixel_index = oled_pixel_index + 1;
                                oled_pixel_index = oled_pixel_index + 1;
                                oled_pixel_index = oled_pixel_index + 1;
                                oled_pixel_index = oled_pixel_index + 1;
                                oled_pixel_index = oled_pixel_index + 1;
                                oled_pixel_index = oled_pixel_index + 1;
                                oled_pixel_index = oled_pixel_index + 1;
                                oled_pixel_index = oled_pixel_index + 1;
                                oled_pixel_index = oled_pixel_index + 1;
                                oled_pixel_index = oled_pixel_index + 1;
                                oled_pixel_index = oled_pixel_index + 1;
        
    end
    
endmodule
