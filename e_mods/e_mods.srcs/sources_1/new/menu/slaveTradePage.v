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


module slaveTradePage(
    // Control
    input clk, input reset, 
    // LEDs, Switches, Buttons
    input btnC, btnU, btnL, btnR, btnD, input [15:0] sw,
    input [12:0] pixel_index,
    //output [15:0] oled_pixel_data,
    output [8*15*7-1:0] text_lines,
    output [15:0] text_colour,
    output [6:0] seg, output dp, output [3:0] an,
    output reg [31:0] stock_id, 
    output reg [31:0] price, 
    output reg [31:0] quantity, 
    output reg action,
    output reg done = 0
    );
    
    
    constants constant();
    reg [31:0] timeout = 32'd1;
    
    /* price adjustment code --------------------------------------------------------------*/
    reg [15:0] key_in_value = 16'd0010;
    reg prev_btnC=0, prev_btnU=0, prev_btnL=0, prev_btnR=0, prev_btnD=0;
    reg buy_sell_state = 0;

    reg debounce = 0;
    reg [31:0] debounce_timer = 0;
    parameter DEBOUNCE_TIME = 30_000_000; // 100ms

    /* State Machine Code ------------------------------------------------------------------*/
    reg [3:0] pageNo = 4'd0;
    task nextState();
    begin
        if (pageNo == 0) begin
            stock_id <= key_in_value;
            key_in_value <= 0;
            pageNo <= 1;
        end else if (pageNo == 1) begin
            price <= key_in_value;
            key_in_value <= 0;
            pageNo <= 2;

        end else if (pageNo == 2) begin
            quantity <= key_in_value;
            key_in_value <= 0;
            pageNo <= 3;
        end else if (pageNo == 3) begin
            action <= buy_sell_state;
            pageNo <= 4;
            done <= 1;
        end else begin
            pageNo <= 0;
        end
    end
    endtask
    
    task button_control();
    begin
        if (debounce) begin
            debounce_timer <= debounce_timer + 1;
            if (debounce_timer == DEBOUNCE_TIME-1) begin
                debounce <= 0;
                debounce_timer <= 0;
            end
        end else begin
            if (prev_btnU == 1 && btnU == 0) begin
                key_in_value <= key_in_value == 9999 ? 0 : key_in_value + (sw[15] ? 1000 : (sw[14] ? 100 : (sw[13] ? 10 : 1)));
                debounce <= 1;
            end
            
            if (prev_btnD == 1 && btnD == 0) begin
                key_in_value <= key_in_value == 0 ? 9999 : key_in_value - (sw[15] ? 1000 : (sw[14] ? 100 : (sw[13] ? 10 : 1)));
                debounce <= 1;
            end

            if (prev_btnC == 1 && btnC == 0) begin
                nextState();
                debounce <= 1;
            end
            
            if (pageNo == 3) begin
                if ((prev_btnL == 1 && btnL == 0) | (prev_btnR == 1 && btnR == 0)) begin
                buy_sell_state <= buy_sell_state == 0 ? 1 : 0;
                debounce <= 1;
                end
            end
            
            prev_btnC <= btnC; prev_btnU <= btnU; prev_btnL <= btnL; 
            prev_btnR <= btnR; prev_btnD <= btnD;
        end
    end
    endtask
    

    always @ (posedge clk) begin
        if (reset) begin
            pageNo <= 4'd0;
            key_in_value <= 0;
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
    //assign oled_pixel_data = pixel_data;
    wire [7:0] xpos = pixel_index % 96, ypos = pixel_index / 96;

    // Text module
        
 /*   wire [15:0] setter_pixel_data;
    text_dynamic #(12) setter_module(
            .x(xpos), .y(ypos), 
            .color(constant.WHITE), .background(constant.BLACK), 
            .text_y_pos(0), .string(pageNo == 1 ? "SET PRICE   " :
                (pageNo == 2 ? "SET QUANTITY" : "SET STOCK ID")
            ), .offset(0), //12*6), 
            .repeat_flag(0), .x_pos_offset(0), .pixel_data(setter_pixel_data));
            */
    wire [8*4-1:0] num_string;
    wire [15:0] num_string_pixel_data;
    text_num_val_mapping price_num_module(key_in_value, num_string);

    wire [8*15*7-1:0] add_trade_lines = {pageNo == 0 ? "SET STOCK ID   " : (
                                         pageNo == 1 ? "SET PRICE      " : (
                                         pageNo == 2 ? "SET QUANTITY   " : 
                                                       "ACTION         ")),
                                         pageNo == 3 ? (buy_sell_state ? "SELL" : "BUY " ) : (pageNo < 3 ? num_string : "    "), "           ",
                                        (pageNo == 0 ? (key_in_value == 0000 ? "AAPL" :
                                                        key_in_value == 0001 ? "GOOG" :
                                                                               "BABA"):
                                                                               "    "), "           ",
                                                                                    "               ",
                                                                                    "               ",
                                                                                    "               ",
                                                                                    "               "};
    assign text_lines = add_trade_lines;
    wire [15:0] add_trade_text_colour = (10 <= ypos && ypos < 20) ? constant.CYAN : constant.WHITE;
    assign text_colour = add_trade_text_colour;


/*    text_dynamic #(4) text_num_display_module(
        .x(xpos), .y(ypos), 
        .color(constant.CYAN), .background(constant.BLACK), 
        .text_y_pos(10), .string(num_string), .offset(0), 
        .repeat_flag(0), .x_pos_offset(0), .pixel_data(num_string_pixel_data));
        
        wire [15:0] select_pixel_data;
        text_dynamic #(6) select_module(
            .x(xpos), .y(ypos), 
            .color(constant.WHITE), .background(constant.BLACK), 
            .text_y_pos(0), .string("ACTION"), .offset(0), //12*6), 
            .repeat_flag(0), .x_pos_offset(0), .pixel_data(select_pixel_data));    
            
        wire [15:0] buy_pixel_data;
        text_dynamic #(3) buy_module(
            .x(xpos), .y(ypos), 
            .color(buy_sell_state == 0 ? constant.RED : constant.WHITE), .background(constant.BLACK), 
            .text_y_pos(10), .string("BUY"), .offset(0), //12*6), 
            .repeat_flag(0), .x_pos_offset(0), .pixel_data(buy_pixel_data));
                    
        wire [15:0] sell_pixel_data;
        text_dynamic #(4) sell_module(
            .x(xpos), .y(ypos), 
            .color(buy_sell_state == 1 ? constant.RED : constant.WHITE), .background(constant.BLACK), 
            .text_y_pos(10), .string("SELL"), .offset(0), //12*6), 
            .repeat_flag(0), .x_pos_offset(20), .pixel_data(sell_pixel_data));
            */

endmodule
