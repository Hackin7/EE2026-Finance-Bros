`timescale 1ns / 1ps
/*
This module handles the market code and all the inputs and outputs
1. Data Structures for accounts, stocks, stocks_threshold, admin_fees
2. UART Processing 
*/

module trade_module_master #(
    parameter DBITS=8, UART_FRAME_SIZE=8, 
    INITIAL_ACCOUNTS='hff_ff_ff_00ffffff___01_00_01_00ffffff___01_00_00_00000fff,
    INITIAL_STOCKS='h00_ff__00_ff__00_0f
)(
    // Control
    input reset, input clk_100MHz,
    // UART
    input [UART_FRAME_SIZE*DBITS-1:0] uart_rx,
    output [UART_FRAME_SIZE*DBITS-1:0] uart_tx,
    output reg uart_tx_trigger=0,
    output reg uart_rx_clear=0,

    input [UART_FRAME_SIZE*DBITS-1:0] uart1_rx,
    output [UART_FRAME_SIZE*DBITS-1:0] uart1_tx,
    output reg uart1_tx_trigger=0,
    output reg uart1_rx_clear=0,

    input [UART_FRAME_SIZE*DBITS-1:0] uart2_rx,
    output [UART_FRAME_SIZE*DBITS-1:0] uart2_tx,
    output reg uart2_tx_trigger=0,
    output reg uart2_rx_clear=0,
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

    reg [7:0] master1_type=0;
    reg [7:0] master1_account_id=0;
    reg [7:0] master1_stock_id=0;
    reg [7:0] master1_qty=0;
    reg [7:0] master1_price=0;
    reg [31:0] master1_balance=0;
    trade_packet_former 
        #(
            .DBITS(DBITS), .UART_FRAME_SIZE(UART_FRAME_SIZE)
        ) former1 (
        .type(master1_type), .account_id(master1_account_id), 
        .stock_id(master1_stock_id), .qty(master1_qty), 
        .price(master1_price), .balance(master1_balance), 
        .uart_tx(uart1_tx)
    );

    reg [7:0] master2_type=0;
    reg [7:0] master2_account_id=0;
    reg [7:0] master2_stock_id=0;
    reg [7:0] master2_qty=0;
    reg [7:0] master2_price=0;
    reg [31:0] master2_balance=0;
    trade_packet_former 
        #(
            .DBITS(DBITS), .UART_FRAME_SIZE(UART_FRAME_SIZE)
        ) former2 (
        .type(master2_type), .account_id(master2_account_id), 
        .stock_id(master2_stock_id), .qty(master2_qty), 
        .price(master2_price), .balance(master2_balance), 
        .uart_tx(uart2_tx)
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
    
    wire [7:0] slave1_type;
    wire [7:0] slave1_account_id;
    wire [7:0] slave1_stock_id;
    wire [7:0] slave1_qty;
    wire [7:0] slave1_price;
    trade_packet_parser // redundancy with module_slave but whatever
        #(
            .DBITS(DBITS), 
            .UART_FRAME_SIZE(UART_FRAME_SIZE)
        ) parser1 (
        .uart_rx(uart1_rx), 
        .type(slave1_type), 
        .account_id(slave1_account_id), 
        .stock_id(slave1_stock_id), 
        .qty(slave1_qty), 
        .price(slave1_price)
    );
    wire [7:0] slave2_type;
    wire [7:0] slave2_account_id;
    wire [7:0] slave2_stock_id;
    wire [7:0] slave2_qty;
    wire [7:0] slave2_price;
    trade_packet_parser // redundancy with module_slave but whatever
        #(
            .DBITS(DBITS), 
            .UART_FRAME_SIZE(UART_FRAME_SIZE)
        ) parser2 (
        .uart_rx(uart2_rx), 
        .type(slave2_type), 
        .account_id(slave2_account_id), 
        .stock_id(slave2_stock_id), 
        .qty(slave2_qty), 
        .price(slave2_price)
    );
    
    reg uart_operation = 0; // extra clock cycle thing
    task fsm_uart_receive();
    begin
        uart_rx_clear <= 0;
        if (slave_type == parser.TYPE_INVALID) begin
            // Do nothing
            uart_operation <= 0;
        end else if (slave_type == parser.TYPE_BUY && !uart_operation) begin
            trade_approve_buy();
            uart_operation <= 1;
            uart_rx_clear <= 1;
        end else if (slave_type == parser.TYPE_SELL && !uart_operation) begin
            trade_approve_sell();
            uart_operation <= 1;
            uart_rx_clear <= 1;
        end else if (slave_type == parser.TYPE_GET_ACCOUNT_BALANCE) begin
            trade_return_account_balance();
            uart_operation <= 1;
            uart_rx_clear <= 1;
        end else if (slave_type == parser.TYPE_GET_ACCOUNT_STOCKS) begin
            trade_return_account_stocks();
            uart_operation <= 1;
            uart_rx_clear <= 1;
        end else begin
            // Do nothing
            uart_operation <= 0;
        end
    end
    endtask

    
    reg uart1_operation = 0;
    task fsm_uart1_receive();
    begin
        uart1_rx_clear <= 0;
        if (slave1_type == parser.TYPE_INVALID) begin
            // Do nothing
            uart1_operation <= 0;
        end else if (slave1_type == parser.TYPE_BUY && !uart1_operation) begin
            trade1_approve_buy();
            uart1_operation <= 1;
            uart1_rx_clear <= 1;
        end else if (slave1_type == parser.TYPE_SELL && !uart1_operation) begin
            trade1_approve_sell();
            uart1_operation <= 1;
            uart1_rx_clear <= 1;
        end else if (slave1_type == parser.TYPE_GET_ACCOUNT_BALANCE) begin
            trade1_return_account_balance();
            uart1_operation <= 1;
            uart1_rx_clear <= 1;
        end else if (slave1_type == parser.TYPE_GET_ACCOUNT_STOCKS) begin
            trade1_return_account_stocks();
            uart1_operation <= 1;
            uart1_rx_clear <= 1;
        end else begin
            // Do nothing
            uart1_operation <= 0;
        end
    end
    endtask

    reg uart2_operation = 0;
    task fsm_uart2_receive();
    begin
        uart2_rx_clear <= 0;
        if (slave2_type == parser.TYPE_INVALID) begin
            // Do nothing
            uart2_operation <= 0;
        end else if (slave2_type == parser.TYPE_BUY && !uart2_operation) begin
            trade2_approve_buy();
            uart2_operation <= 1;
            uart2_rx_clear <= 1;
        end else if (slave2_type == parser.TYPE_SELL && !uart2_operation) begin
            trade2_approve_sell();
            uart2_operation <= 1;
            uart2_rx_clear <= 1;
        end else if (slave2_type == parser.TYPE_GET_ACCOUNT_BALANCE) begin
            trade2_return_account_balance();
            uart2_operation <= 1;
            uart2_rx_clear <= 1;
        end else if (slave2_type == parser.TYPE_GET_ACCOUNT_STOCKS) begin
            trade2_return_account_stocks();
            uart2_operation <= 1;
            uart2_rx_clear <= 1;
        end else begin
            // Do nothing
            uart2_operation <= 0;
        end
    end
    endtask

    always @(posedge clk_100MHz) begin
        // UART Send Reset
        if (uart_tx_trigger) begin
            uart_tx_trigger <= 0;
        end
        if (uart1_tx_trigger) begin
            uart1_tx_trigger <= 0;
        end
        if (uart2_tx_trigger) begin
            uart2_tx_trigger <= 0;
        end
        fsm_uart_receive();
        fsm_uart1_receive();
        fsm_uart2_receive();
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
                account_update_balance(slave_account_id, curr_account_balance - (amount_paid),
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

    
    /* --- Approval1 Logic --------------------------------------------------------------- */
    
    wire [BITWIDTH_ACCT_BALANCE:0]   curr1_account_balance   = account_get_balance(slave1_account_id);
    wire [BITWIDTH_ACCT_STOCKS:0]    curr1_account_stock_qty = account_get_stock(slave1_account_id, slave1_stock_id);
    wire [BITWIDTH_STOCKS:0] curr1_stock_price       = stock_get_price(slave1_stock_id);    
    wire [31:0] amount1_paid = slave1_price * slave1_qty;      // amount_paid  = curr_stock.price * slave1_qty
    wire price1_match_buy = curr1_stock_price <= slave1_price; // price_match  = curr_stock.price <= slave1_price
    wire can1_buy = curr1_account_balance >= amount1_paid;     // can1_buy = (curr_account.balance >= amount_paid)

    wire price1_match_sell = curr1_stock_price >= slave1_price;      
    wire can1_sell = account_get_stock(slave1_account_id, slave1_stock_id) >= slave1_qty;    // TODO: Get Qty of Stock existing

    task trade1_approve_buy();
    begin
        if (can1_buy && price1_match_buy) begin
            // Math -----------------------------------------
            accounts <= (
                account_update_balance(slave1_account_id, curr1_account_balance - amount1_paid, // - (slave1_price*slave1_qty),
                account_update_stock( slave1_account_id, slave1_stock_id, curr1_account_stock_qty + slave1_qty,
                accounts))
            );
            admin_fees <= admin_fees + (slave1_price - curr1_stock_price) * slave1_qty;
            // Comms ----------------------------------------
            // Send OK Packet
            master1_type <= former.TYPE_OK;
            uart1_tx_trigger <= 1;
        end else begin
            // Comms ----------------------------------------
            // Send Fail Packet
            master1_type <= former.TYPE_FAIL;
            uart1_tx_trigger <= 1;
        end
        
        // Market Movement -----------------------------------
        if (can1_buy) begin
            if (slave1_price < curr1_stock_price) begin
                market_movement_one(slave1_stock_id, stock_get_threshold(slave1_stock_id)-1);
            end else if (slave1_price >= curr1_stock_price) begin
                market_movement_one(slave1_stock_id, stock_get_threshold(slave1_stock_id)+1);
            end
        end
    end
    endtask
    
    task trade1_approve_sell();
    begin
        if (can1_sell && price1_match_sell) begin
            // Math -----------------------------------------
            accounts <= (
                account_update_balance(slave1_account_id, curr1_account_balance + (slave1_price*slave1_qty),
                account_update_stock( slave1_account_id, slave1_stock_id, curr1_account_stock_qty - slave1_qty,
                accounts))
            );
            admin_fees <= admin_fees + (curr_stock_price - slave1_price) * slave1_qty;
            // Comms ----------------------------------------
            // Send OK Packet
            master1_type <= former.TYPE_OK;
            uart1_tx_trigger <= 1;
        end else begin
            // Comms ----------------------------------------
            // Send Fail Packet
            master1_type <= former.TYPE_FAIL;
            uart1_tx_trigger <= 1;
        end
        
        // Market Movement -----------------------------------
        if (can1_sell) begin
            if (slave1_price <= curr1_stock_price) begin
                market_movement_one(slave1_stock_id, stock_get_threshold(slave1_stock_id)-1);
            end else if (slave1_price > curr1_stock_price) begin
                market_movement_one(slave1_stock_id, stock_get_threshold(slave1_stock_id)+1);
            end
        end
    end
    endtask

    task trade1_return_account_balance();
    begin
         // Comms ----------------------------------------
        // Send OK Packet
        master1_type <= former.TYPE_RETURN_ACCOUNT_BALANCE;
        master1_balance <= account_get_balance(slave1_account_id);
        uart1_tx_trigger <= 1;
    end
    endtask

    task trade1_return_account_stocks();
    begin
         // Comms ----------------------------------------
        // Send OK Packet
        master1_type <= former.TYPE_RETURN_ACCOUNT_STOCKS;
        master1_balance <= {
            account_get_stock(slave1_account_id, 0),
            account_get_stock(slave1_account_id, 1),
            account_get_stock(slave1_account_id, 2),
            8'b0
        };
        uart1_tx_trigger <= 1;
    end
    endtask

    
    /* --- Approval2 Logic --------------------------------------------------------------- */
    
    wire [BITWIDTH_ACCT_BALANCE:0]   curr2_account_balance   = account_get_balance(slave2_account_id);
    wire [BITWIDTH_ACCT_STOCKS:0]    curr2_account_stock_qty = account_get_stock(slave2_account_id, slave2_stock_id);
    wire [BITWIDTH_STOCKS:0] curr2_stock_price       = stock_get_price(slave2_stock_id);    
    wire [31:0] amount2_paid = slave2_price * slave2_qty;      // amount2_paid  = curr_stock.price * slave2_qty
    wire price2_match_buy = curr2_stock_price <= slave2_price; // price_match  = curr_stock.price <= slave2_price
    wire can2_buy = curr2_account_balance >= amount2_paid;     // can2_buy = (curr_account.balance >= amount2_paid)

    wire price2_match_sell = curr2_stock_price >= slave2_price;      
    wire can2_sell = account_get_stock(slave2_account_id, slave2_stock_id) >= slave2_qty;    // TODO: Get Qty of Stock existing

    task trade2_approve_buy();
    begin
        if (can2_buy && price2_match_buy) begin
            // Math -----------------------------------------
            accounts <= (
                account_update_balance(slave2_account_id, curr2_account_balance - (amount2_paid),
                account_update_stock( slave2_account_id, slave2_stock_id, curr2_account_stock_qty + slave2_qty,
                accounts))
            );
            admin_fees <= admin_fees + (slave2_price - curr2_stock_price) * slave2_qty;
            // Comms ----------------------------------------
            // Send OK Packet
            master2_type <= former.TYPE_OK;
            uart2_tx_trigger <= 1;
        end else begin
            // Comms ----------------------------------------
            // Send Fail Packet
            master2_type <= former.TYPE_FAIL;
            uart2_tx_trigger <= 1;
        end
        
        // Market Movement -----------------------------------
        if (can2_buy) begin
            if (slave2_price < curr2_stock_price) begin
                market_movement_one(slave2_stock_id, stock_get_threshold(slave2_stock_id)-1);
            end else if (slave2_price >= curr2_stock_price) begin
                market_movement_one(slave2_stock_id, stock_get_threshold(slave2_stock_id)+1);
            end
        end
    end
    endtask
    
    task trade2_approve_sell();
    begin
        if (can2_sell && price2_match_sell) begin
            // Math -----------------------------------------
            accounts <= (
                account_update_balance(slave2_account_id, curr2_account_balance + (slave2_price*slave2_qty),
                account_update_stock( slave2_account_id, slave2_stock_id, curr2_account_stock_qty - slave2_qty,
                accounts))
            );
            admin_fees <= admin_fees + (curr2_stock_price - slave2_price) * slave2_qty;
            // Comms ----------------------------------------
            // Send OK Packet
            master2_type <= former.TYPE_OK;
            uart2_tx_trigger <= 1;
        end else begin
            // Comms ----------------------------------------
            // Send Fail Packet
            master2_type <= former.TYPE_FAIL;
            uart2_tx_trigger <= 1;
        end
        
        // Market Movement -----------------------------------
        if (can2_sell) begin
            if (slave2_price <= curr2_stock_price) begin
                market_movement_one(slave2_stock_id, stock_get_threshold(slave2_stock_id)-1);
            end else if (slave2_price > curr2_stock_price) begin
                market_movement_one(slave2_stock_id, stock_get_threshold(slave2_stock_id)+1);
            end
        end
    end
    endtask

    task trade2_return_account_balance();
    begin
         // Comms ----------------------------------------
        // Send OK Packet
        master2_type <= former.TYPE_RETURN_ACCOUNT_BALANCE;
        master2_balance <= account_get_balance(slave2_account_id);
        uart2_tx_trigger <= 1;
    end
    endtask

    task trade2_return_account_stocks();
    begin
         // Comms ----------------------------------------
        // Send OK Packet
        master2_type <= former.TYPE_RETURN_ACCOUNT_STOCKS;
        master2_balance <= {
            account_get_stock(slave2_account_id, 0),
            account_get_stock(slave2_account_id, 1),
            account_get_stock(slave2_account_id, 2),
            8'b0
        };
        uart2_tx_trigger <= 1;
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
            stocks <= stock_update_threshold(stock_id, threshold, stocks);
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
        sw[15:10] == 4 ? uart1_tx_trigger : (
        sw[15:10] == 5 ? uart1_tx[7:0] : (
        sw[15:10] == 6 ? uart1_tx[15:8] : (
        sw[15:10] == 7 ? uart1_tx[23:16] : (
        sw[15:10] == 8 ? uart1_tx[31:24] : (
        sw[15:10] == 9 ? uart1_tx[39:32] : (
        sw[15:10] == 10 ? uart1_tx[47:40] : (
        sw[15:10] == 11 ? uart1_tx[55:48] : (
        sw[15:10] == 12 ? uart1_tx[63:56] : (
        sw[15:10] == 13 ? 'b0 : (
            ~'b0
        ))))))))))))))
    );
endmodule


