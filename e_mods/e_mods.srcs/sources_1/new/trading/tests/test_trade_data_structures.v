`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.01.2024 22:55:44
// Design Name: 
// Module Name: my_control_module_simulation
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

    /* --- Base Functions -------------------------------------*/
    /*
    function [7:0] get_value(input [3*8-1:0] memory, input [2:0] index);
        begin
            get_value = memory >> BITWIDTH_STOCKS*index;
        end
    endfunction
    function [7:0] update_value(input [3*8-1:0] memory, input [2:0] index, input [7:0] new_value)
    begin
        update_value = (memory & ~(~8'b0 << BITWIDTH_STOCKS*index)) | (new_value << BITWIDTH_STOCKS*index);
    end
    endfunction
    */

module test_trade_data_structures();
    // Simulation Inputs
    reg A;
    reg B;
    
    // Simulation Outputs
    reg [7:0] out_test = 0;

    /* --- Data Structures -------------------------------------------------------------- */
    parameter NO_ACCOUNTS = 3;
    parameter BITWIDTH_ACCT = 8*4; // 0-255 x 4
    reg [NO_ACCOUNTS * BITWIDTH_ACCT - 1 : 0] accounts = ~'b0; // Balances

    parameter NO_STOCKS = 3;
    parameter BITWIDTH_STOCKS = 8*2; // 255
    reg [NO_STOCKS * BITWIDTH_STOCKS - 1 : 0] stocks = ~'b0; // prices, threshold

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
        input [NO_STOCKS * BITWIDTH_STOCKS - 1 : 0] new_stocks_prices
    ); begin
        // Bitmask = (((8'hff) << (BITWIDTH_ACCT*index)));
        stock_update_price =  (
            (
                new_stocks_prices &    
                ~((8'hff) << (BITWIDTH_STOCKS*index))
            ) | (new_value << (BITWIDTH_STOCKS*index))
        );
    end
    endfunction

    function [NO_STOCKS * BITWIDTH_STOCKS - 1 : 0] stock_update_threshold(
        input [2:0] index, 
        input [7:0] new_value,
        input [NO_STOCKS * BITWIDTH_STOCKS - 1 : 0] new_stocks_prices
    ); begin
        // Bitmask = (((8'hff) << (BITWIDTH_ACCT*index)));
        stock_update_threshold =  (
            (
                new_stocks_prices &    
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
    /* -------------------------------------------------------------------------------------------- */

    /* --- Operations ---------------------------------------------------------------------------- */
    initial begin
        A = 0; B = 0; #10;
        
        // accounts <= account_update_balance(accounts, 1, 1);
        // accounts <= account_update_stock(accounts, 0, 0, 2); // This will overwrite

        // Account Test
        accounts <= account_update_stock(2, 0, 2, account_update_balance(2, 1, accounts));
        #10;
        out_test <= account_get_balance(2);
        #10;
        out_test <= account_get_stock(2, 0);
        #10;
        
        A = 1; 
        stocks <= stock_update_threshold(2, 4, stock_update_price(2, 3, stocks));
        #10;
        out_test <= stock_get_price(2);
        #10;
        out_test <= stock_get_threshold(2);
        #10;
        /*
        out_test <= account_get_balance(1);
        accounts <= account_update_balance(2, 1);
        accounts <= account_update_stock(2, 0, 2);
        A = 1; B = 1; #10;

        out_test <= account_get_balance(2);
        accounts <= account_update_balance(3, 1);
        accounts <= account_update_stock(3, 0, 2);
        A = 1; B = 1; #10;*/
    end
endmodule