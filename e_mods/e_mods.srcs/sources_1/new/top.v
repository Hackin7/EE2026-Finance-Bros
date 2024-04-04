`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//  STUDENT A NAME: 
//  STUDENT B NAME:
//  STUDENT C NAME: 
//  STUDENT D NAME:  
//
//////////////////////////////////////////////////////////////////////////////////


module top (
    // Control
    input clk,
    // LEDs, Switches, Buttons
    input btnC, btnU, btnL, btnR, btnD, input [15:0] sw, output [15:0] led,
    // 7 Segment Display
    output [6:0] seg, output dp, output [3:0] an,
    // UART
    input rxUSB, output txUSB,
    input rx0, rx1, rx2,
    output tx0, tx1, tx2,
    // OLED PMOD
    inout [7:0] JB,
    inout mouse_ps2_clk, mouse_ps2_data
);
    /*
    rx0 tx0 rx1 tx1 rx2 tx2
    JA0 JA1 JA2 JA3 JA7 JA8
    */
    //// Setup ///////////////////////////////////////////////////////////////////////////////////////////////////////
    //// Clocks /////////////////////////////////////////////
    wire clk_6_25mhz;
    clk_counter #(8, 8, 32) clk6p25m (clk, clk_6_25mhz);

    //// 3.A OLED Setup //////////////////////////////////////
    // Inputs
    wire [7:0] Jx;
    assign JB[7:0] = Jx;
    // Outputs
    wire [12:0] oled_pixel_index;
    wire [15:0] oled_pixel_data;
    // Module
    Oled_Display display(
        .clk(clk_6_25mhz), .reset(0), 
        .frame_begin(), .sending_pixels(), .sample_pixel(), .pixel_index(oled_pixel_index), .pixel_data(oled_pixel_data), 
        .cs(Jx[0]), .sdin(Jx[1]), .sclk(Jx[3]), .d_cn(Jx[4]), .resn(Jx[5]), .vccen(Jx[6]), .pmoden(Jx[7])); //to SPI
    
    //// 3.A OLED Text Module //////////////////////////////////////
    parameter STR_LEN = 15;
    wire [7:0] oled_xpos = oled_pixel_index % 96;
    wire [7:0] oled_ypos = oled_pixel_index / 96;
    wire [15:0] text_pixel_data;
    
    wire [8*STR_LEN*5-1:0] text_lines;
    wire [15:0] text_colour;
    
    text_dynamic_multiline #(STR_LEN) text_display_module(
        .xpos(oled_xpos), .ypos(oled_ypos), 
        .colour(text_colour), 
        .line1(text_lines[8*STR_LEN*5-1:8*STR_LEN*4]), 
        .line2(text_lines[8*STR_LEN*4-1:8*STR_LEN*3]), 
        .line3(text_lines[8*STR_LEN*3-1:8*STR_LEN*2]), 
        .line4(text_lines[8*STR_LEN*2-1:8*STR_LEN*1]), 
        .line5(text_lines[8*STR_LEN*1-1:8*STR_LEN*0]), 
        .oled_pixel_data(text_pixel_data) 
    );

    //// 3.B Mouse Setup /////////////////////////////////////
    /*
    wire mouse_reset; // cannot hardcode to 1 for some reason
    wire [11:0] mouse_xpos;
    wire [11:0] mouse_ypos;
    wire [3:0] mouse_zpos;
    wire mouse_left_click;
    wire mouse_middle_click;
    wire mouse_right_click;
    wire mouse_new_event;
    MouseCtl mouse(
        .clk(clk), .rst(mouse_reset), .value(11'b0), .setx(0), .sety(0), .setmax_x(96), .setmax_y(64),
        .xpos(mouse_xpos), .ypos(mouse_ypos), .zpos(mouse_zpos), 
        .left(mouse_left_click), .middle(mouse_middle_click), .right(mouse_right_click), .new_event(mouse_new_event),
        .ps2_clk(mouse_ps2_clk), .ps2_data(mouse_ps2_data)
    );*/
    //// UART //////////////////////////////////////////////
    //// UART //////////////////////////////////////////////
    // wire rx; //assign rx = sw[15] ? rxUSB : rx0; // Receive data to board - send from PC/ master
    // wire tx; assign txUSB = tx; assign tx0 = tx;

    parameter DBITS = 8;
    parameter UART_FRAME_SIZE = 8;
    wire uart_rx_clear;
    wire uart_tx_trigger;
    wire [UART_FRAME_SIZE*DBITS-1:0] uart_rx;
    wire [UART_FRAME_SIZE*DBITS-1:0] uart_tx;
    // Complete UART Core
    uart_module 
        #(
            .FIFO_IN_SIZE(UART_FRAME_SIZE),
            .FIFO_OUT_SIZE(UART_FRAME_SIZE),
            .FIFO_OUT_SIZE_EXP(32)
        ) 
        UART_UNIT
        (
            .clk_100MHz(clk),
            .rx(rx0), .tx(tx0),
            // .rx_full(rx_full), .rx_empty(rx_empty), .rx_tick(rx_tick),
            .rx_out(uart_rx),
            .rx_clear(uart_rx_clear),
            .tx_trigger(uart_tx_trigger),
            .tx_in(uart_tx)
        );

    wire uart1_rx_clear;
    wire uart1_tx_trigger;
    wire [UART_FRAME_SIZE*DBITS-1:0] uart1_rx;
    wire [UART_FRAME_SIZE*DBITS-1:0] uart1_tx;
    // Complete UART Core
    uart_module 
        #(
            .FIFO_IN_SIZE(UART_FRAME_SIZE),
            .FIFO_OUT_SIZE(UART_FRAME_SIZE),
            .FIFO_OUT_SIZE_EXP(32)
        ) 
        UART1_UNIT
        (
            .clk_100MHz(clk),
            .rx(rx1), .tx(tx1),
            // .rx_full(rx_full), .rx_empty(rx_empty), .rx_tick(rx_tick),
            .rx_out(uart1_rx),
            .rx_clear(uart1_rx_clear),
            .tx_trigger(uart1_tx_trigger),
            .tx_in(uart1_tx)
        );
    wire uart2_rx_clear;
    wire uart2_tx_trigger;
    wire [UART_FRAME_SIZE*DBITS-1:0] uart2_rx;
    wire [UART_FRAME_SIZE*DBITS-1:0] uart2_tx;
    // Complete UART Core
    uart_module 
        #(
            .FIFO_IN_SIZE(UART_FRAME_SIZE),
            .FIFO_OUT_SIZE(UART_FRAME_SIZE),
            .FIFO_OUT_SIZE_EXP(32)
        ) 
        UART2_UNIT
        (
            .clk_100MHz(clk),
            .rx(rx2), .tx(tx2),
            // .rx_full(rx_full), .rx_empty(rx_empty), .rx_tick(rx_tick),
            .rx_out(uart2_rx),
            .rx_clear(uart2_rx_clear),
            .tx_trigger(uart2_tx_trigger),
            .tx_in(uart2_tx)
        );

    //// Intro Page ////////////////////////////////////////////////////////////////////////////////////////////////////
    // Temporary intro page
    constants constant();
    wire [15:0] intro_text_colour = constant.WHITE;
    wire [15*4*8-1:0]  intro_text_lines = {
        "EE2026         ",
        "FINANCE BROS   ",
        "               ",
        "TRUST US BRO   ", 
        "               "
    };

    //// Master Module //////////////////////////////////////////////////////////////////////////////////////////////////
    wire master_reset;
    wire [15:0] master_led; 
    wire [6:0] master_seg;
    wire master_dp;
    wire [3:0] master_an;
    wire [UART_FRAME_SIZE*DBITS-1:0] master_uart_tx;
    wire master_uart_tx_trigger;
    wire master_uart_rx_clear;
    wire [15:0] master_oled_pixel_data;

    wire [8*STR_LEN*5-1:0] master_text_lines;
    wire [15:0] master_text_colour;
    //assign text_colour = master_text_colour;

    module_master master_module(
        .reset(master_reset), .clk(clk),
        .btnC(btnC), .btnU(btnU), .btnL(btnL), .btnR(btnR), .btnD(btnD), .sw(sw), .led(master_led), 
        .seg(master_seg), .dp(master_dp), .an(master_an),
        // UART
        .uart_rx(uart_rx), .uart_tx(master_uart_tx),
        .uart_tx_trigger(master_uart_tx_trigger),
        .uart_rx_clear(master_uart_rx_clear),

        .uart1_rx(uart1_rx), .uart1_tx(uart1_tx),
        .uart1_tx_trigger(uart1_tx_trigger),
        .uart1_rx_clear(uart1_rx_clear),
        
        .uart2_rx(uart2_rx), .uart2_tx(uart2_tx),
        .uart2_tx_trigger(uart2_tx_trigger),
        .uart2_rx_clear(uart2_rx_clear),
        // OLED
        .oled_pixel_index(oled_pixel_index), .oled_pixel_data(master_oled_pixel_data),
        // OLED Text
        .text_lines(master_text_lines), .text_colour(master_text_colour)
        /*
        .mouse_xpos(mouse_xpos), .mouse_ypos(mouse_ypos), .mouse_zpos(mouse_zpos),
        .mouse_left_click(mouse_left_click), .mouse_middle_click(mouse_middle_click),
        .mouse_right_click(mouse_right_click), .mouse_new_event(mouse_new_event)*/
    );

    //// Slave //////////////////////////////////////////////////////////////////////////////////////////////////
    wire slave_reset=0;
    wire [15:0] slave_led; 
    wire [6:0] slave_seg; 
    wire slave_dp;
    wire [3:0] slave_an;
    wire slave_uart_tx_trigger;
    wire slave_uart_rx_clear;
    wire [UART_FRAME_SIZE*DBITS-1:0] slave_uart_tx;
    wire [15:0] slave_oled_pixel_data;

    wire [8*STR_LEN*5-1:0] slave_text_lines;
    wire [15:0] slave_text_colour;
    //assign text_colour = slave_text_colour;

    menuCode slave_menu(
        .clk(clk), .reset(slave_reset) , .sw(sw),.led(slave_led),
        .btnC(btnC), .btnU(btnU), .btnR(btnR), .btnL(btnL), .btnD(btnD),
        .oled_pixel_index(oled_pixel_index), .oled_pixel_data(slave_oled_pixel_data),
        // OLED Text
        .text_lines(slave_text_lines), .text_colour(slave_text_colour), 

        .seg(slave_seg), .dp(slave_dp), .an(slave_an), 
        
        .uart_rx(uart_rx),
        .uart_tx(slave_uart_tx),
        .uart_tx_trigger(slave_uart_tx_trigger),
        .uart_rx_clear(slave_uart_rx_clear)
    );
        
    //// Overall Control Logic ////////////////////////////////////////////////////////////////////////////////////
    // 4.E1
    wire enable_mode_master = sw[0];
    wire enable_mode_slave = sw[1];
    
    assign led = enable_mode_master ? master_led : (enable_mode_slave ? slave_led: {11'd0, rxUSB, rx0, rx1, rx2, rx0});//16'hFFFF);
    assign seg = enable_mode_master ? master_seg : (enable_mode_slave ? slave_seg: 7'b1111111);
    assign dp = enable_mode_master ? master_dp : (enable_mode_slave ? slave_dp : 1);
    assign an = enable_mode_master ? master_an : (enable_mode_slave ? slave_an :  4'b1111);
    assign uart_tx = enable_mode_master ? master_uart_tx : (enable_mode_slave ? slave_uart_tx :  1'b0);
    assign uart_tx_trigger = enable_mode_master ? master_uart_tx_trigger : (enable_mode_slave ? slave_uart_tx_trigger :  1'b0);
    assign uart_rx_clear = enable_mode_master ? master_uart_rx_clear : (enable_mode_slave ? slave_uart_rx_clear :  1'b0);
    assign oled_pixel_data = (enable_mode_master ? master_oled_pixel_data : (enable_mode_slave ? slave_oled_pixel_data : 16'h0)) | text_pixel_data;
    assign text_lines = (enable_mode_master ? master_text_lines : (enable_mode_slave ? slave_text_lines : intro_text_lines));
    assign text_colour = (enable_mode_master ? master_text_colour : (enable_mode_slave ? slave_text_colour : intro_text_colour));
endmodule
