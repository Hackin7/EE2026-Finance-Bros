`timescale 1ns / 1ps
/*
This module handles the market code and all the inputs and outputs
1. Data Structures for accounts, stocks, stocks_threshold, admin_fees
2. UART Processing 
*/

module trade_module_master #(
    parameter DBITS=8, UART_FRAME_SIZE=8, 
    INITIAL_ACCOUNTS='hff_ff_ff_00ffffff___01_00_01_00ffffff___01_00_00_00ffffff,
    INITIAL_STOCKS='h00_ff__00_ff__00_0f
)(
    // Control
    input reset, input clk_100MHz,
    // UART
    input [UART_FRAME_SIZE*DBITS-1:0] uart_rx,
    output [UART_FRAME_SIZE*DBITS-1:0] uart_tx,
    output reg uart_tx_trigger=0,
    output reg uart_rx_clear=0,

    // Debugging //////////////////////////////////////////////////////////
    output [167:0] debug_accounts,
    output [95:0] debug_stocks,
    output [31:0] debug_admin_fees, 
    output [31:0] debug_general,
    // Control
    input [15:0] sw, output [15:0] led
);

    parameter MOVEMENT_THRSHOLD = 2;//0;
    /* --- Data Structures -------------------------------------------------------------- */
    parameter NO_STOCKS = 3;
    parameter BITWIDTH_NO_STOCKS = 2;
    parameter BITWIDTH_STOCKS_PRICE = 8;
    parameter BITWIDTH_STOCKS_THRESHOLD = 8;
    parameter BITWIDTH_STOCKS = BITWIDTH_STOCKS_PRICE + BITWIDTH_STOCKS_THRESHOLD; // 255
    reg [NO_STOCKS * BITWIDTH_STOCKS - 1 : 0] stocks = INITIAL_STOCKS;

    parameter NO_ACCOUNTS = 3;
    parameter BITWIDTH_NO_ACCOUNTS = 2;
    parameter BITWIDTH_ACCT_BALANCE = 32;
    parameter BITWIDTH_ACCT_STOCKS = 8;
    parameter BITWIDTH_ACCT = BITWIDTH_ACCT_BALANCE + BITWIDTH_ACCT_STOCKS*NO_STOCKS;
    reg [NO_ACCOUNTS * BITWIDTH_ACCT - 1 : 0] accounts = INITIAL_ACCOUNTS;

    parameter BITWIDTH_ADMIN_FEES = 32;
    reg [BITWIDTH_ADMIN_FEES - 1 : 0] admin_fees = 'b0;
    /* --- Stock Prices & Threshold ----------------------------------------------*/
    
    function [BITWIDTH_STOCKS_PRICE-1:0] stock_get_price(
        input [BITWIDTH_NO_STOCKS-1:0] index
    );
        begin
            stock_get_price = stocks >> (BITWIDTH_STOCKS*index);
        end
    endfunction
    
    function [BITWIDTH_STOCKS_THRESHOLD-1:0] stock_get_threshold(
        input [BITWIDTH_NO_STOCKS-1:0] index
    );
        begin
            stock_get_threshold = stocks >> (BITWIDTH_STOCKS*index + 8);
        end
    endfunction

    function [NO_STOCKS * BITWIDTH_STOCKS - 1 : 0] stock_update_price(
        input [BITWIDTH_NO_STOCKS-1:0] index, 
        input [BITWIDTH_STOCKS_PRICE-1:0] new_value,
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
        input [BITWIDTH_NO_STOCKS-1:0] index, 
        input [BITWIDTH_STOCKS_THRESHOLD-1:0] new_value,
        input [NO_STOCKS * BITWIDTH_STOCKS - 1 : 0] new_stocks
    ); begin
        // Bitmask = (((8'hff) << (BITWIDTH_ACCT*index)));
        stock_update_threshold =  (
            (
                new_stocks &    
                ~((8'hff) << (BITWIDTH_STOCKS*index + BITWIDTH_STOCKS_PRICE))
            ) | (new_value << (BITWIDTH_STOCKS*index + BITWIDTH_STOCKS_PRICE))
        );
    end
    endfunction

    /* --- Account ----------------------------------------------*/
    function [BITWIDTH_ACCT_BALANCE-1:0] account_get_balance(
        input [BITWIDTH_NO_ACCOUNTS-1:0] index
    );
        begin
            account_get_balance = accounts >> (BITWIDTH_ACCT*index);
        end
    endfunction

    function [BITWIDTH_ACCT_STOCKS-1:0] account_get_stock(
        input [BITWIDTH_NO_ACCOUNTS-1:0] index, 
        input [BITWIDTH_NO_STOCKS-1:0] stock_index
    );
        begin
            account_get_stock = accounts >> (
                BITWIDTH_ACCT*index + BITWIDTH_ACCT_BALANCE + (stock_index * BITWIDTH_ACCT_STOCKS)
            );
        end
    endfunction
    
    function [NO_ACCOUNTS * BITWIDTH_ACCT - 1 : 0] account_update_balance(
        input [BITWIDTH_NO_ACCOUNTS-1:0] index, 
        input [BITWIDTH_ACCT_BALANCE-1:0] new_value,
        input [NO_ACCOUNTS * BITWIDTH_ACCT - 1 : 0] new_accounts
    ); begin
        // Bitmask = (((8'hff) << (BITWIDTH_ACCT*index)));
        account_update_balance =  (
            (
                new_accounts &    
                ~((32'hffffffff) << (BITWIDTH_ACCT*index))
            ) | (new_value << (BITWIDTH_ACCT*index))
        );
    end
    endfunction

    function [NO_ACCOUNTS * BITWIDTH_ACCT - 1 : 0] account_update_stock(
        input [BITWIDTH_NO_ACCOUNTS-1:0] index, 
        input [BITWIDTH_NO_STOCKS-1:0] stock_index,
        input [BITWIDTH_ACCT_STOCKS-1:0] new_value,
        input [NO_ACCOUNTS * BITWIDTH_ACCT - 1 : 0] new_accounts
    ); begin
        account_update_stock =  (
            (
                new_accounts &    
                ~((8'hff) << (BITWIDTH_ACCT*index + BITWIDTH_ACCT_BALANCE + (stock_index * BITWIDTH_ACCT_STOCKS)) )
            ) | (new_value << (BITWIDTH_ACCT*index + BITWIDTH_ACCT_BALANCE + (stock_index * BITWIDTH_ACCT_STOCKS)) )
        );
    end
    endfunction
    /* --- UART Sender -------------------------------------------------------------------------- */
    reg [7:0] master_type=0;
    reg [7:0] master_account_id=0;
    reg [7:0] master_stock_id=0;
    reg [7:0] master_qty=0;
    reg [7:0] master_price=0;
    reg [31:0] master_balance=0;
    trade_packet_former 
        #(
            .DBITS(DBITS), .UART_FRAME_SIZE(UART_FRAME_SIZE)
        ) former (
        .type(master_type), .account_id(master_account_id), 
        .stock_id(master_stock_id), .qty(master_qty), 
        .price(master_price), .balance(master_balance), 
        .uart_tx(uart_tx)
    );

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
    
    
    task fsm_uart_receive();
    begin
        uart_rx_clear <= 0;
        if (slave_type == parser.TYPE_INVALID) begin
            // Do nothing
        end else if (slave_type == parser.TYPE_BUY) begin
            trade_approve_buy();
            uart_rx_clear <= 1;
        end else if (slave_type == parser.TYPE_SELL) begin
            trade_approve_sell();
            uart_rx_clear <= 1;
        end else if (slave_type == parser.TYPE_GET_ACCOUNT_BALANCE) begin
            trade_return_account_balance();
        end else if (slave_type == parser.TYPE_GET_ACCOUNT_STOCKS) begin
            trade_return_account_stocks();
        end else begin
            // Do nothing
        end
    end
    endtask

    
    always @(posedge clk_100MHz) begin
        // UART Send Reset
        if (uart_tx_trigger) begin
            uart_tx_trigger <= 0;
        end
        fsm_uart_receive();
    end

    /* --- Approval Logic --------------------------------------------------------------- */
    
    wire [BITWIDTH_ACCT_BALANCE:0]   curr_account_balance   = account_get_balance(slave_account_id);
    wire [BITWIDTH_ACCT_STOCKS:0]    curr_account_stock_qty = account_get_stock(slave_account_id, slave_stock_id);
    wire [BITWIDTH_STOCKS:0] curr_stock_price       = stock_get_price(slave_stock_id);    
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
                account_update_stock( slave_account_id, slave_stock_id, curr_account_stock_qty + slave_qty,
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
    
    task trade_approve_sell();
    begin
        if (can_sell && price_match_sell) begin
            // Math -----------------------------------------
            accounts <= (
                account_update_balance(slave_account_id, curr_account_balance + (slave_price*slave_qty),
                account_update_stock( slave_account_id, slave_stock_id, curr_account_stock_qty - slave_qty,
                accounts))
            );
            admin_fees <= admin_fees + (curr_stock_price - slave_price) * slave_qty;
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
        if (can_sell) begin
            if (slave_price <= curr_stock_price) begin
                market_movement_one(slave_stock_id, stock_get_threshold(slave_stock_id)-1);
            end else if (slave_price > curr_stock_price) begin
                market_movement_one(slave_stock_id, stock_get_threshold(slave_stock_id)+1);
            end
        end
    end
    endtask

    task trade_return_account_balance();
    begin
         // Comms ----------------------------------------
        // Send OK Packet
        master_type <= former.TYPE_RETURN_ACCOUNT_BALANCE;
        master_balance <= account_get_balance(slave_account_id);
        uart_tx_trigger <= 1;
    end
    endtask

    task trade_return_account_stocks();
    begin
         // Comms ----------------------------------------
        // Send OK Packet
        master_type <= former.TYPE_RETURN_ACCOUNT_STOCKS;
        master_balance <= {
            account_get_stock(slave_account_id, 0),
            account_get_stock(slave_account_id, 1),
            account_get_stock(slave_account_id, 2),
            8'b0
        };
        uart_tx_trigger <= 1;
    end
    endtask

    /* --- Market Movement -------------------------------------------------------------- */
    
    task market_movement_one(
        input [BITWIDTH_NO_STOCKS-1:0] stock_id, 
        input signed [BITWIDTH_STOCKS_THRESHOLD:0] threshold
    );
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
    assign led[15:0] = (
        sw[15:10] == 0 ? {slave_type} : ( // Buggy
        sw[15:10] == 1 ? {slave_account_id} : (   
        sw[15:10] == 2 ? {slave_stock_id} : (
        sw[15:10] == 3 ? {slave_qty} : (
        sw[15:10] == 4 ? {slave_price} : (
        sw[15:10] == 5 ? uart_rx[7:0] : (
        sw[15:10] == 6 ? uart_rx[15:8] : (
        sw[15:10] == 7 ? uart_rx[23:16] : (
        sw[15:10] == 8 ? uart_rx[31:24] : (
        sw[15:10] == 9 ? uart_rx[39:32] : (
        sw[15:10] == 10 ? uart_rx[47:40] : (
        sw[15:10] == 11 ? uart_rx[55:48] : (
        sw[15:10] == 12 ? uart_rx[63:56] : (
        sw[15:10] == 13 ? 'b0 : (
            ~'b0
        ))))))))))))))
    );
endmodule


