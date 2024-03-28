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
    output reg [7:0] send_status=0,

    // Debugging //////////////////////////////////////////////////////////
    // Control
    input [15:0] sw, output [15:0] led, 
    output reg [7:0] fsm_state=0, 
    output reg [32-1:0] fsm_timer=0 
);

    /* State Machine ----------------------------------------------------------*/
    parameter S0 = 8'd0;
    parameter S1 = 8'd1;
    parameter S2 = 8'd2;

    parameter STATUS_PROCESSING = 8'd0;
    parameter STATUS_OK = 8'd1;
    parameter STATUS_FAIL = 8'd2;
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
            fsm_change_state(S0);
        end
    end


    /* Sending Logic ----------------------------------------------------------*/
    /* Buffer can be in the main control logic 
    reg tx_buffer_ctrl_clear = 0;
    reg [7:0] tx_buffer_type;
    reg [7:0] tx_buffer_account_id;
    reg [7:0] tx_buffer_stock_id;
    reg [7:0] tx_buffer_qty;
    reg [7:0] tx_buffer_price;
    always @(posedge clk_100MHz) begin
        if (tx_buffer_ctrl_clear) begin
            tx_buffer_type <= parser.TYPE_INVALID;
        end else if (tx_buffer_ctrl_store) begin
            tx_buffer_type <= tx_type;
            tx_buffer_account_id <= tx_account_id;
            tx_buffer_stock_id <= tx_stock_id;
            tx_buffer_qty <= tx_qty;
            tx_buffer_price <= tx_price;
        end
    end
    trade_packet_former 
        #(
            .DBITS(DBITS), .UART_FRAME_SIZE(UART_FRAME_SIZE)
        ) former (
        .type(tx_buffer_type), .account_id(tx_buffer_account_id), 
        .stock_id(tx_buffer_stock_id), .qty(tx_buffer_qty), 
        .price(tx_buffer_price), .uart_tx(uart_tx)
    );
    */
    trade_packet_former 
        #(
            .DBITS(DBITS), .UART_FRAME_SIZE(UART_FRAME_SIZE)
        ) former (
        .type(tx_type), .account_id(tx_account_id), 
        .stock_id(tx_stock_id), .qty(tx_qty), 
        .price(tx_price), .uart_tx(uart_tx)
    );

    task fsm_uart_send();
        begin
            uart_rx_clear <= 0;
            if (tx_type == former.TYPE_INVALID) begin
                // fsm_timer <= 0; // doesn't matter
            /*end else if (packet_type == parser.TYPE_OK) begin // Catch any sudden receive - will ignore for now
                // clear buffer for 1 cycle
                send_status <= STATUS_OK;
                fsm_change_state(S2); */
            end else begin
                uart_tx_trigger <= 1; // Trigger on for 1 clock cycle
                fsm_change_state(S1);
            end
        end
    endtask

    /* Receiving Logic ----------------------------------------------------------*/
    wire [7:0] packet_type;
    wire [7:0] packet_account_id;
    wire [7:0] packet_stock_id;
    wire [7:0] packet_qty;
    wire [7:0] packet_price;
    trade_packet_parser 
        #(
            .DBITS(DBITS), 
            .UART_FRAME_SIZE(UART_FRAME_SIZE)
        ) parser (
        .uart_rx(uart_rx), 
        .type(packet_type), 
        .account_id(packet_account_id), 
        .stock_id(packet_stock_id), 
        .qty(packet_qty), 
        .price(packet_price)
    );
    
    task fsm_uart_receive();
    begin
        if (tx_type == former.TYPE_INVALID || fsm_timer <= RX_DEBOUNCE) begin
            // do nothing, ignore everything because mode disabled
        end else if (packet_type == parser.TYPE_INVALID) begin
            // do nothing
            if (fsm_timer >= RX_TIMEOUT) begin
                fsm_change_state(S0);
            end
        end else if (packet_type == parser.TYPE_OK) begin
            // clear buffer for 1 cycle
            send_status <= STATUS_OK;
            fsm_change_state(S2);
        end else if (packet_type == parser.TYPE_FAIL) begin
            // do nothing
            send_status <= STATUS_FAIL;
            fsm_change_state(S2);
        end
    end
    endtask

    task fsm_uart_wait();
    begin
        if (trigger) begin
            send_status <= STATUS_PROCESSING;
            uart_rx_clear <= 1;
            fsm_change_state(S0);
        end
    end
    endtask
    
    /* Debugging ---------------------------------------------------------------*/
    // parser not working
    assign led[15:8] = (
        sw[4:0] == 0 ? packet_type : ( // Buggy
        sw[4:0] == 1 ? packet_account_id : (   
        sw[4:0] == 2 ? packet_stock_id : (
        sw[4:0] == 3 ? packet_qty : (
        sw[4:0] == 4 ? packet_price : (
        sw[4:0] == 5 ? uart_rx[7:0] : (
        sw[4:0] == 6 ? uart_rx[15:8] : (
        sw[4:0] == 7 ? uart_rx[23:16] : (
        sw[4:0] == 8 ? uart_rx[31:24] : (
        sw[4:0] == 9 ? uart_rx[39:32] : (
        sw[4:0] == 10 ? uart_rx[47:40] : (
        sw[4:0] == 11 ? uart_rx[55:48] : (
        sw[4:0] == 12 ? uart_rx[63:56] : (
            ~8'b0
        )))))))))))))
    );

    assign led[7:0] = (
        sw[4:0] == 0 ? tx_type : (
        sw[4:0] == 1 ? tx_account_id : (   
        sw[4:0] == 2 ? tx_stock_id : (
        sw[4:0] == 3 ? tx_qty : (
        sw[4:0] == 4 ? tx_price : (
        sw[4:0] == 5 ? uart_tx[7:0] : (
        sw[4:0] == 6 ? uart_tx[15:8] : (
        sw[4:0] == 7 ? uart_tx[23:16] : (
        sw[4:0] == 8 ? uart_tx[31:24] : (
        sw[4:0] == 9 ? uart_tx[39:32] : (
        sw[4:0] == 10 ? uart_tx[47:40] : (
        sw[4:0] == 11 ? uart_tx[55:48] : (
        sw[4:0] == 12 ? uart_tx[63:56] : (
        sw[4:0] == 15 ? send_status: (
            ~8'b0
        ))))))))))))))
    );
endmodule


