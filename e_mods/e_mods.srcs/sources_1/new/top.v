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
    input rx, output tx,
    // OLED PMOD
    inout [7:0] JB,
    inout mouse_ps2_clk, mouse_ps2_data
);
    
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
    
    //// 3.B Mouse Setup /////////////////////////////////////
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
    );
    //// UART //////////////////////////////////////////////
    //// UART //////////////////////////////////////////////
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
            .rx(rx), .tx(tx),
            // .rx_full(rx_full), .rx_empty(rx_empty), .rx_tick(rx_tick),
            .rx_out(uart_rx),
            .rx_clear(uart_rx_clear),
            .tx_trigger(uart_tx_trigger),
            .tx_in(uart_tx)
        );
    
    //// Group Task //////////////////////////////////////////////////////////////////////////////////////////////////
    wire master_reset;
    wire [15:0] master_led; 
    wire [6:0] master_seg;
    wire master_dp;
    wire [3:0] master_an;
    wire master_uart_tx_trigger;
    wire master_uart_rx_clear;
    wire [15:0] master_oled_pixel_data;

    /*adaptor_task_group task_group(
        .reset(group_reset), .clk(clk),
        .btnC(btnC), .btnU(btnU), .btnL(btnL), .btnR(btnR), .btnD(btnD), .sw(sw), .led(group_led), 
        .seg(group_seg), .dp(group_dp), .an(group_an),
        .oled_pixel_index(oled_pixel_index), .oled_pixel_data(group_oled_pixel_data),
        .mouse_xpos(mouse_xpos), .mouse_ypos(mouse_ypos), .mouse_zpos(mouse_zpos),
        .mouse_left_click(mouse_left_click), .mouse_middle_click(mouse_middle_click),
        .mouse_right_click(mouse_right_click), .mouse_new_event(mouse_new_event)
    );*/

    //// Slave //////////////////////////////////////////////////////////////////////////////////////////////////
    wire slave_reset=0;
    wire [15:0] slave_led; 
    wire [6:0] slave_seg; 
    wire slave_dp;
    wire [3:0] slave_an;
    wire slave_uart_tx_trigger;
    wire slave_uart_rx_clear;
    wire slave_uart_tx;
    wire [15:0] slave_oled_pixel_data;

    menuCode slave_menu(
        .clk(clk), .reset(slave_reset) , .sw(sw),.led(slave_led),
        .btnC(btnC), .btnU(btnU), .btnR(btnR), .btnL(btnL), .btnD(btnD),
        .oled_pixel_index(oled_pixel_index), .oled_pixel_data(slave_oled_pixel_data),
        .seg(slave_seg), .dp(slave_dp), .an(slave_an), 
        
        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .uart_tx_trigger(slave_uart_tx_trigger),
        .uart_rx_clear(slave_uart_rx_clear)
    );
        
    /*adaptor_task_a task_a(
        .reset(a_reset), .clk(clk),
        .btnC(btnC), .btnU(btnU), .btnL(btnL), .btnR(btnR), .btnD(btnD), .sw(sw), .led(a_led), 
        .seg(a_seg), .dp(a_dp), .an(a_an),
        .oled_pixel_index(oled_pixel_index), .oled_pixel_data(a_oled_pixel_data),
        .mouse_xpos(mouse_xpos), .mouse_ypos(mouse_ypos), .mouse_zpos(mouse_zpos),
        .mouse_left_click(mouse_left_click), .mouse_middle_click(mouse_middle_click),
        .mouse_right_click(mouse_right_click), .mouse_new_event(mouse_new_event)
    );*/

    //// Overall Control Logic ////////////////////////////////////////////////////////////////////////////////////
    // 4.E1
    wire enable_mode_master = sw[0];
    wire enable_mode_slave = sw[1];
    
    assign led = enable_mode_master ? master_led : (enable_mode_slave ? slave_led: 16'hFFFF);
    assign seg = enable_mode_master ? master_seg : (enable_mode_slave ? slave_seg: 7'b1111111);
    assign dp = enable_mode_master ? master_dp : (enable_mode_slave ? slave_dp : 1);
    assign an = enable_mode_master ? master_an : (enable_mode_slave ? slave_an :  4'b1111);
    assign uart_tx_trigger = enable_mode_master ? master_uart_tx_trigger : (enable_mode_slave ? slave_uart_tx_trigger :  1'b0);
    assign uart_rx_clear = enable_mode_master ? master_uart_rx_clear : (enable_mode_slave ? slave_uart_rx_clear :  1'b0);
    assign oled_pixel_data = enable_mode_master ? master_oled_pixel_data : (enable_mode_slave ? slave_oled_pixel_data : 16'hFFFF);

endmodule
