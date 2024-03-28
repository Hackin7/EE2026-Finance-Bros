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
    
    
    constants constant();
    
    
    /* price adjustment code --------------------------------------------------------------*/
    reg [15:0] key_in_value = 8'd1000;
    reg prev_btnC=0, prev_btnU=0, prev_btnL=0, prev_btnR=0, prev_btnD=0;

    reg debounce = 0;
    reg debounce_timer = 0;
    parameter DEBOUNCE_TIME = 50_000_000; // 100ms
    

    task button_control();
    begin
        if (debounce) begin
            if (debounce_timer == DEBOUNCE_TIME-1) begin
                debounce <= 0;
                debounce_timer <= 0;
            end
            debounce <= debounce + 1;
        end else begin
            if (prev_btnU == 1 && btnU == 0) begin
                key_in_value <= key_in_value + 1;
                debounce <= 1;
            end
            
            if (prev_btnD == 1 && btnD == 0) begin
                key_in_value <= key_in_value - 1;
                debounce <= 1;
            end

            if (prev_btnC == 1 && btnC == 0) begin
                nextState();
            end
            prev_btnC <= btnC; prev_btnU <= btnU; prev_btnL <= btnL; 
            prev_btnR <= btnR; prev_btnD <= btnD;
        end
    end
    endtask
    /* State Machine Code ------------------------------------------------------------------*/
    reg [3:0] pageNo = 4'd0;
    task nextState();
    begin
        if (pageNo == 0) begin
            key_in_value <= 0;
            pageNo <= pageNo + 1;
            price <= key_in_value;
        end else if (pageNo == 1) begin
            key_in_value <= 0;
            pageNo <= pageNo + 1;
            qty <= key_in_value;
            done <= 1;
        end else if (pageNo == 2) begin
            key_in_value <= 0;
            pageNo <= pageNo + 1;
        end
    end
    endtask

    always @ (posedge clk) begin
        if (reset) begin
            pageNo <= 4'd0;
            key_in_value <= 2000;
            done <= 1'b0;
            prev_btnC<=0; prev_btnU<=0; prev_btnL<=0; prev_btnR<=0; prev_btnD<=0;
        end else begin
            button_control();
        end
    end

    /* OUTPUT ----------------------------------------------------------------------------------------------------*/
    /* 7 seg ---------------------------------------------------*/
    wire [6:0] seg0, seg1, seg2, seg3;

    seg_val_mapping svm(key_in_value, seg0, seg1, seg2, seg3);
    seg_multiplexer sm(
        clk, 
        seg0, seg1, seg2, seg3,
        1, 1, 1, 1, 
        seg, dp, an
    );
    /* OLED Screen ---------------------------------------------*/
    reg [15:0] pixel_data = 16'b0;
    assign oled_pixel_data = pixel_data;

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
            input [9:0] x, input [9:0] y, 
            input [9:0] x_start, input [9:0] y_start,
            input [24:0] char_pattern
    ); 
       begin
            if ((x >= x_start && (x - x_start < 5)) //within x range
            && (y >= y_start && (y - y_start < 5)) //within y range
            ) 
            begin
                draw_letter = char_pattern[24 - ((x - x_start) + (5 * (y - y_start)))];
            end else begin
                draw_letter= 0;
            end
        end
    endfunction
    
    reg [7:0] xpos; reg [7:0] ypos;
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
                if ((xpos > 5 && xpos < 11) && (ypos > 29 && ypos < 35)) begin
                    pixel_data <= draw_letter(xpos, ypos, 6, 30, constant.charS) ? constant.BLACK : constant.WHITE;
                end else if ((xpos > 11 && xpos < 17) && (ypos > 29 && ypos < 35)) begin
                    pixel_data <= draw_letter(xpos, ypos, 12, 30, constant.charE) ? constant.BLACK : constant.WHITE;
                end else if ((xpos > 17 && xpos < 23) && (ypos > 29 && ypos < 35)) begin
                    pixel_data <= draw_letter(xpos, ypos, 18, 30, constant.charT) ? constant.BLACK : constant.WHITE;
                end else if ((xpos > 29 && xpos < 35) && (ypos > 29 && ypos < 35)) begin
                    pixel_data <= draw_letter(xpos, ypos, 30, 30, constant.charQ) ? constant.BLACK : constant.WHITE;
                end else if ((xpos > 35 && xpos < 41) && (ypos > 29 && ypos < 35)) begin
                    pixel_data <= draw_letter(xpos, ypos, 36, 30, constant.charU) ? constant.BLACK : constant.WHITE;
                end else if ((xpos > 41 && xpos < 47) && (ypos > 29 && ypos < 35)) begin
                    pixel_data <= draw_letter(xpos, ypos, 42, 30, constant.charA) ? constant.BLACK : constant.WHITE;
                end else if ((xpos > 47 && xpos < 53) && (ypos > 29 && ypos < 35)) begin
                    pixel_data <= draw_letter(xpos, ypos, 48, 30, constant.charN) ? constant.BLACK : constant.WHITE;
                end else if ((xpos > 53 && xpos < 59) && (ypos > 29 && ypos < 35)) begin
                    pixel_data <= draw_letter(xpos, ypos, 54, 30, constant.charT) ? constant.BLACK : constant.WHITE;
                end else if ((xpos > 59 && xpos < 65) && (ypos > 29 && ypos < 35)) begin
                    pixel_data <= draw_letter(xpos, ypos, 60, 30, constant.charI) ? constant.BLACK : constant.WHITE;
                end else if ((xpos > 65 && xpos < 71) && (ypos > 29 && ypos < 35)) begin
                    pixel_data <= draw_letter(xpos, ypos, 66, 30, constant.charT) ? constant.BLACK : constant.WHITE;
                end else if ((xpos > 71 && xpos < 77) && (ypos > 29 && ypos < 35)) begin
                    pixel_data <= draw_letter(xpos, ypos, 72, 30, constant.charY) ? constant.BLACK : constant.WHITE;
                end else begin
                    pixel_data <= constant.WHITE;
                end
            end
        endcase
        /* --------------------------------------------------------------------------*/
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
