`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.03.2024 19:46:50
// Design Name: 
// Module Name: menuCode
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


module menuCode#(
    parameter DBITS=8, UART_FRAME_SIZE=8, RX_DEBOUNCE=1, RX_TIMEOUT=100_000_000 // 1s
)(
        input clk, reset,
        input btnC, btnU, btnR, btnL, btnD,
        input [15:0] sw, output [15:0] led, 
        input [12:0] oled_pixel_index, output [15:0] oled_pixel_data,
        output [6:0] seg, output dp, output [3:0] an,
        
        // UART
        input  [UART_FRAME_SIZE*DBITS-1:0] uart_rx,
        output [UART_FRAME_SIZE*DBITS-1:0] uart_tx,
        output uart_tx_trigger,
        output uart_rx_clear
    );
    
    //constants library
    constants constant();
    wire [12:0] pixel_index = oled_pixel_index;
    reg [15:0] pixel_data = 16'b0;
    assign oled_pixel_data = pixel_data;
    reg [6:0] control_seg;
    reg control_dp;
    reg [3:0] control_an;
    assign seg = control_seg;
    assign dp = control_dp;
    assign an = control_an;
    
    //page one
    reg pageOne_reset = 1;
    wire [15:0] pageOne_pixel_data;
    wire [6:0] pageOne_seg;
    wire pageOne_dp;
    wire [3:0] pageOne_an;
    wire [31:0] price, qty, stock_id;
    wire pageOne_done;
    slavePageOne pageOne(
        .clk(clk), .reset(pageOne_reset), .btnC(btnC), .btnU(btnU), .btnR(btnR), .btnL(btnL), .btnD(btnD),
        .sw(sw), .pixel_index(pixel_index), .oled_pixel_data(pageOne_pixel_data),
        .seg(pageOne_seg), .dp(pageOne_dp), .an(pageOne_an),
        .stock_id(stock_id), .price(price), .qty(qty), .done(pageOne_done)
    );


    /* UART Control --------------------------------------------------------------------*/
    assign uart_tx_trigger = 0;
    reg trade_slave_trigger = 1;
    wire [7:0] send_status;
    trade_module_slave 
        #(
         .DBITS(DBITS), .UART_FRAME_SIZE(UART_FRAME_SIZE), .RX_TIMEOUT(100_000_000)
        )
        trade_slave (
        .clk_100MHz(clk), .reset(),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .uart_tx_trigger(uart_tx_trigger),
        .uart_rx_clear(uart_rx_clear),
        // Trade Parameters
        .tx_type(trade_packet.TYPE_BUY),
        .tx_account_id(4),
        .tx_stock_id(1),
        .tx_qty(2),
        .tx_price(3),
        .trigger(trade_slave_trigger),
        .send_status(send_status)
    );
    /* Button Control Code --------------------------------------------------------------*/
    reg prev_btnC=0, prev_btnU=0, prev_btnL=0, prev_btnR=0, prev_btnD=0;

    reg debounce = 0;
    reg debounce_timer = 0;
    parameter DEBOUNCE_TIME = 10_000_000; // 100ms
    

    task button_control();
    begin
        if (debounce) begin
            if (debounce_timer == DEBOUNCE_TIME-1) begin
                debounce <= 0;
                debounce_timer <= 0;
            end
            debounce <= debounce + 1;
        end else begin
            /*if (prev_btnU == 1 && btnU == 0) begin
                key_in_value <= key_in_value + 1;
                debounce <= 1;
            end*/
            prev_btnC <= btnC; prev_btnU <= btnU; prev_btnL <= btnL; 
            prev_btnR <= btnR; prev_btnD <= btnD;
        end
    end
    endtask
    
    /* State Machine Code ------------------------------------------------------------------*/
    reg [3:0] state = 4'd1;
    parameter STATE_INPUT_SLAVE_ID = 0;
    parameter STATE_MENU = 1;
    parameter STATE_ADD_TRADE = 2;
    parameter STATE_FAIL_ADD_TRADE = 3;
    parameter STATE_TABLE_VIEW = 4;

    task state_menu_handle();
    begin
        if (!debounce) begin
            if (prev_btnC == 1 && btnC == 0) begin
                state <= STATE_ADD_TRADE;
                pageOne_reset <= 0;
                debounce <= 1;
            end
            if (prev_btnL == 1 && btnL == 0) begin
                state <= STATE_TABLE_VIEW;
                debounce <= 1;
            end
        end
    end
    endtask

    assign led[5] = pageOne_done;
    assign led[4] = pageOne_reset;
    assign led[3:0] = state;
    /* --- Trade Handler -------------------------------------------*/
    trade_packet_former trade_packet();
    task state_add_trade_handle();
    begin
        if (pageOne_done) begin
            state <= STATE_MENU;
            pageOne_reset <= 1;
        end
    end
    endtask

    always @ (posedge clk) begin
        if (reset) begin
            state <= 4'd0;
        end else if (state == STATE_INPUT_SLAVE_ID) begin
        end else if (state == STATE_MENU) begin
            state_menu_handle();
        end else if (state == STATE_ADD_TRADE) begin
            state_add_trade_handle();
        end else if (state == STATE_FAIL_ADD_TRADE) begin
        end else if (state == STATE_TABLE_VIEW) begin
        end
        button_control();
    end

    /* OLED Layout --------------------------------------------------*/
    always @ (*) begin
        if (state == STATE_INPUT_SLAVE_ID) begin
            pixel_data <= constant.WHITE;
        end else if (state == STATE_MENU) begin
            pixel_data <= constant.GREEN;
        end else if (state == STATE_ADD_TRADE) begin
            pixel_data = pageOne_pixel_data;
            control_seg = pageOne_seg;
            control_dp = pageOne_dp;
            control_an = pageOne_an;
        end else if (state == STATE_FAIL_ADD_TRADE) begin
            pixel_data <= constant.RED;
        end else if (state == STATE_TABLE_VIEW) begin
            pixel_data <= constant.BLUE;
        end
    end

endmodule
