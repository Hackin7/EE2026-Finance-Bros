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
    input [12:0] oled_pixel_index, output [15:0] oled_pixel_data,
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
         .DBITS(DBITS), .UART_FRAME_SIZE(UART_FRAME_SIZE)
        )
        trade_slave (
        .clk_100MHz(clk), .reset(),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .uart_tx_trigger(uart_tx_trigger),
        .uart_rx_clear(uart_rx_clear),
        
        // Debugging Ports
        .sw(sw), .led(led)
    );
endmodule

