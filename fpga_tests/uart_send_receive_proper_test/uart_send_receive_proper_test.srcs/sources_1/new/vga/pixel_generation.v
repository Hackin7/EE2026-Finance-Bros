`timescale 1ns / 1ps

module pixel_generation(
    input video_on,
    input [9:0] x, y,
    output reg [11:0] rgb, 
    
    input clk_100MHz,
    input rx,               // USB-RS232 Rx
    input btn,              // btnL (read and write FIFO operation)
    output tx,              // USB-RS232 Tx
    output [3:0] an,        // 7 segment display digits
    output [0:6] seg,       // 7 segment display segments
    output [7:0] LED,        // data byte display
    output [15:8] led        // extra tests
    );
    
    
    
    reg [3072-1:0] screen;
    //// UART Section ////////////////////////////////////////////////
    // Connection Signals
    wire rx_full, rx_empty, btn_tick;
    wire [7:0] rec_data, rec_data1;
    wire [31:0] read_all_data_out;
    wire read_tick;
    // Complete UART Core
    uart_top UART_UNIT
        (
            .clk_100MHz(clk_100MHz),
            .read_uart(btn_tick),
            .write_uart(btn_tick),
            .rx(rx),
            .write_data(rec_data1),
            .rx_full(rx_full),
            .rx_empty(rx_empty),
            .read_data(rec_data),
            .tx(tx),
            .read_all_data_out(read_all_data_out),
            .read_tick(read_tick)
        );
    
    
    // Signal Logic    
    assign rec_data1 = rec_data + 1;    // add 1 to ascii value of received data (to transmit)
    
    // Output Logic
    //assign LED = rec_data;              // data byte received displayed on LEDs
    assign an = 4'b1110;                // using only one 7 segment digit 
    assign seg = {~rx_full, 2'b11, ~rx_empty, 3'b111};
    assign led[15] = rec_data == 65;
    assign led[14] = read_all_data_out[31:24] == 65;
    assign led[13] = read_all_data_out[23:16] == 65;
    assign led[12] = read_all_data_out[15:8] == 65;
    assign led[11] = read_all_data_out[7:0] == 65;
    
    assign LED = rec_data;
    
    reg toggle;
    assign led[10] = toggle;
    initial begin
        toggle = 0;
        screen = ~(3072'b0);
    end
    always @(negedge read_tick) begin
        // Toggle LED
        /*if(rec_data == 65) begin
            toggle = ~toggle;
        end*/
        
        // Change Pixel B<y><x>A
        if (read_all_data_out[7:0] == 65 & read_all_data_out[31:24] == 66) begin
            screen[read_all_data_out[15:8] * 48 + read_all_data_out[23:16]] = 1;
            toggle = ~toggle;
        end
        if (read_all_data_out[7:0] == 65 & read_all_data_out[31:24] == 67) begin
            screen[read_all_data_out[15:8] * 48 + read_all_data_out[23:16]] = 0;
            toggle = ~toggle;
        end
    end
    
    ////////////////////////////////////////////////////////////////
    // RGB Color Values
    parameter RED    = 12'h00F;
    parameter GREEN  = 12'h0F0;
    parameter BLUE   = 12'hF00;
    parameter YELLOW = 12'h0FF;     // RED and GREEN
    parameter AQUA   = 12'hFF0;     // GREEN and BLUE
    parameter VIOLET = 12'hF0F;     // RED and BLUE
    parameter WHITE  = 12'hFFF;     // all ON
    parameter BLACK  = 12'h000;     // all OFF
    parameter GRAY   = 12'hAAA;     // some of each color //178
    
    // Pixel Location Status Signals
    wire u_white_on, u_yellow_on, u_aqua_on, u_green_on, u_violet_on, u_red_on, u_blue_on;
    wire l_blue_on, l_black1_on, l_violet_on, l_gray_on, l_aqua_on, l_black2_on, l_white_on;
    
    // Drivers for Status Signals
    // Upper Sections
    assign u_white_on  = ((x >= 0)   && (x < 91)   &&  (y >= 0) && (y < 412));
    assign u_yellow_on = ((x >= 91)  && (x < 182)  &&  (y >= 0) && (y < 412));
    assign u_aqua_on   = ((x >= 182) && (x < 273)  &&  (y >= 0) && (y < 412));
    assign u_green_on  = ((x >= 273) && (x < 364)  &&  (y >= 0) && (y < 412));
    assign u_violet_on = ((x >= 364) && (x < 455)  &&  (y >= 0) && (y < 412));
    assign u_red_on    = ((x >= 455) && (x < 546)  &&  (y >= 0) && (y < 412));
    assign u_blue_on   = ((x >= 546) && (x < 640)  &&  (y >= 0) && (y < 412));
    // Lower Sections
    assign l_blue_on   = ((x >= 0)   && (x < 91)   &&  (y >= 412) && (y < 480));
    assign l_black1_on = ((x >= 91)  && (x < 182)  &&  (y >= 412) && (y < 480));
    assign l_violet_on = ((x >= 182) && (x < 273)  &&  (y >= 412) && (y < 480));
    assign l_gray_on   = ((x >= 273) && (x < 364)  &&  (y >= 412) && (y < 480));
    assign l_aqua_on   = ((x >= 364) && (x < 455)  &&  (y >= 412) && (y < 480));
    assign l_black2_on = ((x >= 455) && (x < 546)  &&  (y >= 412) && (y < 480));
    assign l_white_on  = ((x >= 546) && (x < 640)  &&  (y >= 412) && (y < 480));
    
    wire [12:0] mapping;
    screen_mapper mapper(x, y, mapping);
    
    // Set RGB output value based on status signals
    always @*
        if(~video_on)
            rgb = BLACK;
        else
            //if (screen[(x/10) * 48 + (y/10)] == 0) //not support
            if (screen[mapping] == 0) 
            //if (screen[(x) * 48 + (y)] == 0) //not support
                rgb = BLACK;
            else if(u_white_on)
                rgb = WHITE;
            else
                rgb = WHITE;
            //rgb = WHITE;
            /*
            if ((x >= 0 & x <= 255 & y >= 0 & y <= 255 & screen[x * 255 + y] == 0))
                rgb = BLACK;
            else if ((x >= 0 & x <= 255 & y >= 0 & y <= 255 & screen[x * 255 + y] == 1))
                rgb = WHITE;
            else if(u_white_on)
                rgb = WHITE;
            else if(u_yellow_on)
                rgb = YELLOW;
            else if(u_aqua_on)
                rgb = AQUA;
            else if(u_green_on)
                rgb = GREEN;
            else if(u_violet_on)
                rgb = VIOLET;
            else if(u_red_on)
                rgb = RED;
            else if(u_blue_on)
                rgb = BLUE;
            else if(l_blue_on)
                rgb = BLUE;
            else if(l_black1_on)
                rgb = BLACK;
            else if(l_violet_on)
                rgb = VIOLET;
            else if(l_gray_on)
                rgb = GRAY;
            else if(l_aqua_on)
                rgb = AQUA;
            else if(l_black2_on)
                rgb = BLACK;
            else if(l_white_on)
                rgb = WHITE;
            */
       
endmodule