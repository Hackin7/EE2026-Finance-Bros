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
        if (sw[10]) begin
            fsm_state = 8'd2;
        end
    end


    /* Sending Logic ----------------------------------------------------------*/
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
            send_status <= STATUS_PROCESSING;
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
    reg [7:0] extra_state = 0;
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
        extra_state <= 8'b11;
        if (tx_type == former.TYPE_INVALID || fsm_timer <= RX_DEBOUNCE) begin
            // do nothing, ignore everything because mode disabled
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
    
    /* Debugging ---------------------------------------------------------------*/
    // parser not working
    /*
    assign led[15:8] = (
        sw[15:11] == 0 ? packet_type : ( // Buggy
        sw[15:11] == 1 ? packet_account_id : (   
        sw[15:11] == 2 ? packet_stock_id : (
        sw[15:11] == 3 ? packet_qty : (
        sw[15:11] == 4 ? packet_price : (
        sw[15:11] == 5 ? uart_rx[7:0] : (
        sw[15:11] == 6 ? uart_rx[15:8] : (
        sw[15:11] == 7 ? uart_rx[23:16] : (
        sw[15:11] == 8 ? uart_rx[31:24] : (
        sw[15:11] == 9 ? uart_rx[39:32] : (
        sw[15:11] == 10 ? uart_rx[47:40] : (
        sw[15:11] == 11 ? uart_rx[55:48] : (
        sw[15:11] == 12 ? uart_rx[63:56] : (
            ~8'b0
        )))))))))))))
    );

    assign led[7:0] = (
        sw[15:11] == 0 ? tx_type : (
        sw[15:11] == 1 ? tx_account_id : (   
        sw[15:11] == 2 ? tx_stock_id : (
        sw[15:11] == 3 ? tx_qty : (
        sw[15:11] == 4 ? tx_price : (
        sw[15:11] == 5 ? uart_tx[7:0] : (
        sw[15:11] == 6 ? uart_tx[15:8] : (
        sw[15:11] == 7 ? uart_tx[23:16] : (
        sw[15:11] == 8 ? uart_tx[31:24] : (
        sw[15:11] == 9 ? uart_tx[39:32] : (
        sw[15:11] == 10 ? uart_tx[47:40] : (
        sw[15:11] == 11 ? uart_tx[55:48] : (
        sw[15:11] == 12 ? uart_tx[63:56] : (
        sw[15:11] == 15 ? send_status: (
            ~8'b0
        ))))))))))))))
    );*/
    reg [15:0] led_out = 0;
    assign led = led_out;
    
    always @(*) begin
        if (sw[15:11] == 5'b0000) begin    
            led_out[15:8] = fsm_state;
            led_out[7:0] = send_status;
        end else if (sw[15:11] == 5'b0001) begin    
            led_out = trigger;
        end else if (sw[15:11] == 5'b0010) begin    
            led_out = fsm_timer;
        end else if (sw[15:11] == 5'b0011) begin    
            led_out = 0;
        end else if (sw[15:11] == 5'b0100) begin    
            led_out = extra_state;
        end else begin
            led_out = ~16'b0;
        end
    end

endmodule

