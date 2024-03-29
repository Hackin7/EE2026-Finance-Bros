`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.03.2024 12:21:43
// Design Name: 
// Module Name: module_slave
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


module module_master #(
    parameter DBITS=8, UART_FRAME_SIZE=8
)(
    // Control
    input reset, input clk,
    // LEDs, Switches, Buttons
    input btnC, btnU, btnL, btnR, btnD, input [15:0] sw, output [15:0] led,
    // 7 Segment Display
    output [6:0] seg, output dp, output [3:0] an,
    // UART
    input [UART_FRAME_SIZE*DBITS-1:0] uart_rx,
    output [UART_FRAME_SIZE*DBITS-1:0] uart_tx,
    output uart_tx_trigger,
    output uart_rx_clear,
    // OLED
    input [12:0] oled_pixel_index, output reg [15:0] oled_pixel_data,
    // Mouse - NOT NEEDED
    input [11:0] mouse_xpos,  mouse_ypos, input [3:0] mouse_zpos,
    input mouse_left_click, mouse_middle_click, mouse_right_click, mouse_new_event
);

    parameter NO_STOCKS = 3;
    parameter BITWIDTH_NO_STOCKS = 2;
    parameter BITWIDTH_STOCKS_PRICE = 8;
    parameter BITWIDTH_STOCKS_THRESHOLD = 8;
    parameter BITWIDTH_STOCKS = BITWIDTH_STOCKS_PRICE + BITWIDTH_STOCKS_THRESHOLD; // 255
    wire [NO_STOCKS * BITWIDTH_STOCKS - 1 : 0] stocks;

    parameter NO_ACCOUNTS = 3;
    parameter BITWIDTH_NO_ACCOUNTS = 2;
    parameter BITWIDTH_ACCT_BALANCE = 32;
    parameter BITWIDTH_ACCT_STOCKS = 8;
    parameter BITWIDTH_ACCT = BITWIDTH_ACCT_BALANCE + BITWIDTH_ACCT_STOCKS*NO_STOCKS;
    wire [NO_ACCOUNTS * BITWIDTH_ACCT - 1 : 0] accounts;

    trade_module_master 
        #(
         .DBITS(8), .UART_FRAME_SIZE(8)
        )
        trade_slave (
        .clk_100MHz(clk), .reset(),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .uart_tx_trigger(uart_tx_trigger),
        .uart_rx_clear(uart_rx_clear),
        
        // Debugging Ports
        .sw(sw), .led(led), 
        .debug_accounts(accounts),
        .debug_stocks(stocks)
    );

     /* --- Account ----------------------------------------------*/
     function [BITWIDTH_STOCKS_PRICE-1:0] stock_get_price(
        input [BITWIDTH_NO_STOCKS-1:0] index
    );
        begin
            stock_get_price = stocks >> (BITWIDTH_STOCKS*index);
        end
    endfunction
    function [BITWIDTH_ACCT_BALANCE-1:0] account_get_balance(
        input [BITWIDTH_NO_ACCOUNTS-1:0] index
    );
        begin
            account_get_balance = accounts >> (BITWIDTH_ACCT*index);
        end
    endfunction

    function [BITWIDTH_ACCT_STOCKS-1:0] account_get_stock(
        input [BITWIDTH_NO_ACCOUNTS-1:0] index, 
        input [BITWIDTH_NO_STOCKS-1:0] stock_index
    );
        begin
            account_get_stock = accounts >> (
                BITWIDTH_ACCT*index + BITWIDTH_ACCT_BALANCE + (stock_index * BITWIDTH_ACCT_STOCKS)
            );
        end
    endfunction
    
    function [NO_ACCOUNTS * BITWIDTH_ACCT - 1 : 0] account_update_balance(
        input [BITWIDTH_NO_ACCOUNTS-1:0] index, 
        input [BITWIDTH_ACCT_BALANCE-1:0] new_value,
        input [NO_ACCOUNTS * BITWIDTH_ACCT - 1 : 0] new_accounts
    ); begin
        // Bitmask = (((8'hff) << (BITWIDTH_ACCT*index)));
        account_update_balance =  (
            (
                new_accounts &    
                ~((32'hffffffff) << (BITWIDTH_ACCT*index))
            ) | (new_value << (BITWIDTH_ACCT*index))
        );
    end
    endfunction

    function [NO_ACCOUNTS * BITWIDTH_ACCT - 1 : 0] account_update_stock(
        input [BITWIDTH_NO_ACCOUNTS-1:0] index, 
        input [BITWIDTH_NO_STOCKS-1:0] stock_index,
        input [BITWIDTH_ACCT_STOCKS-1:0] new_value,
        input [NO_ACCOUNTS * BITWIDTH_ACCT - 1 : 0] new_accounts
    ); begin
        account_update_stock =  (
            (
                new_accounts &    
                ~((8'hff) << (BITWIDTH_ACCT*index + BITWIDTH_ACCT_BALANCE + (stock_index * BITWIDTH_ACCT_STOCKS)) )
            ) | (new_value << (BITWIDTH_ACCT*index + BITWIDTH_ACCT_BALANCE + (stock_index * BITWIDTH_ACCT_STOCKS)) )
        );
    end
    endfunction
    /* --- OLED ------------------------------------------------------------- */

    //constants library
    constants constant();

    reg [7:0] xpos; reg [7:0] ypos;

    wire [8*(4)-1:0] num_string1, num_string2, num_string3, 
                     num_string4, num_string5, num_string6;
    text_num_val_mapping text_num1_module(account_get_balance(0), num_string1);
    text_num_val_mapping text_num2_module(account_get_balance(1), num_string2);
    text_num_val_mapping text_num3_module(account_get_balance(2), num_string3);
    text_num_val_mapping text_num4_module(stock_get_price(0), num_string4);
    text_num_val_mapping text_num5_module(stock_get_price(1), num_string5);
    text_num_val_mapping text_num6_module(stock_get_price(2), num_string6);


    wire [15:0] num1_pixel_data;
    text_dynamic #(14) text_num_display_module(
        .x(xpos), .y(ypos), 
        .color(constant.CYAN), .background(constant.BLACK), 
        .text_y_pos(10), 
        .string({num_string1, " ", num_string2, " ", num_string3}), 
        .offset(0), 
        .repeat_flag(0), .x_pos_offset(0), .pixel_data(num1_pixel_data));

    wire [15:0] num2_pixel_data;
    text_dynamic #(14) text_num2_display_module(
        .x(xpos), .y(ypos), 
        .color(constant.CYAN), .background(constant.BLACK), 
        .text_y_pos(20), 
        .string({num_string4, " ", num_string5, " ", num_string6}), 
        .offset(0), 
        .repeat_flag(0), .x_pos_offset(0), .pixel_data(num2_pixel_data));

    always @ (*) begin
        xpos = oled_pixel_index % 96;
        ypos = oled_pixel_index / 96;
        oled_pixel_data <= num1_pixel_data | num2_pixel_data;
    end
endmodule

