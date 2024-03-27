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
        input [12:0] oled_pixel_index, output [15:0] oled_pixel_data,
        output [6:0] seg, output dp, output [3:0] an
    );
    
    //constants library
    constants constant();
    wire [12:0] pixel_index = oled_pixel_index;
    reg [15:0] pixel_data = 16'b0;
    assign oled_pixel_data = pixel_data;
    reg [6:0] control_seg;
    reg control_dp;
    reg [3:0] control_an;
    assign seg = control_seg;
    assign dp = control_dp;
    assign an = control_an;
    

    reg [7:0] xpos, ypos;
    wire [24:0] char_pattern;
    reg [7:0] char_code;
    reg btnPressed = 0;
    reg [3:0] btnState = 4'd0;
    reg [31:0] debouncer;
    reg [3:0] prevIndex;
    reg [7:0] pageNumber;
    
    //page one
    wire [15:0] pageOne_pixel_data;
    wire [6:0] pageOne_seg;
    wire pageOne_dp;
    wire [3:0] pageOne_an;
    wire [31:0] price, qty, stock;
    slavePageOne pageOne(
        .clk(clk), .btnC(btnC), .btnU(btnU), .btnR(btnR), .btnL(btnL), .btnD(btnD),
        .sw(sw), .pixel_index(pixel_index), .oled_pixel_data(pageOne_pixel_data),
        .seg(pageOne_seg), .dp(pageOne_dp), .an(pageOne_an),
        .price(price)
    );
    //page two
        wire [15:0] pageTwo_pixel_data;
        wire [6:0] pageTwo_seg;
        wire pageTwo_dp;
        wire [3:0] pageTwo_an;
        slavePageTwo pageTwo(
            .clk(clk), .btnC(btnC), .btnU(btnU), .btnR(btnR), .btnL(btnL), .btnD(btnD),
            .sw(sw), .pixel_index(pixel_index), .oled_pixel_data(pageTwo_pixel_data),
            .seg(pageTwo_seg), .dp(pageTwo_dp), .an(pageTwo_an),
            .qty(qty)
        );

    always @ (*) begin
        //movement of buttons
        if (btnPressed & ~btnC) btnState <= btnState + 1;
        btnPressed <= btnC;
        
        case (btnState)
            0: begin
                pixel_data <= pageOne_pixel_data;
                control_seg <= pageOne_seg;
                control_dp <= pageOne_dp;
                control_an <= pageOne_an;
            end
            1: begin
                pixel_data <= pageTwo_pixel_data;
                control_seg <= pageTwo_seg;
                control_dp <= pageTwo_dp;
                control_an <= pageTwo_an;
            end
        endcase
    end
    
endmodule
