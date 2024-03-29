`timescale 1ns / 1ps

module trade_packet_former#(
    parameter DBITS=8, UART_FRAME_SIZE=8
)(
    input [7:0] type,
    input [7:0] account_id,
    input [7:0] stock_id,
    input [7:0] qty,
    input [7:0] price,
    input [32-1:0] balance,
    output  [UART_FRAME_SIZE*DBITS-1:0] uart_tx
);
    parameter TYPE_INVALID = 8'd0;
    parameter TYPE_BUY = 8'd1;
    parameter TYPE_SELL = 8'd2;
    parameter TYPE_OK = 8'd3;
    parameter TYPE_FAIL = 8'd4;
    parameter TYPE_GET_ACCOUNT_BALANCE = 8'd5;
    parameter TYPE_GET_ACCOUNT_STOCKS = 8'd6; // Hardcode all stocks

    parameter TYPE_RETURN_ACCOUNT_BALANCE = 8'd7;
    parameter TYPE_RETURN_ACCOUNT_STOCKS = 8'd8;
    assign uart_tx = ( (type == TYPE_RETURN_ACCOUNT_BALANCE | type == TYPE_RETURN_ACCOUNT_STOCKS) ? 
        {"[", type, balance, 8'b0, "]"}
        :
        {"[", type, account_id, stock_id, qty, price, 8'b0, "]"}
    );
    
endmodule

module trade_packet_parser#(
    parameter DBITS=8, UART_FRAME_SIZE=8
)(
    input  [UART_FRAME_SIZE*DBITS-1:0] uart_rx,
    output [7:0] type, // Not working properly
    output [7:0] account_id,
    output [7:0] stock_id,
    output [7:0] qty,
    output [7:0] price,
    output [32:0] balance
);

    // Parameters for stock 
    parameter TYPE_INVALID = 8'd0;
    parameter TYPE_BUY = 8'd1;
    parameter TYPE_SELL = 8'd2;
    parameter TYPE_OK = 8'd3;
    parameter TYPE_FAIL = 8'd4;
    parameter TYPE_GET_ACCOUNT_BALANCE = 8'd5;
    parameter TYPE_GET_ACCOUNT_STOCKS = 8'd6; // Hardcode all stocks
    parameter TYPE_RETURN_ACCOUNT_BALANCE = 8'd7;
    parameter TYPE_RETURN_ACCOUNT_STOCKS = 8'd8;

    wire [7:0] char_first = uart_rx[63:56];
    wire [7:0] char_last = uart_rx[7:0];
    wire [7:0] char_type = uart_rx[55:48];
    assign type = (char_first == "[" && char_last == "]") ? char_type : TYPE_INVALID;
    
    assign account_id = uart_rx[DBITS*6-1:DBITS*5];
    assign stock_id = uart_rx[DBITS*5-1:DBITS*4];
    assign qty = uart_rx[DBITS*4-1:DBITS*3];
    assign price = uart_rx[DBITS*3-1:DBITS*2];
    assign balance = uart_rx[DBITS*6-1:DBITS*2];
endmodule

