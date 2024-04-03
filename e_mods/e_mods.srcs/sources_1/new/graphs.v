module graphs(
    input reset, input clk,
    input btnC, btnU, btnL, btnR, btnD, input [15:0] sw, output reg [15:0] led,
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

    // First graph points
    reg signed [31:0] x_point1 = 20; 
    reg signed [31:0] y_point1 = 40; 
    reg signed [31:0]  x_point2 = 30;
    reg signed [31:0]  y_point2 = 30; 
    reg signed [31:0]  x_point3 = 60; 
    reg signed [31:0]  y_point3 = 50; 
    
    // Second graph points
    reg signed [31:0]  x_point4 = 15; 
    reg signed [31:0]  y_point4 = 20; 
    reg signed [31:0]  x_point5 = 45;
    reg signed [31:0]  y_point5 = 35; 
    reg signed [31:0]  x_point6 = 75; 
    reg signed [31:0]  y_point6 = 25; 

    // Third graph points
    reg signed [31:0] x_point7 = 14; 
    reg signed [31:0] y_point7 = 50; 
    reg signed [31:0]  x_point8 = 40;
    reg signed [31:0]  y_point8 = 20; 
    reg signed [31:0]  x_point9 = 80; 
    reg signed [31:0]  y_point9 = 40;

    wire signed [31:0] slope1, slope2, slope3, slope4, slope5, slope6;
    wire signed [31:0] intercept1, intercept2, intercept3, intercept4, intercept5, intercept6;

    parameter scale = 128;

    // First graph slopes and intercepts
    assign slope1 = ((y_point2 - y_point1) * scale) / (x_point2 - x_point1);
    assign intercept1 = y_point1 * scale - (slope1 * x_point1);
    assign slope2 = ((y_point3 - y_point2) * scale) / (x_point3 - x_point2);
    assign intercept2 = y_point2 * scale - (slope2 * x_point2);

    // Second graph slopes and intercepts
    assign slope3 = ((y_point5 - y_point4) * scale) / (x_point5 - x_point4);
    assign intercept3 = y_point4 * scale - (slope3 * x_point4);
    assign slope4 = ((y_point6 - y_point5) * scale) / (x_point6 - x_point5);
    assign intercept4 = y_point5 * scale - (slope4 * x_point5);

    // Third graph slopes and intercepts
    assign slope5 = ((y_point8 - y_point7) * scale) / (x_point8 - x_point7);
    assign intercept5 = y_point7 * scale - (slope5 * x_point7);
    assign slope6 = ((y_point9 - y_point8) * scale) / (x_point9 - x_point8);
    assign intercept6 = y_point8 * scale - (slope6 * x_point8);

    reg [15:0] calc_y1, calc_y2, calc_y3, calc_y4, calc_y5, calc_y6;
    
     always @(*) begin
           if (sw == 0) begin
               led = slope1;
           end else if (sw == 1) begin
               led = intercept1;
           end else if (sw == 2) begin
               led = (y_point2 - y_point1);
           end else if (sw == 3) begin
               led = (x_point2 - x_point1);
           end else if (sw == 4) begin
               led = (y_point2 - y_point1) * scale;
           end else if (sw == 5) begin
               led = (y_point2 - y_point1)/(x_point2 - x_point1);
           end else if (sw == 6) begin
           end else if (sw == 7) begin
           end else if (sw == 8) begin
           end else if (sw == 9) begin
           end else if (sw == 10) begin
           end else if (sw == 11) begin
           end 
       end


    always @(*) begin
        x <= oled_pixel_index % 96; 
        y <= oled_pixel_index / 96; 

        oled_pixel_data <= 16'h0000; 

        // Drawing axes
        if (x == 10) oled_pixel_data <= 16'hFFFF; // White
        if (y == 56) oled_pixel_data <= 16'hFFFF; // White

        // Drawing the first graph in green
        drawLine(x_point1, y_point1, x_point2, y_point2, slope1, intercept1, 16'h07E0); // Green
        drawLine(x_point2, y_point2, x_point3, y_point3, slope2, intercept2, 16'h07E0); 
        highlightPoints(x_point1, y_point1, x_point2, y_point2, x_point3, y_point3, 16'hF800); // Red points
        
        // Drawing the second graph in blue
        drawLine(x_point4, y_point4, x_point5, y_point5, slope3, intercept3, 16'h001F); // Blue
        drawLine(x_point5, y_point5, x_point6, y_point6, slope4, intercept4, 16'h001F); 
        highlightPoints(x_point4, y_point4, x_point5, y_point5, x_point6, y_point6, 16'h07FF); // Light blue points
        
        // Drawing the third graph in red
        drawLine(x_point7, y_point7, x_point8, y_point8, slope5, intercept5, 16'hF800); // Red
        drawLine(x_point8, y_point8, x_point9, y_point9, slope6, intercept6, 16'hF800); 
        highlightPoints(x_point7, y_point7, x_point8, y_point8, x_point9, y_point9, 16'hFA10); // Red points
    end

    // Function to draw lines between points
    task drawLine;
        input [31:0] x_start, y_start, x_end, y_end;
        input signed [31:0] slope, intercept;
        input [15:0] color;
        begin
            if (x >= x_start && x <= x_end) begin
                if (y == (((slope * x) + intercept)/scale)) oled_pixel_data <= color;
            end
        end
    endtask

    // Function to highlight points
    task highlightPoints;
        input [6:0] x1, y1, x2, y2, x3, y3;
        input [15:0] pointColor;
        begin
            if ((x == x1 && y == y1) || (x == x2 && y == y2) || (x == x3 && y == y3)) begin
                oled_pixel_data <= pointColor;
            end
        end
    endtask
endmodule
