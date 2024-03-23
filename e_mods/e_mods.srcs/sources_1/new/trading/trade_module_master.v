`timescale 1ns / 1ps
/*
This module handles the market code and all the inputs and outputs
1. Data Structures for accounts, stocks, stocks_threshold, admin_fees
2. UART Processing 
*/

module trade_module_master #(
    parameter DBITS=8, UART_FRAME_SIZE=8
)(
    // Control
    input reset, input clk,
    // UART
    input [UART_FRAME_SIZE*DBITS-1:0] uart_rx,
    output [UART_FRAME_SIZE*DBITS-1:0] uart_tx,
    output uart_tx_trigger,

    // Debugging //////////////////////////////////////////////////////////
    // Control
    input [15:0] sw, output [15:0] led, 
    output reg [7:0] fsm_state=0, 
    output reg [32-1:0] fsm_timer=0 
);

    parameter MOVEMENT_THRSHOLD = 10;

    /* --- Data Structures -------------------------------------------------------------- */
    parameter NO_ACCOUNTS = 3;
    parameter BITWIDTH_ACCT = 8*4; // 0-255 x 4
    reg [NO_ACCOUNTS * BITWIDTH_ACCT - 1 : 0] accounts = 0; // Balances

    parameter NO_STOCKS = 3;
    parameter BITWIDTH_STOCKS = 8; // 255
    reg [NO_ACCOUNTS * BITWIDTH_ACCT - 1 : 0] stocks = 0; // prices

    parameter BITWIDTH_THRESHOLD = 8; // 255
    reg [NO_ACCOUNTS * BITWIDTH_ACCT - 1 : 0] stocks_threshold = 0; // Balances

    parameter BITWIDTH_ADMIN_FEES = 32;
    reg [BITWIDTH_ADMIN_FEES - 1 : 0] admin_fees = 0;


    function [7:0] get_entry(input [2:0] index, input [3*8-1:0] memory);
        begin
            get_entry = memory >> BITWIDTH_STOCKS*index;
        end
    endfunction
    
    function [7:0] change_entry_value(input [2:0] index, input [3*8-1:0] memory, input [7:0] new_value)
    begin
        change_entry_value = (memory & ~(~8'b0 << BITWIDTH_STOCKS*index)) | (new_value << BITWIDTH_STOCKS*index);
    end
    endfunction

    // Account //////////////////////////////////////////////////////////////////////
    function [7:0] account_get_balance(input [2:0] index);
        begin
            get_entry = accounts >> (BITWIDTH_ACCT*index + (0 * 8));
        end
    endfunction
    function [7:0] account_get_stock(input [2:0] index, input [2:0] stock_index);
        begin
            get_entry = accounts >> (BITWIDTH_ACCT*index + (stock_index + 1 * 8));
        end
    endfunction
    
    task update_account(input [2:0] index, input [2:0] position_index, input [7:0] new_value);
    begin
        accounts[
            BITWIDTH_ACCT*index + (((position_index+1) * 8) -1) :
            BITWIDTH_ACCT*index + (position_index * 8)
        ] <= new_value;
    end
    endtask

    /* --- Finite State Machine ---------------------------------------------------------- */


    /* --- Approval Logic --------------------------------------------------------------- */
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

    wire [BITWIDTH_ACCT:0]   curr_account = get_account(packet_account_id, 0);
    wire [BITWIDTH_STOCKS:0] curr_stock_price   = get_entry(packet_stock_id, stocks);    
    wire [31:0] amount_paid = packet_price * packet_qty;      // amount_paid  = curr_stock.price * packet_qty
    wire price_match_buy = curr_stock_price <= packet_price;      // price_match  = curr_stock.price <= packet_price
    wire can_buy = curr_account >= amount_paid;             // can_buy = (curr_account.balance >= amount_paid)

    wire price_match_sell = curr_stock_price >= packet_price;      
    wire can_sell = get_account(packet_account_id, packet_stock_id+1) >= packet_qty;    // TODO: Get Qty of Stock existing

    task trade_approve_buy();
    begin
        if (can_buy && price_match_buy) begin
            // Math -----------------------------------------
            update_account(packet_account_id, 0, amount_paid);
            update_account(packet_account_id, packet_stock_id+1, get_account(packet_account_id, packet_stock_id+1) + packet_qty);
            admin_fees <= admin_fees + (packet_price - curr_stock_price) * packet_qty
            // Comms ----------------------------------------
            // Send OK Packet
        end else begin
            // Comms ----------------------------------------
            // Send Fail Packet
        end

        // Market Movement -----------------------------------
        if (can_buy) begin
            if (packet_price < curr_stock_price) begin
                update_entry(packet_stock_id, stocks_threshold, get_entry(packet_stock_id, stocks_threshold)-1 );
            end else if (packet_price >= curr_stock_price) begin
                update_entry(packet_stock_id, stocks_threshold, get_entry(packet_stock_id, stocks_threshold)+1 );
            end
        end
        market_movement();
    end
    endtask

    task trade_approve_sell();
    begin
        if (can_sell && price_match_sell) begin
            // Math -----------------------------------------
            update_account(packet_account_id, 0, amount_paid);
            update_account(packet_account_id, packet_stock_id+1, get_account(packet_account_id, packet_stock_id+1) + packet_qty);
            admin_fees <= admin_fees + (packet_price - curr_stock_price) * packet_qty
            // Comms ----------------------------------------
            // Send OK Packet
        end else begin
            // Comms ----------------------------------------
            // Send Fail Packet
        end

        // Market Movement -----------------------------------
        if (can_buy) begin
            if (packet_price > curr_stock_price) begin
                update_entry(packet_stock_id, stocks_threshold, get_entry(packet_stock_id, stocks_threshold)-1 );
            end else if (packet_price <= curr_stock_price) begin
                update_entry(packet_stock_id, stocks_threshold, get_entry(packet_stock_id, stocks_threshold)+1 );
            end
        end
        market_movement();
    end
    endtask

    /* --- Market Movement -------------------------------------------------------------- */
    task market_movement_one(input [2:0] stock_id);
    begin
        if (get_entry(stock_id, stocks_threshold) <= -MOVEMENT_THRSHOLD) begin
            update_entry(stock_id, stocks, get_entry(stock_id, stocks)-1);
            update_entry(stock_id, stocks_threshold, 0 );
        end else if (get_entry(stock_id, stocks_threshold) >= MOVEMENT_THRSHOLD) begin
            update_entry(stock_id, stocks, get_entry(stock_id, stocks)+1);
            update_entry(stock_id, stocks_threshold, 0 );
        end 
    end
    endtask

    task market_movement();
    begin
        // Hardcode for 3 blocks
        market_movement_one(0);
        market_movement_one(1);
        market_movement_one(2);
    end
    endtask

endmodule


