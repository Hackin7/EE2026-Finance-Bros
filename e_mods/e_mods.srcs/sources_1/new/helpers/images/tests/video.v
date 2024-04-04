`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.03.2024 22:35:27
// Design Name: 
// Module Name: video
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


module video(
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

reg [15:0] image_memory [0:23039]; // Adjust size based on the total number of lines in the mem file

initial begin
    $readmemh("video_data.mem", image_memory); // Load the video data
end

wire [12:0] oled_pixel_index;
reg [15:0] oled_pixel_data = 16'h0000;
wire [15:0] pixel_data = oled_pixel_data;

Oled_Display display(
    .clk(clk_6_25mhz), .reset(0),
    .frame_begin(), .sending_pixels(), .sample_pixel(), .pixel_index(oled_pixel_index), .pixel_data(pixel_data),
    .cs(Jb[0]), .sdin(Jb[1]), .sclk(Jb[3]), .d_cn(Jb[4]), .resn(Jb[5]), .vccen(Jb[6]), .pmoden(Jb[7])
);

reg [8:0] frame_counter = 0;
reg [15:0] frame_start_address = 0;

always @(posedge clk_6_25mhz) begin
    if (frame_counter == 0) begin
        frame_start_address <= 0;
    end else if (frame_counter == 24) begin
        frame_counter <= 0;
        frame_start_address <= frame_start_address + 64;
        if (frame_start_address >= 23040 - 64) begin
            frame_start_address <= 0;
        end
    end else begin
        frame_counter <= frame_counter + 1;
    end
end

always @ (*) begin
    if (oled_pixel_index < 6144) begin // Assuming 96x64 image
        oled_pixel_data = image_memory[frame_start_address + oled_pixel_index];
    end else begin
        oled_pixel_data = 16'hFFFF; // Default or error color, adjust as needed
    end
end

endmodule