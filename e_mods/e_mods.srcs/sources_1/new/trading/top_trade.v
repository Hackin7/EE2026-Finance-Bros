`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//  STUDENT A NAME: 
//  STUDENT B NAME:
//  STUDENT C NAME: 
//  STUDENT D NAME:  
//
//////////////////////////////////////////////////////////////////////////////////


module top_trade (
    // Control
    input clk,
    // LEDs, Switches, Buttons
    input btnC, btnU, btnL, btnR, btnD, input [15:0] sw, output [15:0] led,
    // 7 Segment Display
    output [6:0] seg, output dp, output [3:0] an,
    // UART
    input rx, output tx,
    // OLED PMOD
    inout [7:0] JB,
    inout mouse_ps2_clk, mouse_ps2_data
);
    //// UART //////////////////////////////////////////////
    parameter DBITS = 8;
    parameter UART_FRAME_SIZE = 8;
    wire uart_tx_trigger;
    wire [UART_FRAME_SIZE*DBITS-1:0] uart_rx;
    wire [UART_FRAME_SIZE*DBITS-1:0] uart_tx;
    // Complete UART Core
    uart_module 
        #(
            .FIFO_IN_SIZE(UART_FRAME_SIZE),
            .FIFO_OUT_SIZE(UART_FRAME_SIZE),
            .FIFO_OUT_SIZE_EXP(32)
        ) 
        UART_UNIT
        (
            .clk_100MHz(clk),
            .rx(rx), .tx(tx),
            // .rx_full(rx_full), .rx_empty(rx_empty), .rx_tick(rx_tick),
            .rx_out(uart_rx),
            .tx_trigger(uart_tx_trigger),
            .tx_in(uart_tx)
        );
    
    //// Slave Trade Module //////////////////////////////////////////////////////////////////////////////////////////////////
    wire master_reset;
    wire [15:0] master_led; 
    wire [6:0] master_seg;
    wire master_dp;
    wire [3:0] master_an;


    wire master_uart_tx_trigger;
    wire master_uart_tx;
    wire trigger;
    wire [7:0] send_status;
    trade_packet_former trade_packet();
    trade_module_slave 
        #(
         .DBITS(DBITS), .UART_FRAME_SIZE(UART_FRAME_SIZE), .RX_TIMEOUT(100_000_000)
        )
        trade_slave (
        .clk_100MHz(clk), .reset(),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .uart_tx_trigger(uart_tx_trigger),
        // Trade Parameters
        .tx_type(trade_packet.TYPE_BUY),
        .tx_account_id(4),
        .tx_stock_id(1),
        .tx_qty(2),
        .tx_price(3),
        .trigger(trigger),
        .send_status(send_status),

        // Debugging Ports
        .sw(sw), .led(led)
    );
endmodule
