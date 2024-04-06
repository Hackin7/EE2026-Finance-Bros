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
    output reg [15:0] oled2_pixel_data,
    // OLED Text Module
    output [8*STR_LEN*7-1:0] text_lines, output [15:0] text_colour,
    
    // Mouse - NOT NEEDED
    input [11:0] mouse_xpos,  mouse_ypos, input [3:0] mouse_zpos,
    input mouse_left_click, mouse_middle_click, mouse_right_click, mouse_new_event
);
    // 2nd OLED Text module ////////////////////////////////////////////////////////////////
    //constants library
    constants constant();

    wire [7:0] xpos = oled_pixel_index % 96, ypos = oled_pixel_index / 96;

    wire [15:0] text_pixel_data;
    //reg [8*STR_LEN*7-1:0] oled2_text_lines;
    /*assign oled2_text_lines = text_lines;
    text_dynamic_multiline #(STR_LEN) text_display_module(
        .xpos(xpos), .ypos(ypos), 
        .colour(text_colour), 
        .line1(text_lines[8*STR_LEN*7-1:8*STR_LEN*6]), 
        .line2(text_lines[8*STR_LEN*6-1:8*STR_LEN*5]), 
        .line3(text_lines[8*STR_LEN*5-1:8*STR_LEN*4]), 
        .line4(text_lines[8*STR_LEN*4-1:8*STR_LEN*3]), 
        .line5(text_lines[8*STR_LEN*3-1:8*STR_LEN*2]), 
        .line6(text_lines[8*STR_LEN*2-1:8*STR_LEN*1]), 
        //.line7(text_lines[8*STR_LEN*1-1:8*STR_LEN*0]), 
        .oled_pixel_data(text_pixel_data) 
    );
    */
    /////////////////////////////////////////////////////////////////////////////////////
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
    
    wire encrypted0 = sw[5], encrypted1 = sw[6], encrypted2 = sw[7];
    wire decrypted0 = sw[8], decrypted1 = sw[9], decrypted2 = sw[10];
    wire [63:0] prev_uart_rx;

    trade_module_master 
        #(
         .DBITS(8), .UART_FRAME_SIZE(8)
        )
        trade_slave (
        .clk_100MHz(clk), .reset(),
        .encrypted0(encrypted0), .encrypted1(encrypted1), .encrypted2(encrypted2),
        .decrypted0(decrypted0), .decrypted1(decrypted1), .decrypted2(decrypted2),
        .uart_rx(uart_rx), .uart_tx(uart_tx),
        .uart_tx_trigger(uart_tx_trigger),
        .uart_rx_clear(uart_rx_clear),
        .prev_uart_rx(prev_uart_rx),
        
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
    parameter ENCRYPTED_STATE = 5;

    reg [2:0] user_id = 0;
    wire [8*(4)-1:0] num_string1, num_string2, num_string3, num_string4;
    text_num_val_mapping text_num1_module(
        state == USER_TABLE_STATE  ? (
            ypos < 10 ? user_id : 
                        account_get_balance(user_id)):
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

    wire [8*15*7-1:0] table_text_lines = (state == USER_TABLE_STATE  ? 
                                         {"USER       ", num_string1, 
                                          "BALANCE    ", num_string1,
                                          "AAPL QTY   ", num_string2,
                                          "GOOG QTY   ", num_string3,
                                          "BABA QTY   ", num_string4,
                                          "               ",
                                          "               "} :
                                          state == STOCK_TABLE_STATE ? 
                                         {"PRICES         ",
                                          "AAPL       ", num_string1,
                                          "GOOG       ", num_string2,
                                          "BABA       ", num_string3,
                                          "               ",
                                          "               ",
                                          "               "} : 
                                          "");

    wire [8*12-1:0] mapped_uart, mapped_decrypt;
    wire [63:0] decrypted_packet;
    encryption decryptor(.action(1),
            .seed(0), .data_in(prev_uart_rx), .data_out(decrypted_packet));
    binary_to_hex uart_mapping(prev_uart_rx[55:8], mapped_uart);
    binary_to_hex decrypt_mapping(decrypted_packet[55:8], mapped_decrypt);
    wire [8*15*7-1:0] encrypted_text_lines = {"ENCRYPTED      ",
                                              mapped_uart, "   ",
                                              "DECRYPTED      ",
                                              mapped_decrypt, "   ",
                                              "               ",
                                              "               ",
                                              "               "};
    wire [15:0] encrypted_text_colour = constant.WHITE;
    
    
    /* --- Data Change ------------------------------------------------------------- */
    parameter TIME = 3;
    reg [8*TIME-1:0] line_appl = 'ha9_a9_a9;
    reg [8*TIME-1:0] line_goog  = 'ha0_a0_a0;
    reg [8*TIME-1:0] line_baba  = 'h90_90_90;

    always @ (posedge clk) begin
        if (line_appl[7:0] != stock_get_price(0) |
            line_goog[7:0] != stock_get_price(1) | 
            line_baba[7:0] != stock_get_price(2)
        ) begin 
            line_appl <= line_appl << 8 | stock_get_price(0);
            line_goog <= line_goog << 8 | stock_get_price(1);
            line_baba <= line_baba << 8 | stock_get_price(2);
        end
    end
    
    function [7:0] normalize_y(input [7:0] val);
    begin
        normalize_y = (val - 155) * 2;
    end
    endfunction

    wire [8*TIME-1:0] line_red   = line_appl;
    wire [8*TIME-1:0] line_blue  = line_goog;
    wire [8*TIME-1:0] line_green = line_baba;

    wire [15:0] graph_pixel_data;
    reg [2:0] current_graph_stock = 0;
    graphs graph_module(
        .reset(0), .clk(clk), 
        .btnC(btnC), .btnU(btnU), .btnL(btnL), .btnR(btnR), .btnD(btnD), .stock_id(current_graph_stock),
        //.sw(sw), .led(led), .seg(seg), .dp(dp), .an(an),
        .oled_pixel_index(oled_pixel_index), .oled_pixel_data(graph_pixel_data),
        // Line 1
        .x_point1(35), .y_point1(normalize_y(line_green[23:16])), 
        .x_point2(60), .y_point2(normalize_y(line_green[15:8 ])), 
        .x_point3(85), .y_point3(normalize_y(line_green[7:0])),
        // Line 1
        //.x_point4(35), 
        .y_point4(normalize_y(line_blue[23:16])), 
        //.x_point5(60),
        .y_point5(normalize_y(line_blue[15:8 ])), 
        //.x_point6(85), 
        .y_point6(normalize_y(line_blue[ 7:0 ])),
        // Line 1
        //.x_point7(35), 
        .y_point7(normalize_y(line_red[23:16])), 
        //.x_point8(60), 
        .y_point8(normalize_y(line_red[15:8 ])), 
        //.x_point9(85), 
        .y_point9(normalize_y(line_red[ 7:0 ])),
        .mouse_xpos(mouse_xpos), .mouse_ypos(mouse_ypos), 
        .mouse_left_click(mouse_left_click), .mouse_right_click(mouse_right_click)
    );

    /* --- OLED ------------------------------------------------------------- */
    reg master_menu_reset;
    reg [2:0] master_button_state;
    
    wire [15:0] menu_text_colour;
    wire [8*15*7-1:0] menu_text_lines;

    master_menu menu(
        .clk(clk), .reset(master_menu_reset),
        .ypos(ypos), 
        .text_colour(menu_text_colour), .text_lines(menu_text_lines),
        .button_state(master_button_state)
    );
        
    assign text_lines = state == GRAPH_STATE ?      "" : 
                       (state == MENU_STATE ?       menu_text_lines : 
                       (state == ENCRYPTED_STATE ?  encrypted_text_lines :
                                                    table_text_lines));
    assign text_colour = state == MENU_STATE ?      menu_text_colour : 
                        (state == ENCRYPTED_STATE ? encrypted_text_colour :
                        (xpos >= 49 ? constant.CYAN : constant.WHITE));
     
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
            end else if (master_button_state == 3) begin
                state <= ENCRYPTED_STATE;
            end
            master_button_state <= 0;
        end
        if (prev_btnU == 1 && btnU == 0) begin
            master_button_state <= master_button_state == 0 ? 3 : master_button_state - 1;
        end
        if (prev_btnD == 1 && btnD == 0) begin
            master_button_state <= master_button_state == 3 ? 0 : master_button_state + 1;
        end
    end
    endtask
    
    task btnC_handle(); begin
        if (prev_btnC == 1 && btnC == 0) begin
            state <= MENU_STATE;
            user_id <= 0;
        end
        if (prev_btnL == 1 && btnL == 0) begin
            user_id <= user_id == 0 ? 2 : user_id - 1;
        end
        if (prev_btnR == 1 && btnR == 0) begin
            user_id <= user_id == 2 ? 0 : user_id + 1;
        end
    end endtask

    
    task graph_handle(); begin
        if (prev_btnC == 1 && btnC == 0) begin
            state <= MENU_STATE;
            current_graph_stock <= 0;
        end
        if (prev_btnL == 1 && btnL == 0) begin
            current_graph_stock <= current_graph_stock == 0 ? 2 : current_graph_stock - 1;
        end
        if (prev_btnR == 1 && btnR == 0) begin
            current_graph_stock <= current_graph_stock == 2 ? 0 : current_graph_stock + 1;
        end
    end endtask

    always @ (posedge clk) begin
        case (state)
        MENU_STATE: begin 
        oled_pixel_data <= 0;
        state_menu_handle();
        end
        USER_TABLE_STATE: begin 
        oled_pixel_data <= 0;
        btnC_handle();
        end
        STOCK_TABLE_STATE: begin 
        oled_pixel_data <= 0;
        btnC_handle();
        end 
        GRAPH_STATE: begin 
        oled_pixel_data <= graph_pixel_data;
        graph_handle();
        end
        ENCRYPTED_STATE: begin 
        oled_pixel_data <= 0;
        btnC_handle();
        end 
        default: begin 
        btnC_handle();
        end
        endcase
        button_control();
    end
endmodule
