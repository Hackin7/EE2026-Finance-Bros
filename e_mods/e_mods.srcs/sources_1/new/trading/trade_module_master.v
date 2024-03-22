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


module trade_master_packet_former#(
    parameter DBITS=8, UART_FRAME_SIZE=8
)(
    input [7:0] type,
    input [7:0] account_id,
    input [7:0] stock_id,
    input [7:0] qty,
    input [7:0] price,
    output  [UART_FRAME_SIZE*DBITS-1:0] uart_tx
);
    parameter TYPE_INVALID = 0;
    parameter TYPE_BUY = 1;
    parameter TYPE_SELL = 2;
    assign uart_tx = {"[", type, account_id, stock_id, qty, price, 8'b0, "]"};
endmodule

module trade_master_packet_parser#(
    parameter DBITS=8, UART_FRAME_SIZE=8
)(
    input  [UART_FRAME_SIZE*DBITS-1:0] uart_rx,
    output reg [7:0] type,
    output [7:0] account_id,
    output [7:0] stock_id,
    output [7:0] qty,
    output [7:0] price
);

    // Parameters for stock 
    parameter TYPE_INVALID = 0;
    parameter TYPE_OK = 1;
    parameter TYPE_FAIL = 2;

    wire char_first = uart_rx[DBITS*8-1:DBITS*(8-1)];
    wire char_last = uart_rx[7:0];
    wire char_type = uart_rx[DBITS*7-1:DBITS*(7-1)];
    always @ (*) begin
        if (!(char_first == "[" && char_last == "]")) begin
            type <= 0; // invalid type
        end else begin
            type <= char_type;
        end
    end
    
    assign account_id = uart_rx[DBITS*6-1:DBITS*(6-1)];
    assign stock_id = uart_rx[DBITS*5-1:DBITS*(5-1)];
    assign qty = uart_rx[DBITS*4-1:DBITS*(4-1)];
    assign price = uart_rx[DBITS*3-1:DBITS*(3-1)];
endmodule


module trade_module_master #(
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
    // OLED
    input [12:0] oled_pixel_index, output [15:0] oled_pixel_data,
    // Mouse - NOT NEEDED
    input [11:0] mouse_xpos,  mouse_ypos, input [3:0] mouse_zpos,
    input mouse_left_click, mouse_middle_click, mouse_right_click, mouse_new_event
);
endmodule

