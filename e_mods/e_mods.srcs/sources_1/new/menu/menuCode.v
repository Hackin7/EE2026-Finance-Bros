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
        input btnC, btnU, btnR, btnL, btnD,
        input [15:0] sw,
        input [12:0] oled_pixel_index, output [15:0] oled_pixel_data
    );
    
    //constants library
    constants constant();
    
    wire [12:0] pixel_index = oled_pixel_index;
    reg [15:0] pixel_data = 16'b0;
    assign oled_pixel_data = pixel_data;
    reg [15:0] pageOne_pixel_data;
    reg [7:0] xpos, ypos;
    wire [24:0] char_pattern;
    reg [7:0] char_code;
    reg btnPressed;
    reg [3:0] btnState = 4'd0;
    reg [3:0] prevIndex;
    reg [7:0] pageNumber;

    slavePageOne pageOne(
        .clk(clk), .btnC(btnC), btnU(btnU), .btnR(btnR), .btnL(btnL), .btnD(btnD),
        .sw(sw), .pixel_index(pixel_index), pixel_data(pageOne_pixel_data)
    );

    always @ (*) begin
        
        //movement of buttons
        if (btnR || btnL) begin
            btnPressed <= 1;
            prevIndex <= btnState;
        end else if (btnL) begin
            btnPressed <= 1;
            btnState <= btnState - 1;
        end else if (btnC) begin
            btnState <= 0;
        end else begin
            btnPressed <= 0;
        end
    end
    
endmodule
