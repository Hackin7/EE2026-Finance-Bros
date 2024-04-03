`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.03.2024 12:21:43
// Design Name: 
// Module Name: module_slave
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


module module_master #(
    parameter DBITS=8, UART_FRAME_SIZE=8, 
    STR_LEN=15
)(
    // Control
    input reset, input clk,
    // LEDs, Switches, Buttons
    input btnC, btnU, btnL, btnR, btnD, input [15:0] sw, output [15:0] led,
    // 7 Segment Display
    output [6:0] seg, output dp, output [3:0] an,
    // UART
    input [UART_FRAME_SIZE*DBITS-1:0] uart_rx,
    output [UART_FRAME_SIZE*DBITS-1:0] uart_tx,
    output uart_tx_trigger,
    output uart_rx_clear,

    input [UART_FRAME_SIZE*DBITS-1:0] uart1_rx,
    output [UART_FRAME_SIZE*DBITS-1:0] uart1_tx,
    output uart1_tx_trigger,
    output uart1_rx_clear,
    
    input [UART_FRAME_SIZE*DBITS-1:0] uart2_rx,
    output [UART_FRAME_SIZE*DBITS-1:0] uart2_tx,
    output uart2_tx_trigger,
    output uart2_rx_clear,
    // OLED
    input [12:0] oled_pixel_index, output reg [15:0] oled_pixel_data,
    // OLED Text Module
    output [8*STR_LEN*5-1:0] text_lines, output [15:0] text_colour,
    
    // Mouse - NOT NEEDED
    input [11:0] mouse_xpos,  mouse_ypos, input [3:0] mouse_zpos,
    input mouse_left_click, mouse_middle_click, mouse_right_click, mouse_new_event
);

    parameter NO_STOCKS = 3;
    parameter BITWIDTH_NO_STOCKS = 2;
    parameter BITWIDTH_STOCKS_PRICE = 8;
    parameter BITWIDTH_STOCKS_THRESHOLD = 8;
    parameter BITWIDTH_STOCKS = BITWIDTH_STOCKS_PRICE + BITWIDTH_STOCKS_THRESHOLD; // 255
    wire [NO_STOCKS * BITWIDTH_STOCKS - 1 : 0] stocks;

    parameter NO_ACCOUNTS = 3;
    parameter BITWIDTH_NO_ACCOUNTS = 2;
    parameter BITWIDTH_ACCT_BALANCE = 32;
    parameter BITWIDTH_ACCT_STOCKS = 8;
    parameter BITWIDTH_ACCT = BITWIDTH_ACCT_BALANCE + BITWIDTH_ACCT_STOCKS*NO_STOCKS;
    wire [NO_ACCOUNTS * BITWIDTH_ACCT - 1 : 0] accounts;
    
    //constants library
    constants constant();

    reg [7:0] xpos; reg [7:0] ypos;


    trade_module_master 
        #(
         .DBITS(8), .UART_FRAME_SIZE(8)
        )
        trade_slave (
        .clk_100MHz(clk), .reset(),
        .uart_rx(uart_rx), .uart_tx(uart_tx),
        .uart_tx_trigger(uart_tx_trigger),
        .uart_rx_clear(uart_rx_clear),
        
        .uart1_rx(uart1_rx), .uart1_tx(uart1_tx),
        .uart1_tx_trigger(uart1_tx_trigger),
        .uart1_rx_clear(uart1_rx_clear),
        
        .uart2_rx(uart2_rx), .uart2_tx(uart2_tx),
        .uart2_tx_trigger(uart2_tx_trigger),
        .uart2_rx_clear(uart2_rx_clear),
        
        // Debugging Ports
        .sw(sw), .led(led), 
        .debug_accounts(accounts),
        .debug_stocks(stocks)
    );

     /* --- Account ----------------------------------------------*/
     function [BITWIDTH_STOCKS_PRICE-1:0] stock_get_price(
        input [BITWIDTH_NO_STOCKS-1:0] index
    );
        begin
            stock_get_price = stocks >> (BITWIDTH_STOCKS*index);
        end
    endfunction
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
    //////////////////////////////////////////////////////////
    //State machine    
    reg [3:0] state = 4'd1;
    parameter MENU_STATE = 1;
    parameter USER_TABLE_STATE = 2;
    parameter STOCK_TABLE_STATE = 3;
    parameter GRAPH_STATE = 4;

    reg [2:0] user_id = 0;
    wire [8*(4)-1:0] num_string1, num_string2, num_string3, num_string4;
    text_num_val_mapping text_num1_module(
        state == USER_TABLE_STATE  ? (
            ypos < 10 ? user_id
            : account_get_balance(user_id)
        ):
        state == STOCK_TABLE_STATE ? stock_get_price(0) : 0, 
        num_string1
    );
    
    text_num_val_mapping text_num2_module(
        state == USER_TABLE_STATE  ? account_get_stock(user_id, 0):
        state == STOCK_TABLE_STATE ? stock_get_price(1) : 0, 
        num_string2
    );
    
    text_num_val_mapping text_num3_module(
        state == USER_TABLE_STATE  ? account_get_stock(user_id, 1):
        state == STOCK_TABLE_STATE ? stock_get_price(2) : 0, 
        num_string3
    );
    
    text_num_val_mapping text_num4_module(
        state == USER_TABLE_STATE  ? account_get_stock(user_id, 2):
        state == STOCK_TABLE_STATE ? 0 : 0, 
        num_string4
    );

    wire [8*15-1:0] line1 = (
        state == USER_TABLE_STATE  ? {"USER       ", num_string1} :
        state == STOCK_TABLE_STATE ? "PRICES         " : 
        ""
    );
    wire [8*15-1:0] line2 = (
        state == USER_TABLE_STATE  ? {"BALANCE    ", num_string1}: 
        state == STOCK_TABLE_STATE ? {"AAPL       ", num_string1}: 
        "               "
    );
    
    wire [8*15-1:0] line3 = (
        state == USER_TABLE_STATE  ? {"AAPL QTY   ", num_string2} : 
        state == STOCK_TABLE_STATE ? {"GOOG       ", num_string2} : 
        "               "
    );
    
    wire [8*15-1:0] line4 = (
        state == USER_TABLE_STATE  ? {"GOOG QTY   ", num_string3}: 
        state == STOCK_TABLE_STATE ? {"BABA       ", num_string3}: 
        "               "
    );
    wire [8*15-1:0] line5 = {
        state == USER_TABLE_STATE  ? {"BABA QTY   ", num_string4}: 
        state == STOCK_TABLE_STATE ? "       ": 
        "               "
    };
    
    wire [15:0]     menu_text_colour;
    
    assign text_lines = state == MENU_STATE ? menu_text_lines : {line1, line2, line3, line4, line5};
    assign text_colour = state == MENU_STATE ? menu_text_colour : (xpos >= 49 ? constant.CYAN : constant.WHITE);
            
    
    
    /* --- OLED ------------------------------------------------------------- */
    reg master_menu_reset;
    reg [2:0] master_button_state;
    
    
    wire [8*15*5-1:0] menu_text_lines;

    master_menu menu(
        .clk(clk), .reset(master_menu_reset),
        .ypos(ypos), 
        .text_colour(menu_text_colour), .text_lines(menu_text_lines),
        .button_state(master_button_state)
    );
     
    wire [15:0] num2_pixel_data;
    text_dynamic #(14) text_num2_display_module(
        .x(xpos), .y(ypos), 
        .color(constant.CYAN), .background(constant.BLACK), 
        .text_y_pos(20), 
        .string({num_string4, " ", num_string5, " ", num_string6}), 
        .offset(0), 
        .repeat_flag(0), .x_pos_offset(0), .pixel_data(num2_pixel_data));

    reg prev_btnC, prev_btnU, prev_btnR, prev_btnL, prev_btnD;
    task button_control();
    begin
            /*if (prev_btnU == 1 && btnU == 0) begin
                key_in_value <= key_in_value + 1;
                debounce <= 1;
            end*/
            prev_btnC <= btnC; prev_btnU <= btnU; prev_btnL <= btnL; 
            prev_btnR <= btnR; prev_btnD <= btnD;
    end
    endtask
    
    task state_menu_handle(); begin
        if (prev_btnC == 1 && btnC == 0) begin
            if (master_button_state == 0) begin
                state <= USER_TABLE_STATE;
            end else if (master_button_state == 1) begin
                state <= STOCK_TABLE_STATE;
            end else if (master_button_state == 2) begin
                state <= GRAPH_STATE;
            end
            master_button_state <= 0;
        end
        if (prev_btnU == 1 && btnU == 0) begin
            master_button_state <= master_button_state == 0 ? 2 : master_button_state - 1;
        end
        if (prev_btnD == 1 && btnD == 0) begin
            master_button_state <= master_button_state == 2 ? 0 : master_button_state + 1;
        end
    end
    endtask
    
    task btnC_handle(); begin
        if (prev_btnC == 1 && btnC == 0) begin
            state <= MENU_STATE;
        end
        if (prev_btnL == 1 && btnL == 0) begin
            user_id <= user_id == 0 ? 2 : user_id - 1;
        end
        if (prev_btnR == 1 && btnR == 0) begin
            user_id <= user_id == 2 ? 0 : user_id + 1;
        end
    end endtask
    
    always @ (posedge clk) begin
        case (state)
        MENU_STATE: state_menu_handle();
        USER_TABLE_STATE: btnC_handle();
        STOCK_TABLE_STATE: btnC_handle();
        GRAPH_STATE: btnC_handle();
        endcase
        button_control();
    end
    
    always @ (*) begin
        xpos = oled_pixel_index % 96;
        ypos = oled_pixel_index / 96;
        case (state)
        MENU_STATE: oled_pixel_data <= 0;
        USER_TABLE_STATE: oled_pixel_data <= 0;
        STOCK_TABLE_STATE: oled_pixel_data <= 0;
        GRAPH_STATE: oled_pixel_data <= constant.YELLOW;
        endcase
    end
endmodule

