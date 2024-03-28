`timescale 1ns / 1ps

module top(
    input clk_100MHz,       // from Basys 3
    input reset,            // btnC on Basys 3
    output hsync,           // to VGA connector
    output vsync,           // to VGA connector
    output [11:0] rgb,       // to DAC, 3 RGB bits to VGA connector
    
    
    input rx,               // USB-RS232 Rx
    input btn,              // btnL (read and write FIFO operation)
    output tx,              // USB-RS232 Tx
    output [3:0] an,        // 7 segment display digits
    output [0:6] seg,       // 7 segment display segments
    output [7:0] LED,        // data byte display
    output [15:8] led        // extra tests
    );
    
    
    /////////////////////////////////////////////////////////////////////////////
    wire w_video_on, w_p_tick;
    wire [9:0] w_x, w_y;
    reg [11:0] rgb_reg;
    wire [11:0] rgb_next;
    
    vga_controller vc(.clk_100MHz(clk_100MHz), .reset(reset), .video_on(w_video_on), 
                      .hsync(hsync), .vsync(vsync), .p_tick(w_p_tick), .x(w_x), .y(w_y));
    pixel_generation pg(
        .video_on(w_video_on), .x(w_x), .y(w_y), .rgb(rgb_next), 
        .clk_100MHz(clk_100MHz), .rx(rx), .btn(btn), .tx(tx), .an(an), .LED(LED), .led(led)
    );
    
    // Buffer RGB
    always @(posedge clk_100MHz)
        if(w_p_tick)
            rgb_reg <= rgb_next;
            
    assign rgb = rgb_reg;
    
    assign led[9] = 1;
    
    
endmodule