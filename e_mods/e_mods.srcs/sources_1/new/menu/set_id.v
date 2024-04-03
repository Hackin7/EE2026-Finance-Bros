`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.03.2024 14:38:00
// Design Name: 
// Module Name: set_id
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


module set_id(
    // Control
    input clk, reset,
    // LEDs, Switches, Buttons
    input btnC, btnU, btnL, btnR, btnD, input [15:0] sw,
    input [12:0] pixel_index,
    output [15:0] oled_pixel_data,
    // OLED Text
    output [15:0] text_colour, 
    output [8*15*5-1:0] text_lines,

    output [6:0] seg, output dp, output [3:0] an,
    output reg [31:0] account_id,
    output reg done = 0
    );

    constants constant();
    reg [7:0] xpos, ypos;
    reg [15:0] pixel_data;
    assign oled_pixel_data = pixel_data;
    reg [31:0] key_in_value;
    reg prev_btnC=0, prev_btnU=0, prev_btnL=0, prev_btnR=0, prev_btnD=0;
    reg debounce = 0;
    reg [31:0] debounce_timer = 0;
    parameter DEBOUNCE_TIME = 30_000_000; //100ms
    
    task button_control(); begin
        if (debounce) begin
            debounce_timer <= debounce_timer + 1;
            if (debounce_timer == DEBOUNCE_TIME - 1) begin
                debounce <= 0;
                debounce_timer <= 0;
            end
        end else begin
            if (prev_btnU == 1 && btnU == 0) begin 
                key_in_value <= key_in_value == 9999 ? 0 : key_in_value + 1;
                debounce <= 1;
            end

            if (prev_btnD == 1 && btnD == 0) begin
                key_in_value <= key_in_value == 0 ? 9999 : key_in_value - 1;
                debounce <= 1;
            end

            if (prev_btnC == 1 && btnC == 0) begin
                debounce <= 1;
                account_id <= key_in_value;
                done <= 1;
            end
            prev_btnC <= btnC; prev_btnU <= btnU; prev_btnL <= btnL; 
            prev_btnR <= btnR; prev_btnD <= btnD;
        end
    end 
    endtask
    
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

    wire [8*4-1:0] account_num;
    wire [15:0] account_num_pixel_data;
    text_num_val_mapping price_num_module(key_in_value, account_num);

    assign text_colour = (
        (ypos < 10) ? constant.WHITE : 
        constant.CYAN
    );
    assign text_lines = {
        "SET ACCOUNT ID ", 
        {account_num, "           "}, 
        "               ",
        "               ",
        "               "
    };

    always @ (posedge clk) begin
        if (reset) begin
            key_in_value <= 0;
            prev_btnC<=0; prev_btnU<=0; prev_btnL<=0; prev_btnR<=0; prev_btnD<=0;
        end else begin
            button_control();
        end
    end
    
    always @ (*) begin
        xpos <= pixel_index % 96;
        ypos <= pixel_index / 96;
        
        pixel_data <= 0; //account_id_pixel_data | account_num_pixel_data;
    end
endmodule
