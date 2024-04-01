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
    output [6:0] seg, output dp, output [3:0] an,
    output reg [31:0] account_id,
    output reg done
    );

    constants constant();
    
    reg [7:0] xpos, ypos;
    reg [15:0] pixel_data;
    assign oled_pixel_data = pixel_data;
    reg [31:0] key_in_value;
    reg prev_btnC=0, prev_btnU=0, prev_btnL=0, prev_btnR=0, prev_btnD=0;
    reg debounce = 0;
    reg debounce_timer = 0;
    parameter DEBOUNCE_TIME = 50_000_000; //100ms
    
    task button_control(); begin
        if (debounce) begin
            if (debounce_timer == DEBOUNCE_TIME - 1) begin
                debounce <= 0;
                debounce_timer <= 0;
            end
            debounce <= debounce + 1;
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

    wire [15:0] account_id_pixel_data;
    text_dynamic #(14) text_module(
            .x(xpos), .y(ypos), 
            .color(constant.WHITE), .background(constant.BLACK), 
            .text_y_pos(0), .string("SET ACCOUNT ID"), .offset(0), //9*6), 
            .repeat_flag(0), .x_pos_offset(0), .pixel_data(account_id_pixel_data));


    wire [8*4-1:0] account_num;
    wire [15:0] account_num_pixel_data;
    text_num_val_mapping price_num_module(key_in_value, account_num);
    text_dynamic #(4) text_num_display_module(
        .x(xpos), .y(ypos), 
        .color(constant.CYAN), .background(constant.BLACK), 
        .text_y_pos(10), .string(account_num), .offset(0), 
        .repeat_flag(0), .x_pos_offset(0), .pixel_data(account_num_pixel_data));
        
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
        
        pixel_data <= account_id_pixel_data | account_num_pixel_data;
    end
endmodule