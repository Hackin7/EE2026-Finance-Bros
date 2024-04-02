`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.03.2024 19:46:50
// Design Name: 
// Module Name: menuCode
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


module menuCode#(
    parameter DBITS=8, UART_FRAME_SIZE=8, RX_DEBOUNCE=1, RX_TIMEOUT=100_000_000 // 1s
)(
        input clk, reset,
        input btnC, btnU, btnR, btnL, btnD,
        input [15:0] sw, output [15:0] led, 
        input [12:0] oled_pixel_index, output [15:0] oled_pixel_data,
        output [6:0] seg, output dp, output [3:0] an,
        
        // UART
        input  [UART_FRAME_SIZE*DBITS-1:0] uart_rx,
        output [UART_FRAME_SIZE*DBITS-1:0] uart_tx,
        output uart_tx_trigger,
        output uart_rx_clear
    );
    wire [12:0] pixel_index = oled_pixel_index;
    reg [15:0] pixel_data = 16'b0;
    assign oled_pixel_data = pixel_data;
    reg [6:0] control_seg;
    reg control_dp;
    reg [3:0] control_an;
    assign seg = control_seg;
    assign dp = control_dp;
    assign an = control_an;
    //constants library
    constants constant();
    
    //page one
    reg pageOne_reset = 1;
    wire [15:0] pageOne_pixel_data;
    wire [6:0] pageOne_seg;
    wire pageOne_dp;
    wire [3:0] pageOne_an;
    wire [31:0] price, qty, stock_id;
    wire action;
    wire pageOne_done;
    slaveTradePage pageOne(
        .clk(clk), .reset(pageOne_reset), .btnC(btnC), .btnU(btnU), .btnR(btnR), .btnL(btnL), .btnD(btnD),
        .sw(sw), .pixel_index(oled_pixel_index), .oled_pixel_data(pageOne_pixel_data),
        .seg(pageOne_seg), .dp(pageOne_dp), .an(pageOne_an),
        .stock_id(stock_id), .price(price), .quantity(qty), .action(action), .done(pageOne_done)
    );
    
    //menu page
    wire [15:0] menu_page_pixel_data;
    reg menu_page_reset;
    wire [6:0] menu_seg;
    wire menu_dp;
    wire [3:0] menu_an;
    reg [3:0] menu_button_state;
    slaveMenuPage menuPage(
        .clk(clk), .reset(menu_page_reset), .btnC(btnC), .btnU(btnU), .btnR(btnR), .btnL(btnL), .btnD(btnD),
        .sw(sw), .pixel_index(oled_pixel_index), .oled_pixel_data(menu_page_pixel_data),
        .seg(menu_seg), .dp(menu_dp), .an(menu_an), .menu_button_state(menu_button_state)
    );

    //input id page
    reg set_id_reset;
    wire [15:0] input_id_pixel_data;
    wire [6:0] input_id_seg;
    wire input_id_dp;
    wire [3:0] input_id_an;
    wire [31:0] account_id;
    wire input_id_done;
    set_id slave_input_id(
        .clk(clk), .reset(set_id_reset),
        .btnC(btnC), .btnU(btnU), .btnR(btnR), .btnL(btnL), .btnD(btnD),
        .sw(sw), .pixel_index(oled_pixel_index), .oled_pixel_data(input_id_pixel_data),
        .seg(input_id_seg), .dp(input_id_dp), .an(input_id_an), .account_id(account_id),
        .done(input_id_done)
    );
    
    //table page
    reg [3:0] self_status_state = 0;
    wire [8*4-1:0] self_status_state_string;
    text_num_val_mapping text_num1_module(self_status_state, self_status_state_string);
    wire [15:0] table_view_loading_pixel_data;
    wire [7:0] xpos = oled_pixel_index % 96; wire [7:0] ypos = oled_pixel_index / 96;
    text_dynamic #(12) table_view_loading(
        .x(xpos), .y(ypos), 
        .color(constant.WHITE), .background(constant.BLACK), 
        .text_y_pos(56), .string({"LOADING ", self_status_state_string}), .offset(0), //9*6), 
        .repeat_flag(0), .x_pos_offset(0), .pixel_data(table_view_loading_pixel_data));
    
    wire [15:0] table_view_ready_pixel_data;
    reg [31:0] table_balance = 0;
    reg [7:0] table_stock1 = 9999;
    reg [7:0] table_stock2 = 9999;
    reg [7:0] table_stock3 = 9999;
    wire table_view_reset;
    wire [31:0] trade_slave_balance; 
    slave_table_view table_view(
        .clk(clk), .reset(table_view_reset), 
// HEAD
        .pixel_index(oled_pixel_index), .oled_pixel_data(table_view_ready_pixel_data), 
        .num1(trade_slave_account_id), .num2(table_balance), .num3(table_stock1), .num4(table_stock2), .num5(table_stock3), .num6(0)
    );
    wire [15:0] table_view_pixel_data = table_view_ready_pixel_data | (self_status_state != 3 ? table_view_loading_pixel_data : 0);
/*
        .pixel_index(oled_pixel_index), .oled_pixel_data(table_view_pixel_data),
        .balance(trade_slave_balance), .account_id(account_id)
    );
 slave-ui-menus*/

    /* UART Control --------------------------------------------------------------------*/
    trade_packet_former trade_packet();
    reg [7:0] trade_slave_type = trade_packet.TYPE_INVALID;
    reg [7:0] trade_slave_account_id = 0;
    reg [7:0] trade_slave_stock_id = 0;
    reg [7:0] trade_slave_qty = 0;
    reg [7:0] trade_slave_price = 0;

    reg trade_slave_trigger = 0;
    wire [7:0] trade_slave_send_status;
    wire [31:0] trade_slave_get_balance;
    wire [7:0] trade_slave_get_stock1;
    wire [7:0] trade_slave_get_stock2;
    wire [7:0] trade_slave_get_stock3;
    trade_module_slave 
        #(
         .DBITS(DBITS), .UART_FRAME_SIZE(UART_FRAME_SIZE), .RX_TIMEOUT(100_000_000)
        )
        trade_slave (
        .clk_100MHz(clk), .reset(),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .uart_tx_trigger(uart_tx_trigger),
        .uart_rx_clear(uart_rx_clear),
        // Trade Parameters
        .tx_type(trade_slave_type),
        .tx_account_id(trade_slave_account_id),
        .tx_stock_id(trade_slave_stock_id),
        .tx_qty(trade_slave_qty),
        .tx_price(trade_slave_price),
        .trigger(trade_slave_trigger),
        .send_status(trade_slave_send_status), 
        .balance(trade_slave_get_balance),
        .stock1(trade_slave_get_stock1),
        .stock2(trade_slave_get_stock2),
        .stock3(trade_slave_get_stock3),
        .led(led), .sw(sw)
    );
    
    //current trade page
        wire [15:0] last_packet_pixel_data;
        view_packet last_packet(
            .price(trade_slave_price), .quantity(trade_slave_qty), 
            .stock_id(trade_slave_stock_id), .action(trade_slave_type),
            .pixel_index(oled_pixel_index), .packet_pixel_data(last_packet_pixel_data)
        );

    // Logic
    parameter TRADE_SUCCESS_SHOW = 200_000_000; // 2 seconds
    reg [31:0] trade_module_send_success = 0;
    task trade_module_slave_processing();
    begin
        trade_module_send_success <= trade_module_send_success == 0 ? 0 : trade_module_send_success - 1;
        if (trade_slave_send_status == trade_slave.STATUS_FAIL) begin
            trade_slave_trigger <= 1; // retry if fail
        end else if (trade_slave_send_status == trade_slave.STATUS_OK) begin
            trade_module_send_success <= TRADE_SUCCESS_SHOW; // show success screen
            trade_slave_type <= trade_packet.TYPE_INVALID; // label that it is not sending anymore
        end
    end
    endtask
    /* Button Control Code --------------------------------------------------------------*/
    reg prev_btnC=0, prev_btnU=0, prev_btnL=0, prev_btnR=0, prev_btnD=0;

    reg debounce = 0;
    reg [31:0] debounce_timer = 0;
    parameter DEBOUNCE_TIME = 30_000_000; // 100ms
    

    task button_control();
    begin
        if (debounce) begin
            debounce_timer <= debounce_timer + 1;
            if (debounce_timer > DEBOUNCE_TIME-1) begin
                debounce <= 0;
                debounce_timer <= 0;
            end
        end else begin
            /*if (prev_btnU == 1 && btnU == 0) begin
                key_in_value <= key_in_value + 1;
                debounce <= 1;
            end*/
            prev_btnC <= btnC; prev_btnU <= btnU; prev_btnL <= btnL; 
            prev_btnR <= btnR; prev_btnD <= btnD;
        end
    end
    endtask
    
    /* State Machine Code ------------------------------------------------------------------*/
    reg [3:0] state = 4'd6;
    parameter STATE_INPUT_SLAVE_ID = 6;
    parameter STATE_MENU = 1;
    parameter STATE_ADD_TRADE = 2;
    parameter STATE_FAIL_ADD_TRADE = 3;
    parameter STATE_TABLE_VIEW = 4;
    parameter STATE_CURRENT_TRADE = 5;

    task state_set_id_handle(); begin
        if (prev_btnC == 1 && btnC == 0) begin
            trade_slave_account_id <= account_id;
            debounce <= 1;
            set_id_reset <= 1;
            state <= STATE_MENU;
        end
    end
    endtask

    task state_menu_handle();
    begin
        if (!debounce) begin
            if (prev_btnC == 1 && btnC == 0) begin
                debounce <= 1;
                if (menu_button_state == 0) begin
                    state <= STATE_TABLE_VIEW;
                end else if (menu_button_state == 1) begin
                    state <= STATE_CURRENT_TRADE;
                end else if (menu_button_state == 2) begin
                    state <= STATE_ADD_TRADE;
                    pageOne_reset <= 0;
                end else if (menu_button_state == 3) begin
                    state <= STATE_INPUT_SLAVE_ID;
                    set_id_reset <= 0;
                end
                menu_button_state <= 0;
            end
            if (prev_btnU == 1 && btnU == 0) begin
                menu_button_state <= menu_button_state == 0 ? 3 : menu_button_state - 1;
                debounce <= 1;
            end
            if (prev_btnD == 1 && btnD == 0) begin
                menu_button_state <= menu_button_state == 3 ? 0 : menu_button_state + 1;
                debounce <= 1;
            end
        end
    end
    endtask


    task state_add_trade_handle();
    begin
        if (pageOne_done) begin
            state <= STATE_MENU;
            pageOne_reset <= 1;
            //trade_slave_account_id <= account_id;
            //trade_slave_type <= sw[15] ? trade_packet.TYPE_SELL : trade_packet.TYPE_BUY;
            trade_slave_account_id <= account_id;
            trade_slave_type <= action ? trade_packet.TYPE_SELL : trade_packet.TYPE_BUY;
            trade_slave_stock_id <= stock_id;
            trade_slave_qty <= qty;
            trade_slave_price <= price;
            trade_slave_trigger <= 1;
            debounce <= 1;
        end
    end
    endtask
    
    task state_table_handle();
    begin
        if (!debounce) begin
            if (prev_btnL == 1 && btnL == 0) begin
                state <= STATE_MENU;
                self_status_state <= 0;
                trade_slave_type <= prev_trade_slave_type; // label that it is not sending anymore
                trade_slave_trigger <= 1;
                debounce <= 1;
            end
        end
        if (self_status_state == 0) begin // Initialise Loading
                prev_trade_slave_type <= trade_slave_type;
                trade_slave_type <= trade_packet.TYPE_GET_ACCOUNT_BALANCE;
                trade_slave_trigger <= 1;
                self_status_state <= 1;
            end else if (self_status_state == 1) begin // Wait for other balance
                if (trade_slave_send_status == trade_slave.STATUS_RETRIEVED) begin
                    table_balance <= trade_slave_get_balance;
                    trade_slave_type <= trade_packet.TYPE_GET_ACCOUNT_STOCKS; // label that it is not sending anymore
                    trade_slave_trigger <= 1;
                    self_status_state <= 2;
                end
            end else if (self_status_state == 2) begin
                if (trade_slave_send_status == trade_slave.STATUS_RETRIEVED) begin
                    table_stock1 <= trade_slave_get_stock1;
                    table_stock2 <= trade_slave_get_stock2;
                    table_stock3 <= trade_slave_get_stock3;
                    trade_slave_type <= prev_trade_slave_type; // label that it is not sending anymore
                    trade_slave_trigger <= 1;
                    self_status_state <= 3;
                end
            end else if (self_status_state == 3) begin
                if (!debounce) begin
                    if (prev_btnC == 1 && btnC == 0) begin
                        state <= STATE_MENU;
                        self_status_state <= 0;
                        debounce <= 1;
                    end
                end
            end else begin
                self_status_state <= 0; // reload state
            end
    end
    endtask
    
    reg [7:0] prev_trade_slave_type;
    
    task state_current_trade_handle();
    begin
        if (!debounce) begin
            if (prev_btnC == 1 && btnC == 0) begin
                state <= STATE_MENU;
                self_status_state <= 0;
                debounce <= 1;
            end
        end
    end
    endtask
    // Debugger
    /*assign led[5] = pageOne_done;
    assign led[4] = pageOne_reset;
    assign led[3:0] = state;*/
    
    /* Multiplexer -------------------------------------*/ 
    always @ (posedge clk) begin
        trade_slave_trigger <= 0;
        if (reset) begin
            state <= 4'd0;
        end else if (state == STATE_INPUT_SLAVE_ID) begin
            state_set_id_handle();
        end else if (state == STATE_MENU) begin
            state_menu_handle();
        end else if (state == STATE_ADD_TRADE) begin
            state_add_trade_handle();
        end else if (state == STATE_FAIL_ADD_TRADE) begin
        end else if (state == STATE_TABLE_VIEW) begin
            state_table_handle();
        end else if (state == STATE_CURRENT_TRADE) begin
            state_current_trade_handle();
        end
        button_control();
        trade_module_slave_processing();
    end

    always @ (*) begin
        if (trade_module_send_success > 0) begin
            pixel_data <= constant.GREEN;   
        end else if (state == STATE_INPUT_SLAVE_ID) begin
            pixel_data <= input_id_pixel_data;
            control_seg <= input_id_seg;
            control_an <= input_id_an;
            control_dp <= input_id_dp;
        end else if (state == STATE_MENU) begin
            pixel_data <= menu_page_pixel_data;
            control_seg <= menu_seg;
            control_dp <= menu_dp;
            control_an <= menu_an;
        end else if (state == STATE_ADD_TRADE) begin
            pixel_data <= pageOne_pixel_data;
            control_seg <= pageOne_seg;
            control_dp <= pageOne_dp;
            control_an <= pageOne_an;
        end else if (state == STATE_FAIL_ADD_TRADE) begin
            pixel_data <= constant.RED;
        end else if (state == STATE_TABLE_VIEW) begin
            pixel_data <= table_view_pixel_data;
        end else if (state == STATE_CURRENT_TRADE) begin
            pixel_data <= last_packet_pixel_data;
        end
    end

endmodule
