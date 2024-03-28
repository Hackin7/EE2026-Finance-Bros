`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.03.2024 14:20:28
// Design Name: 
// Module Name: image
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


module image(
    // Control
    input reset, input clk,
    // LEDs, Switches, Buttons
    input btnC, btnU, btnL, btnR, btnD, input [15:0] sw, output [15:0] led,
    // 7 Segment Display
    output [6:0] seg, output dp, output [3:0] an,
    // OLED
    inout [7:0] JB
);

    //// OLED Setup ////////////////////////////////////////////////////////
    wire [7:0] Jb;
    assign JB[7:0] = Jb;

    wire clk_6_25mhz;
    clk_counter #(16, 5) clk6p25m (clk, clk_6_25mhz);

    reg [15:0] image_memory [0:7679]; // Adjust size based on image dimensions (96x64 for example)
    reg [15:0] image2_memory [0:7679]; // Memory for the second image
    initial begin
        $readmemh("image_data.mem", image_memory); // Load the first image data
        $readmemh("image2_data.mem", image2_memory); // Load the second image data
    end

    wire [12:0] oled_pixel_index;
    reg [15:0] oled_pixel_data = 16'h0000;
    wire [15:0] pixel_data = oled_pixel_data;
    
    Oled_Display display(
        .clk(clk_6_25mhz), .reset(0),
        .frame_begin(), .sending_pixels(), .sample_pixel(), .pixel_index(oled_pixel_index), .pixel_data(pixel_data),
        .cs(Jb[0]), .sdin(Jb[1]), .sclk(Jb[3]), .d_cn(Jb[4]), .resn(Jb[5]), .vccen(Jb[6]), .pmoden(Jb[7])
    );

    always @ (*) begin
        if (oled_pixel_index < 7680) begin // Assuming 96x64 image
            if (btnC) begin
                // When btnC is pressed, display the second image
                oled_pixel_data = image2_memory[oled_pixel_index];
            end else begin
                // When btnC is not pressed, display the first image
                oled_pixel_data = image_memory[oled_pixel_index];
            end
        end else begin
            oled_pixel_data = 16'hFFFF; // Default or error color, adjust as needed
        end
    end

endmodule