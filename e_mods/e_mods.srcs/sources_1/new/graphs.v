module graphs(
    input reset, input clk,
    input btnC, btnU, btnL, btnR, btnD, input [15:0] sw, output [15:0] led,
    output [6:0] seg, output dp, output [3:0] an,
    inout [7:0] JB
);

    wire [7:0] Jb;
    assign JB[7:0] = Jb;

    wire clk_6_25mhz;
    clk_counter #(16, 5) clk6p25m (clk, clk_6_25mhz);

    reg [15:0] oled_pixel_data = 16'h0000;
    wire [12:0] oled_pixel_index;
    wire [15:0] pixel_data = oled_pixel_data;
    Oled_Display display(
        .clk(clk_6_25mhz), .reset(0), 
        .frame_begin(), .sending_pixels(), .sample_pixel(), .pixel_index(oled_pixel_index), .pixel_data(pixel_data), 
        .cs(Jb[0]), .sdin(Jb[1]), .sclk(Jb[3]), .d_cn(Jb[4]), .resn(Jb[5]), .vccen(Jb[6]), .pmoden(Jb[7])
    );

    reg [6:0] x;
    reg [5:0] y; 

    parameter x_point1 = 20; 
    parameter y_point1 = 40; 
    
    parameter x_point2 = 30;
    parameter y_point2 = 30; 

    parameter x_point3 = 60; 
    parameter y_point3 = 50; 
    
    wire signed [31:0] slope1, slope2;
    wire signed [31:0] intercept1, intercept2;

    // Scaling factor for fixed-point
    parameter scale = 100;

 
    assign slope1 = ((y_point2 - y_point1) * scale) / (x_point2 - x_point1);
    assign intercept1 = y_point1 * scale - (slope1 * x_point1);

    assign slope2 = ((y_point3 - y_point2) * scale) / (x_point3 - x_point2);
    assign intercept2 = y_point2 * scale - (slope2 * x_point2);

    reg [15:0] calc_y1, calc_y2;

    always @(posedge clk) begin
        x <= oled_pixel_index % 96; 
        y <= oled_pixel_index / 96; 

        oled_pixel_data <= 16'h0000; 

        // Drawing axes
        if (x == 12) oled_pixel_data <= 16'hFFFF; // White
        if (y == 56) oled_pixel_data <= 16'hFFFF; 

       
        if (x >= x_point1 && x <= x_point2) begin
            calc_y1 = ((slope1 * x) + intercept1) / scale;
            if (y == calc_y1) oled_pixel_data <= 16'h07E0; // Green
        end

        // Drawing the second line with adjusted calculations for fixed-point
        if (x >= x_point2 && x <= x_point3) begin
            calc_y2 = ((slope2 * x) + intercept2) / scale;
            if (y == calc_y2) oled_pixel_data <= 16'h07E0; 
        end

      
        if ((x == x_point1 && y == y_point1) || (x == x_point2 && y == y_point2) || (x == x_point3 && y == y_point3)) begin
            oled_pixel_data <= 16'hF800; // Red 
        end
    end
endmodule
