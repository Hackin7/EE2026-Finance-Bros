`timescale 1ns / 1ps

/*
To Test
1. former
2. parser - buggy
3. sending FSM
4. Receiving FSM

States
1. Send information
2. Wait for feedback
3. Parse Feedback
    1. If timeout -> continue
    2. else, halt

*/

module trade_module_slave #(
    parameter DBITS=8, UART_FRAME_SIZE=8, RX_DEBOUNCE=1, RX_TIMEOUT=100_000_000 // 1s
)(
    // General
    input clk_100MHz,               // FPGA clock
    input reset,                    // reset
    // UART
    input  [UART_FRAME_SIZE*DBITS-1:0] uart_rx,
    output [UART_FRAME_SIZE*DBITS-1:0] uart_tx,
    output reg uart_tx_trigger=0,
    output reg uart_rx_clear=0,
    // Trade Buffer
    input [7:0] tx_type,
    input [7:0] tx_account_id,
    input [7:0] tx_stock_id,
    input [7:0] tx_qty,
    input [7:0] tx_price,
    input trigger,
    input encrypted, decrypted,
    output reg [7:0] send_status=0,
    output [31:0] balance, 
    output [7:0] stock1,
    output [7:0] stock2,
    output [7:0] stock3,

    // Debugging //////////////////////////////////////////////////////////
    // Control
    output reg [7:0] fsm_state=2, 
    output reg [32-1:0] fsm_timer=0 
);

    /* State Machine ----------------------------------------------------------*/
    parameter S0 = 8'd0;
    parameter S1 = 8'd1;
    parameter S2 = 8'd2;

    parameter STATUS_IDLE = 8'd0;
    parameter STATUS_PROCESSING = 8'd1;
    parameter STATUS_OK = 8'd2;
    parameter STATUS_FAIL = 8'd3;
    parameter STATUS_RETRIEVED = 8'd4;
    //reg [7:0] fsm_state = 0;
    //reg [32-1:0] fsm_timer = 0;

    // FSM Control Logic
    task fsm_change_state(input [7:0] next_state);
        begin
            fsm_state <= next_state;
            fsm_timer <= 0;
        end
    endtask

    // Main FSM Block
    always @(posedge clk_100MHz) begin
        fsm_timer <= fsm_timer + 1; // for tracking time passed
        if (fsm_state == S0) begin
            fsm_uart_send();
        end else if (fsm_state == S1) begin
            uart_tx_trigger <= 0; // DisableTrigger
            fsm_uart_receive();
        end else if (fsm_state == S2) begin
            fsm_uart_wait();
        end else begin
            fsm_change_state(S2);
        end
    end


    /* Sending Logic ----------------------------------------------------------*/
    trade_packet_former 
        #(
            .DBITS(DBITS), .UART_FRAME_SIZE(UART_FRAME_SIZE)
        ) former (
        .type(tx_type), .account_id(tx_account_id), 
        .stock_id(tx_stock_id), .qty(tx_qty), 
        .price(tx_price), .uart_tx(uart_tx), .encrypted(encrypted)
    );

    task fsm_uart_send();
        begin
            send_status <= STATUS_PROCESSING;
            uart_rx_clear <= 0;
            if (tx_type == former.TYPE_INVALID) begin
                // fsm_timer <= 0; // doesn't matter
            /*end else if (packet_type == parser.TYPE_OK) begin // Catch any sudden receive - will ignore for now
                // clear buffer for 1 cycle
                send_status <= STATUS_OK;
                ; */
                fsm_change_state(S2);
            end else begin
                uart_tx_trigger <= 1; // Trigger on for 1 clock cycle
                fsm_change_state(S1);
            end
        end
    endtask

    /* Receiving Logic ----------------------------------------------------------*/
    reg [7:0] extra_state = 0;
    wire [7:0] packet_type;
    wire [7:0] packet_account_id;
    wire [7:0] packet_stock_id;
    wire [7:0] packet_qty;
    wire [7:0] packet_price;
    wire [2:0] seed = 0; //account_id[2:0];
    trade_packet_parser 
        #(
            .DBITS(DBITS), 
            .UART_FRAME_SIZE(UART_FRAME_SIZE)
        ) parser (
        .seed(seed),
        .encrypted(decrypted),
        .uart_rx(uart_rx), 
        .type(packet_type), 
        .account_id(packet_account_id), 
        .stock_id(packet_stock_id), 
        .qty(packet_qty), 
        .price(packet_price), 
        .balance(balance)
    );
    assign stock1 = packet_account_id;
    assign stock2 = packet_stock_id;
    assign stock3 = packet_qty;
    
    task fsm_uart_receive();
    begin
        extra_state <= 8'b11;
        if (tx_type == former.TYPE_INVALID) begin 
            // Not sending anything 
            // Reset to idle state
            //send_status <= STATUS_IDLE;
            fsm_change_state(S2);
        end else if (fsm_timer <= RX_DEBOUNCE) begin
            // Ignore because waiting
        end else if (packet_type == parser.TYPE_INVALID) begin
            // do nothing
            extra_state <= 8'b111;
            if (fsm_timer >= RX_TIMEOUT) begin
                fsm_change_state(S0);
            end
        end else if (packet_type == parser.TYPE_OK) begin
            // clear buffer for 1 cycle
            extra_state <= 8'b1111;
            send_status <= STATUS_OK;
            fsm_change_state(S2);
        end else if (packet_type == parser.TYPE_FAIL) begin
            // do nothing
            extra_state <= 8'b11111;
            send_status <= STATUS_FAIL;
            fsm_change_state(S2);
        end else if (packet_type == parser.TYPE_RETURN_ACCOUNT_BALANCE) begin
            // clear buffer for 1 cycle
            extra_state <= 8'b1111;
            send_status <= STATUS_RETRIEVED;
            fsm_change_state(S2);
        end else if (packet_type == parser.TYPE_RETURN_ACCOUNT_STOCKS) begin
            // clear buffer for 1 cycle
            extra_state <= 8'b1111;
            send_status <= STATUS_RETRIEVED;
            fsm_change_state(S2);
        end else begin
            // do nothing
            extra_state <= 8'b111;
            if (fsm_timer >= RX_TIMEOUT) begin
                fsm_change_state(S0);
            end
        end
    end
    endtask

    task fsm_uart_wait();
    begin
        extra_state <= 8'b111111;
        send_status <= STATUS_IDLE;
        if (trigger) begin
            send_status <= STATUS_PROCESSING;
            uart_rx_clear <= 1;
            fsm_change_state(S0);
        end
    end
    endtask
endmodule


