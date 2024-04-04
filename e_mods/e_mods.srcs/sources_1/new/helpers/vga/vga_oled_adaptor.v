`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.04.2024 19:55:44
// Design Name: 
// Module Name: vga_oled_adaptor
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


module vga_oled_adaptor(
    input clk,
    input reset,
    inout [7:0] JB,
    output [12:0] pixel_index,
    input [15:0] pixel_data,
    input separate_vga,
    input [15:0] pixel_data2,
    output hsync,
    output vsync,
    output [11:0] rgb
);

// OLED display parameters
wire [7:0] oled_xpos;
wire [7:0] oled_ypos;
wire frame_begin, sending_pixels, sample_pixel;

// VGA display parameters
wire w_video_on;
wire [10:0] w_x, w_y;
reg [11:0] rgb_reg;

// Buffer to store OLED display data
reg [15:0] oled_buffer [0:6143]; // 96 x 64 = 6144 pixels
reg [12:0] buffer_index;

// Generate 6.25 MHz clock for OLED display
wire clk_6_25mhz;
clk_counter #(16, 5) clk6p25m (clk, clk_6_25mhz);

// Instantiate the OLED display module
Oled_Display display(
    .clk(clk_6_25mhz), .reset(reset),
    .frame_begin(frame_begin), .sending_pixels(sending_pixels), .sample_pixel(sample_pixel),
    .pixel_index(pixel_index), .pixel_data(pixel_data),
    .cs(JB[0]), .sdin(JB[1]), .sclk(JB[3]), .d_cn(JB[4]), .resn(JB[5]), .vccen(JB[6]), .pmoden(JB[7])
);

// Instantiate the VGA controller module
vga_controller vc(
    .clk(clk),
    .reset(reset),
    .video_on(w_video_on),
    .hsync(hsync),
    .vsync(vsync),
    .p_tick(),
    .x(w_x),
    .y(w_y)
);

// Calculate OLED pixel coordinates
assign oled_xpos = pixel_index % 96;
assign oled_ypos = pixel_index / 96;

// Store OLED display data in the buffer
always @(posedge clk_6_25mhz) begin
    if (sending_pixels) begin
        oled_buffer[pixel_index] <= separate_vga ? pixel_data2 : pixel_data;
    end
end

// Read from the buffer at VGA clock speed
always @(posedge clk) begin
    buffer_index <= (w_y / 9) * 96 + (w_x / 8);
end

// Convert OLED pixel color to VGA pixel color
wire [15:0] vga_pixel_data = oled_buffer[buffer_index];
wire [3:0] vga_red = vga_pixel_data[15:12];
wire [3:0] vga_green = vga_pixel_data[10:7];
wire [3:0] vga_blue = vga_pixel_data[4:1];
wire [11:0] vga_pixel_color = {vga_red, vga_green, vga_blue};

// Set RGB output value based on VGA pixel coordinates and color
always @(posedge clk) begin
    if (~w_video_on) begin
        rgb_reg <= 12'h000; // Black color when video is off
    end else begin
        rgb_reg <= vga_pixel_color;
    end
end

assign rgb = rgb_reg;

endmodule