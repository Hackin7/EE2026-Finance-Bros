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
    // Mouse
    inout mouse_ps2_clk, mouse_ps2_data, 
    // VGA
    output hsync,
    output vsync,
    output [11:0] rgb
);
    wire enable_mode_master = sw[0];
    wire enable_mode_slave = sw[1];
    wire enable_mode_raycasting = sw[2];
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
    wire [15:0] oled2_pixel_data;
    wire separate_vga = sw[3];
    // Module
    /*Oled_Display display(
        .clk(clk_6_25mhz), .reset(0), 
        .frame_begin(), .sending_pixels(), .sample_pixel(), .pixel_index(oled_pixel_index), .pixel_data(oled_pixel_data), 
        .cs(Jx[0]), .sdin(Jx[1]), .sclk(Jx[3]), .d_cn(Jx[4]), .resn(Jx[5]), .vccen(Jx[6]), .pmoden(Jx[7])); //to SPI*/
    vga_oled_adaptor adaptor(
        .clk(clk),
        .reset(0),
        .JB(Jx),
        .pixel_index(oled_pixel_index),
        .pixel_data(oled_pixel_data),
        .pixel_data2(oled2_pixel_data),
        .separate_vga(separate_vga),
        .hsync(hsync),
        .vsync(vsync),
        .rgb(rgb)
    );
    
    
    /*
    wire [12:0] oled2_pixel_index;
    wire [15:0] oled2_pixel_data;
    vga_oled_adaptor adaptor(
        .clk(clk),
        .reset(0),
        .JB(),
        .pixel_index(oled2_pixel_index),
        .pixel_data(oled2_pixel_data),
        .hsync(hsync),
        .vsync(vsync),
        .rgb(rgb)
    );
    */
    //// 3.A OLED Text Module //////////////////////////////////////
    parameter STR_LEN = 15;
    wire [7:0] oled_xpos = oled_pixel_index % 96;
    wire [7:0] oled_ypos = oled_pixel_index / 96;
    wire [15:0] text_pixel_data;
    
    wire [8*STR_LEN*7-1:0] text_lines;
    wire [15:0] text_colour;
    
    text_dynamic_multiline #(STR_LEN) text_display_module(
        .xpos(oled_xpos), .ypos(oled_ypos), 
        .colour(text_colour), 
        .line1(text_lines[8*STR_LEN*7-1:8*STR_LEN*6]), 
        .line2(text_lines[8*STR_LEN*6-1:8*STR_LEN*5]), 
        .line3(text_lines[8*STR_LEN*5-1:8*STR_LEN*4]), 
        .line4(text_lines[8*STR_LEN*4-1:8*STR_LEN*3]), 
        .line5(text_lines[8*STR_LEN*3-1:8*STR_LEN*2]), 
        .line6(text_lines[8*STR_LEN*2-1:8*STR_LEN*1]), 
        .line7(text_lines[8*STR_LEN*1-1:8*STR_LEN*0]), 
        .oled_pixel_data(text_pixel_data) 
    );

    // OLED Image Module
    
    wire clk_2s;
    clk_counter #(200_000_000, 200_000_000, 32) clk2s (clk, clk_2s);
    reg [15:0] image_memory [0:7679]; // Adjust size based on image dimensions (96x64 for example)
    initial begin
        $readmemh("stonks.mem", image_memory); // Load the first image data
    end
    wire [15:0] image_pixel_data = image_memory[oled_pixel_index];
    /*wire [7:0] image_load = 0;
    always @ (posedge clk) begin
        if (image_load == 1) begin
            $readmemh("stonks.mem", image_memory);
        end
    end*/
    
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
    wire [15*7*8-1:0]  intro_text_lines = { 
        "               ",
        " EE2026        ",
        " FINANCE BROS  ",
        "               ",
        " TRUST US BRO  ", 
        "               ",
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

    wire [8*STR_LEN*7-1:0] master_text_lines;
    wire [15:0] master_text_colour;

    module_master master_module(
        .reset(master_reset), .clk(clk),
        .btnC(enable_mode_master & btnC), .btnU(enable_mode_master & btnU), 
        .btnL(enable_mode_master & btnL), .btnR(enable_mode_master & btnR), .btnD(enable_mode_master & btnD), 
        .sw(sw), .led(master_led), 
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
        .oled2_pixel_data(oled2_pixel_data),
        // OLED Text
        .text_lines(master_text_lines), .text_colour(master_text_colour),
        .mouse_xpos(mouse_xpos), .mouse_ypos(mouse_ypos), .mouse_zpos(mouse_zpos),
        .mouse_left_click(mouse_left_click), .mouse_middle_click(mouse_middle_click),
        .mouse_right_click(mouse_right_click), .mouse_new_event(mouse_new_event)
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
    wire [8*STR_LEN*7-1:0] slave_text_lines;
    wire [15:0] slave_text_colour;

    menuCode slave_menu(
        .clk(clk), .reset(slave_reset) , .sw(sw),.led(slave_led),
        .btnC(enable_mode_slave & btnC), .btnU(enable_mode_slave & btnU), 
        .btnR(enable_mode_slave & btnR), .btnL(enable_mode_slave & btnL), .btnD(enable_mode_slave & btnD),
        .oled_pixel_index(oled_pixel_index), .oled_pixel_data(slave_oled_pixel_data),
        // OLED Text
        .text_lines(slave_text_lines), .text_colour(slave_text_colour), 

        .seg(slave_seg), .dp(slave_dp), .an(slave_an), 
        
        .uart_rx(uart_rx),
        .uart_tx(slave_uart_tx),
        .uart_tx_trigger(slave_uart_tx_trigger),
        .uart_rx_clear(slave_uart_rx_clear)
    );
    
    //// Raycasting ////////////////////////////////////////////////////////////////////////////////////////////////
    wire raycast_reset=0;
    wire raycast_dp;
    wire [3:0] raycast_an;
    wire raycast_uart_tx_trigger;
    wire raycast_uart_rx_clear;
    wire [UART_FRAME_SIZE*DBITS-1:0] raycast_uart_tx;
    wire [15:0] raycast_oled_pixel_data;
    wire [8*STR_LEN*7-1:0] raycast_text_lines;
    wire [15:0] raycast_text_colour;

    raycasting raycast_module(
        .clk(clk), .reset(raycast_reset),
        .btnC(enable_mode_raycasting & btnC), .btnU(enable_mode_raycasting & btnU), 
        .btnR(enable_mode_raycasting & btnR), .btnL(enable_mode_raycasting & btnL), 
        .btnD(enable_mode_raycasting & btnD),
        .oled_pixel_index(oled_pixel_index), .oled_pixel_data(raycast_oled_pixel_data),
        // OLED Text
        .text_lines(raycast_text_lines), .text_colour(raycast_text_colour), 

        .seg(raycast_seg), .dp(raycast_dp), .an(raycast_an)
        
        /*,.uart_rx(uart_rx),
        .uart_tx(raycast_uart_tx),
        .uart_tx_trigger(raycast_uart_tx_trigger),
        .uart_rx_clear(raycast_uart_rx_clear)*/
    );

    //// Overall Control Logic ////////////////////////////////////////////////////////////////////////////////////
    // 4.E1

    assign led = 0; //r_led;
    //reg [15:0] r_led;                           assign led = r_led;
    reg [6:0] r_seg;                            assign seg = r_seg;
    reg r_dp;                                   assign dp = r_dp;
    reg [3:0]  r_an;                            assign an = r_an;
    reg [UART_FRAME_SIZE*DBITS-1:0] r_uart_tx;  assign uart_tx = r_uart_tx;
    reg r_uart_tx_trigger;                      assign uart_tx_trigger = r_uart_tx_trigger;
    reg r_uart_rx_clear;                        assign uart_rx_clear = r_uart_rx_clear;
    reg [15:0] r_oled_pixel_data;               assign oled_pixel_data = r_oled_pixel_data | text_pixel_data;
    reg [8*STR_LEN*7-1:0] r_text_lines;         assign text_lines = r_text_lines;
    reg [15:0] r_text_colour;                   assign text_colour = r_text_colour;
    
    always @ (*) begin
        if (enable_mode_master) begin
            //r_led = 0; //master_led;
            r_seg = master_seg;
            r_dp = master_dp;
            r_an = master_an;

            r_uart_tx = master_uart_tx;
            r_uart_tx_trigger = master_uart_tx_trigger;
            r_uart_rx_clear = master_uart_rx_clear;

            r_oled_pixel_data = master_oled_pixel_data;
            r_text_lines = master_text_lines;
            r_text_colour = master_text_colour;
        end else if (enable_mode_slave) begin
            //r_led = 0; //slave_led;
            r_seg = slave_seg;
            r_dp = slave_dp;
            r_an = slave_an;

            r_uart_tx = slave_uart_tx;
            r_uart_tx_trigger = slave_uart_tx_trigger;
            r_uart_rx_clear = slave_uart_rx_clear;

            r_oled_pixel_data = slave_oled_pixel_data;
            r_text_lines = slave_text_lines;
            r_text_colour = slave_text_colour;

        end else if (enable_mode_raycasting) begin
            //r_led = 0; //raycast_led;
            r_seg = raycast_seg;
            r_dp = raycast_dp;
            r_an = raycast_an;

            r_uart_tx = raycast_uart_tx;
            r_uart_tx_trigger = raycast_uart_tx_trigger;
            r_uart_rx_clear = raycast_uart_rx_clear;

            r_oled_pixel_data = raycast_oled_pixel_data;
            r_text_lines = 0;  //raycast_text_lines;
            r_text_colour = 0; //raycast_text_colour;
        end else begin
            //r_led = 0; 
            r_seg = 7'b1111111;
            r_dp = 1;
            r_an = 4'b1111;

            r_uart_tx = 1'b0;
            r_uart_tx_trigger = 1'b0;
            r_uart_rx_clear = 1'b0;

            //r_oled_pixel_data = 16'h0;
            r_oled_pixel_data = image_pixel_data;
            r_text_lines = intro_text_lines; 
            r_text_colour = intro_text_colour;
        end
    end
endmodule
