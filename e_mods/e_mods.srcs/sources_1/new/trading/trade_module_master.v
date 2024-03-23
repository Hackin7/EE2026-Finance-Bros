`timescale 1ns / 1ps
/*
This module handles the market code and all the inputs and outputs
1. Data Structures for accounts, stocks, stocks_threshold, admin_fees
2. UART Processing 
*/

module trade_module_master #(
    parameter DBITS=8, UART_FRAME_SIZE=8, 
    INITIAL_ACCOUNTS='hff_ff_ff_ff___01_00_01_ff___01_00_00_ff,
    INITIAL_STOCKS='h00_ff__00_ff__00_0f
)(
    // Control
    input reset, input clk_100MHz,
    // UART
    input [UART_FRAME_SIZE*DBITS-1:0] uart_rx,
    output [UART_FRAME_SIZE*DBITS-1:0] uart_tx,
    output reg uart_tx_trigger=0,

    // Debugging //////////////////////////////////////////////////////////
    output [95:0] debug_accounts,
    output [95:0] debug_stocks,
    output [31:0] debug_admin_fees
);

    parameter MOVEMENT_THRSHOLD = 2;//0;

    /* --- Data Structures -------------------------------------------------------------- */
    parameter NO_ACCOUNTS = 3;
    parameter BITWIDTH_ACCT = 8*4; // 0-255 x 4
    reg [NO_ACCOUNTS * BITWIDTH_ACCT - 1 : 0] accounts = INITIAL_ACCOUNTS;
    //~'b0; // Balances

    parameter NO_STOCKS = 3;
    parameter BITWIDTH_STOCKS = 8*2; // 255
    reg [NO_STOCKS * BITWIDTH_STOCKS - 1 : 0] stocks = INITIAL_STOCKS;
    //~'b0; // prices, threshold

    parameter BITWIDTH_ADMIN_FEES = 32;
    reg [BITWIDTH_ADMIN_FEES - 1 : 0] admin_fees = 'b0;

    /* --- Stock Prices & Threshold ----------------------------------------------*/
    
    function [7:0] stock_get_price(input [2:0] index);
        begin
            stock_get_price = stocks >> (BITWIDTH_STOCKS*index);
        end
    endfunction
    
    function [7:0] stock_get_threshold(input [2:0] index);
        begin
            stock_get_threshold = stocks >> (BITWIDTH_STOCKS*index + 8);
        end
    endfunction

    function [NO_STOCKS * BITWIDTH_STOCKS - 1 : 0] stock_update_price(
        input [2:0] index, 
        input [7:0] new_value,
        input [NO_STOCKS * BITWIDTH_STOCKS - 1 : 0] new_stocks
    ); begin
        // Bitmask = (((8'hff) << (BITWIDTH_ACCT*index)));
        stock_update_price =  (
            (
                new_stocks &    
                ~((8'hff) << (BITWIDTH_STOCKS*index))
            ) | (new_value << (BITWIDTH_STOCKS*index))
        );
    end
    endfunction

    function [NO_STOCKS * BITWIDTH_STOCKS - 1 : 0] stock_update_threshold(
        input [2:0] index, 
        input [7:0] new_value,
        input [NO_STOCKS * BITWIDTH_STOCKS - 1 : 0] new_stocks
    ); begin
        // Bitmask = (((8'hff) << (BITWIDTH_ACCT*index)));
        stock_update_threshold =  (
            (
                new_stocks &    
                ~((8'hff) << (BITWIDTH_STOCKS*index+8))
            ) | (new_value << (BITWIDTH_STOCKS*index+8))
        );
    end
    endfunction

    /* --- Account ----------------------------------------------*/
    function [7:0] account_get_balance(input [2:0] index);
        begin
            account_get_balance = accounts >> (BITWIDTH_ACCT*index);
        end
    endfunction

    function [7:0] account_get_stock(input [2:0] index, input [2:0] stock_index);
        begin
            account_get_stock = accounts >> (BITWIDTH_ACCT*index + (stock_index + 1 * 8));
        end
    endfunction
    
    function [NO_ACCOUNTS * BITWIDTH_ACCT - 1 : 0] account_update_balance(
        input [2:0] index, 
        input [7:0] new_value,
        input [NO_ACCOUNTS * BITWIDTH_ACCT - 1 : 0] new_accounts
    ); begin
        // Bitmask = (((8'hff) << (BITWIDTH_ACCT*index)));
        account_update_balance =  (
            (
                new_accounts &    
                ~((8'hff) << (BITWIDTH_ACCT*index))
            ) | (new_value << (BITWIDTH_ACCT*index))
        );
    end
    endfunction

    function [NO_ACCOUNTS * BITWIDTH_ACCT - 1 : 0] account_update_stock(
        input [2:0] index, 
        input [2:0] stock_index,
        input [7:0] new_value,
        input [NO_ACCOUNTS * BITWIDTH_ACCT - 1 : 0] new_accounts
    ); begin
        account_update_stock =  (
            (
                new_accounts &    
                ~((8'hff) << (BITWIDTH_ACCT*index + (stock_index + 1 * 8)) )
            ) | (new_value << (BITWIDTH_ACCT*index + (stock_index + 1 * 8)) )
        );
    end
    endfunction
    /* --- UART Sender -------------------------------------------------------------------------- */
    reg [7:0] master_type=0;
    reg [7:0] master_account_id=0;
    reg [7:0] master_stock_id=0;
    reg [7:0] master_qty=0;
    reg [7:0] master_price=0;
    trade_packet_former 
        #(
            .DBITS(DBITS), .UART_FRAME_SIZE(UART_FRAME_SIZE)
        ) former (
        .type(master_type), .account_id(master_account_id), 
        .stock_id(master_stock_id), .qty(master_qty), 
        .price(master_price), .uart_tx(uart_tx)
    );

    // Auto detach
    always @(posedge clk_100MHz) begin
        if (uart_tx_trigger) begin
            uart_tx_trigger <= 0;
        end
    end

    /* --- UART Receiver -------------------------------------------------------------------------- */
    wire [7:0] slave_type;
    wire [7:0] slave_account_id;
    wire [7:0] slave_stock_id;
    wire [7:0] slave_qty;
    wire [7:0] slave_price;
    trade_packet_parser // redundancy with module_slave but whatever
        #(
            .DBITS(DBITS), 
            .UART_FRAME_SIZE(UART_FRAME_SIZE)
        ) parser (
        .uart_rx(uart_rx), 
        .type(slave_type), 
        .account_id(slave_account_id), 
        .stock_id(slave_stock_id), 
        .qty(slave_qty), 
        .price(slave_price)
    );
    
    reg [UART_FRAME_SIZE*DBITS-1:0] prev_processed_uart_rx=0;
    task fsm_uart_receive();
    begin
        if (prev_processed_uart_rx == uart_rx) begin
            // do nothing - Don't process a request twice in a row
        end else if (slave_type == parser.TYPE_INVALID) begin
            // do nothing
            prev_processed_uart_rx <= 0; // Clear processed
        end else if (slave_type == parser.TYPE_BUY) begin
            // process buy request
            trade_approve_buy();
            prev_processed_uart_rx <= uart_rx;
        end else if (slave_type == parser.TYPE_SELL) begin
            // do nothing
        end
        
    end
    endtask

    
    always @(posedge clk_100MHz) begin
        fsm_uart_receive();
    end

    /* --- UART Checker --------------------------------------------------------------------------- */


    /* --- Approval Logic --------------------------------------------------------------- */
    
    wire [BITWIDTH_ACCT:0]   curr_account_balance = account_get_balance(slave_account_id);
    wire [7:0]               curr_account_stock_qty = account_get_stock(slave_account_id, slave_stock_id);
    wire [BITWIDTH_STOCKS:0] curr_stock_price     = stock_get_price(slave_stock_id);    
    wire [31:0] amount_paid = slave_price * slave_qty;      // amount_paid  = curr_stock.price * slave_qty
    wire price_match_buy = curr_stock_price <= slave_price; // price_match  = curr_stock.price <= slave_price
    wire can_buy = curr_account_balance >= amount_paid;     // can_buy = (curr_account.balance >= amount_paid)

    wire price_match_sell = curr_stock_price >= slave_price;      
    wire can_sell = account_get_stock(slave_account_id, slave_stock_id) >= slave_qty;    // TODO: Get Qty of Stock existing

    task trade_approve_buy();
    begin
        if (can_buy && price_match_buy) begin
            // Math -----------------------------------------
            accounts <= (
                account_update_balance(slave_account_id, curr_account_balance - (slave_price*slave_qty),
                account_update_stock( slave_account_id, slave_stock_id, curr_account_stock_qty + 1,
                accounts))
            );
            admin_fees <= admin_fees + (slave_price - curr_stock_price) * slave_qty;
            // Comms ----------------------------------------
            // Send OK Packet
            master_type <= former.TYPE_OK;
            uart_tx_trigger <= 1;
        end else begin
            // Comms ----------------------------------------
            // Send Fail Packet
            master_type <= former.TYPE_FAIL;
            uart_tx_trigger <= 1;
        end
        
        // Market Movement -----------------------------------
        if (can_buy) begin
            if (slave_price < curr_stock_price) begin
                market_movement_one(slave_stock_id, stock_get_threshold(slave_stock_id)-1);
            end else if (slave_price >= curr_stock_price) begin
                market_movement_one(slave_stock_id, stock_get_threshold(slave_stock_id)+1);
            end
        end
    end
    endtask
    
    /*
    task trade_approve_sell();
    begin
        if (can_sell && price_match_sell) begin
            // Math -----------------------------------------
            update_account(slave_account_id, 0, amount_paid);
            update_account(slave_account_id, slave_stock_id+1, get_account(slave_account_id, slave_stock_id+1) + slave_qty);
            admin_fees <= admin_fees + (slave_price - curr_stock_price) * slave_qty
            // Comms ----------------------------------------
            // Send OK Packet
        end else begin
            // Comms ----------------------------------------
            // Send Fail Packet
        end

        // Market Movement -----------------------------------
        if (can_buy) begin
            if (slave_price > curr_stock_price) begin
                update_entry(slave_stock_id, stocks_threshold, get_entry(slave_stock_id, stocks_threshold)-1 );
            end else if (slave_price <= curr_stock_price) begin
                update_entry(slave_stock_id, stocks_threshold, get_entry(slave_stock_id, stocks_threshold)+1 );
            end
        end
        market_movement();
    end
    endtask
    */
    /* --- Market Movement -------------------------------------------------------------- */
    
    task market_movement_one(input [2:0] stock_id, input signed [7:0] threshold);
    begin
        if (threshold <= -MOVEMENT_THRSHOLD) begin
            // update price & threshold
            stocks <= (
                stock_update_price(stock_id, stock_get_price(stock_id)-1, 
                stock_update_threshold(stock_id, 0, 
            stocks)));
        end else if (threshold >= MOVEMENT_THRSHOLD) begin
            stocks <= (
                stock_update_price(stock_id, stock_get_price(stock_id)+1, 
                stock_update_threshold(stock_id, 0, 
            stocks)));
        end else begin
            stocks <= stock_update_threshold(slave_stock_id, threshold, stocks);
        end
    end
    endtask

    /*
    // unnecessary - can just update for the specific one
    task market_movement();
    begin
        // Hardcode for 3 blocks
        market_movement_one(0);
        market_movement_one(1);
        market_movement_one(2);
    end
    endtask
    */

    /* --- Debug -------------------------------------------------------*/
    assign debug_accounts = accounts;
    assign debug_stocks = stocks;
    assign debug_admin_fees = admin_fees;
endmodule


