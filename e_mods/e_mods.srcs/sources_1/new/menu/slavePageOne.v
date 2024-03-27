`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.03.2024 21:31:32
// Design Name: 
// Module Name: slavePageOne
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


module slavePageOne(
    // Control
    input clk,
    // LEDs, Switches, Buttons
    input btnC, btnU, btnL, btnR, btnD, input [15:0] sw,
    input [12:0] pixel_index,
    output [15:0] oled_pixel_data,
    output [6:0] seg, output dp, output [3:0] an,
    output [31:0] price
    );
    
    reg [15:0] pixel_data = 16'b0;
    assign oled_pixel_data = pixel_data;
    
    reg [6:0] controlSeg;
    reg controlDp;
    reg [3:0] controlAn;
    assign seg = controlSeg;
    assign dp = controlDp;
    assign an = controlAn;

    reg [31:0] controlPrice;
    reg [31:0] controlQty;
    reg [31:0] controlStockNo;
    assign price = controlPrice;
    reg [7:0] xpos; reg [7:0] ypos;
    constants constant();
    
    function is_border(
        input [7:0] x, input [7:0] y,
        input [7:0] x_start, input [7:0] y_start,
        input [7:0] x_len, input [7:0] y_len
   );
        reg long_range, short_range;
             
        begin
            long_range = (((x_start <= x) && (x < x_start + x_len + 1)) && 
                ((y_start == y)||((y_start + y_len) == y)));
            short_range = ( ((x_start == x)||(x_start + x_len == x)) && 
                (y_start <= y && y < y_start + y_len));
            is_border = long_range || short_range;
        end
    endfunction

    function draw_letter(
            input [7:0] x, input [7:0] y, 
            input [7:0] x_start, input [7:0] y_start,
            input [24:0] char_pattern); begin
        if ((x >= x_start && (x - x_start < 5)) //within x range
        && (y >= y_start && (y - y_start < 5)) //within y range
        ) begin
            draw_letter = char_pattern[24 - ((x - x_start) + (5 * (y - y_start)))];
            end 
        end
    endfunction

    reg pressed;
    reg [3:0] pageNo = 4'd0;

    reg [4:0] state = 0;
    wire clk_10000hz;
    clk_counter #(5_000, 30)    clk_100hz_module(clk, clk_10000hz);  // Looks like PWM

    always @ (posedge clk_10000hz) begin
        state <= state + 1;
        if (state == 0) begin 
            controlSeg <= constant.num0;
            controlDp <= 0;
            controlAn <= 4'b1110;
        end else if (state == 1) begin 
            controlSeg <= constant.num1;
            controlDp <= 0;
            controlAn <= 4'b1101;
        end else if (state == 2) begin 
            controlSeg <= constant.num2;
            controlDp <= 0;
            controlAn <= 4'b1011;
        end else if (state == 3) begin 
            controlSeg <= constant.num3;
            controlDp <= 0;
            controlAn <= 4'b0111;
            state <= 0; // Reset
        end  
    end

    always @ (*) begin
        xpos = pixel_index % 96;
        ypos = pixel_index / 96;
        
        case (pageNo)
            0: begin
                if ((xpos > 25 && xpos < 31) && (ypos > 29 && ypos < 35)) begin
                    pixel_data <= draw_letter(xpos, ypos, 26, 30, constant.charS) ? constant.BLACK : constant.WHITE;
                end else if ((xpos > 31 && xpos < 37) && (ypos > 29 && ypos < 35)) begin
                    pixel_data <= draw_letter(xpos, ypos, 32, 30, constant.charE) ? constant.BLACK : constant.WHITE;
                end else if ((xpos > 37 && xpos < 43) && (ypos > 29 && ypos < 35)) begin
                    pixel_data <= draw_letter(xpos, ypos, 38, 30, constant.charT) ? constant.BLACK : constant.WHITE;
                end else if ((xpos > 49 && xpos < 55) && (ypos > 29 && ypos < 35)) begin
                    pixel_data <= draw_letter(xpos, ypos, 50, 30, constant.charP) ? constant.BLACK : constant.WHITE;
                end else if ((xpos > 55 && xpos < 61) && (ypos > 29 && ypos < 35)) begin
                    pixel_data <= draw_letter(xpos, ypos, 56, 30, constant.charR) ? constant.BLACK : constant.WHITE;
                end else if ((xpos > 61 && xpos < 67) && (ypos > 29 && ypos < 35)) begin
                    pixel_data <= draw_letter(xpos, ypos, 62, 30, constant.charI) ? constant.BLACK : constant.WHITE;
                end else if ((xpos > 67 && xpos < 73) && (ypos > 29 && ypos < 35)) begin
                    pixel_data <= draw_letter(xpos, ypos, 68, 30, constant.charC) ? constant.BLACK : constant.WHITE;
                end else if ((xpos > 73 && xpos < 79) && (ypos > 29 && ypos < 35)) begin
                    pixel_data <= draw_letter(xpos, ypos, 74, 30, constant.charE) ? constant.BLACK : constant.WHITE;
                end else pixel_data <= constant.WHITE;
            end
            1: begin
                
            end
        endcase

        /*
        sample code for button
        if (is_border(xpos, ypos, 8, 8, 33, 9)) begin
                pixel_data <= btnState == 8'd0 ? constant.GREEN : constant.BLACK;
            end else if ((xpos > 10 && xpos < 16) && (ypos > 10 && ypos < 16)) begin
                pixel_data <= draw_letter(xpos, ypos, 11, 11, constant.charS) ? constant.RED : constant.WHITE;
            end else if ((xpos > 16 && xpos < 22) && (ypos > 10 && ypos < 16)) begin
                pixel_data <= draw_letter(xpos, ypos, 17, 11, constant.charL) ? constant.RED : constant.WHITE;
            end else if ((xpos > 22 && xpos < 28) && (ypos > 10 && ypos < 16)) begin
                pixel_data <= draw_letter(xpos, ypos, 23, 11, constant.charA) ? constant.RED : constant.WHITE;
            end else if ((xpos > 28 && xpos < 34) && (ypos > 10 && ypos < 16)) begin
                pixel_data <= draw_letter(xpos, ypos, 29, 11, constant.charV) ? constant.RED : constant.WHITE;
            end else if ((xpos > 34 && xpos < 40) && (ypos > 10 && ypos < 16)) begin
                pixel_data <= draw_letter(xpos, ypos, 35, 11, constant.charE) ? constant.RED : constant.WHITE;
            end else if (is_border(xpos, ypos, 45, 8, 39, 9)) begin
                pixel_data <= btnState == 8'd1 ? constant.GREEN : constant.BLACK;
            end else if ((xpos > 47 && xpos < 53) && (ypos > 10 && ypos < 16)) begin
                pixel_data <= draw_letter(xpos, ypos, 48, 11, constant.charM) ? constant.BLUE : constant.WHITE;
            end else if ((xpos > 53 && xpos < 59) && (ypos > 10 && ypos < 16)) begin
                pixel_data <= draw_letter(xpos, ypos, 54, 11, constant.charA) ? constant.BLUE : constant.WHITE;
            end else if ((xpos > 59 && xpos < 65) && (ypos > 10 && ypos < 16)) begin
                pixel_data <= draw_letter(xpos, ypos, 60, 11, constant.charS) ? constant.BLUE : constant.WHITE;
            end else if ((xpos > 65 && xpos < 71) && (ypos > 10 && ypos < 16)) begin
                pixel_data <= draw_letter(xpos, ypos, 66, 11, constant.charT) ? constant.BLUE : constant.WHITE;
            end else if ((xpos > 71 && xpos < 77) && (ypos > 10 && ypos < 16)) begin
                pixel_data <= draw_letter(xpos, ypos, 72, 11, constant.charE) ? constant.BLUE : constant.WHITE;
            end else if ((xpos > 77 && xpos < 83) && (ypos > 10 && ypos < 16)) begin
                pixel_data <= draw_letter(xpos, ypos, 78, 11, constant.charR) ? constant.BLUE : constant.WHITE;
            end else pixel_data <= constant.WHITE;
        end
    */
    end
    
endmodule
