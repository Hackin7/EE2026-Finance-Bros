`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.02.2024 09:21:18
// Design Name: 
// Module Name: main
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


module main(input clk_100MHz,       // from Basys 3
    input reset,            // btnC on Basys 3
    output hsync,           // to VGA connector
    output vsync,           // to VGA connector
    output [11:0] rgb,      // to DAC, 3 RGB bits to VGA connector
    
    
    input rx,               // USB-RS232 Rx
    output tx,              // USB-RS232 Tx
    input btn,              // btnL (read and write FIFO operation)
    input [15:0] sw,
    output [3:0] an,        // 7 segment display digits
    output [0:6] seg,       // 7 segment display segments
    output [15:0] led       // extra tests
    );

    parameter DBITS = 8;
    parameter UART_FRAME_SIZE = 4;
    //// UART Setup ////////////////////////////////////////////////////
    wire  btn_tick;
    wire [7:0] rec_data, rec_data1;
    
    wire [UART_FRAME_SIZE*DBITS-1:0] tx_fifo_out;
    
    wire [UART_FRAME_SIZE*DBITS-1:0] rx_out;
    wire rx_full, rx_empty, rx_tick;
    // Complete UART Core
    uart_top 
        #(
            .FIFO_IN_SIZE(UART_FRAME_SIZE),
            .FIFO_OUT_SIZE(UART_FRAME_SIZE),
            .FIFO_OUT_SIZE_EXP(32)
        ) 
        UART_UNIT
        (
            .clk_100MHz(clk_100MHz),
            .write_data(rec_data1),
            
            .rx(rx),
            .tx(tx),
            
            .rx_full(rx_full),
            .rx_empty(rx_empty),
            .rx_tick(rx_tick),
            .rx_out(rx_out),
            
            .tx_trigger(btn),
            .tx_in({sw, sw, sw, sw})
        );
        
    reg t=0;
    always @(posedge clk_100MHz) begin
        // send A__B
        if (rx_out[7:0] == 65 & rx_out[DBITS*UART_FRAME_SIZE-1:DBITS*(UART_FRAME_SIZE-1)] == 66) begin
            t <= 1;
        end
        if (rx_out[7:0] == 65 & rx_out[DBITS*UART_FRAME_SIZE-1:DBITS*(UART_FRAME_SIZE-1)] == 67) begin
            t <= 0;
        end
    end
    assign led[14] = t;
    assign led[15] = (rx_out[7:0] == 65 & rx_out[31:24] == 66);
    assign led[15:8] = tx_fifo_out[7:0];
    assign led[7:0] = rx_out[7:0];
endmodule
