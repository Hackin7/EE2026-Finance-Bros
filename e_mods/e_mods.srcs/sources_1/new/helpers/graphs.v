module graphs(
    input reset, input clk,
    input btnC, input btnU, input btnL, input btnR, input btnD, input [15:0] sw,
    output [15:0] led, output [6:0] seg, output dp, output [3:0] an,
    input [12:0] oled_pixel_index, output reg [15:0] oled_pixel_data,
    input signed [31:0] x_point1, y_point1, x_point2, y_point2, x_point3, y_point3,
    input signed [31:0] x_point4, y_point4, x_point5, y_point5, x_point6, y_point6,
    input signed [31:0] x_point7, y_point7, x_point8, y_point8, x_point9, y_point9,
    input [11:0] mouse_xpos, input [11:0] mouse_ypos,  mouse_left_click, mouse_right_click

);
   

    wire signed [31:0] slope1, slope2, slope3, slope4, slope5, slope6;
    wire signed [31:0] intercept1, intercept2, intercept3, intercept4, intercept5, intercept6;
    reg [3:0] zoom_level = 1;

    reg [6:0] x;
    reg [5:0] y; 
    
    reg [6:0] cursor_x;
    reg [5:0] cursor_y;
    
    reg [11:0] prev_cursor_x,  prev_cursor_y;
    reg [11:0] delta_x,  delta_y;
    
    reg [6:0]scaled_x;
    reg [5:0]scaled_y;


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
    
    always @(posedge clk) begin
        if (mouse_right_click && zoom_level == 1) begin
            zoom_level <= 2;
            
            prev_cursor_x <= mouse_xpos[11:3];
            prev_cursor_y <= mouse_ypos[11:3];
        end
        else if (mouse_left_click && zoom_level == 2) begin
            zoom_level <= 1;
        end
        
    end
    
   always @(*) begin
         
        if (zoom_level == 1) begin
            
            x <= oled_pixel_index % 96; 
            y <= oled_pixel_index / 96;
        end
        else if (zoom_level == 2 && cursor_x < 48 && cursor_y < 32) begin
           x <= ((oled_pixel_index % 96) / 2); 
           y <= ((oled_pixel_index / 96) / 2); 
        end else if (zoom_level == 2 && cursor_x < 48 && cursor_y >= 32) begin 
             x <= ((oled_pixel_index % 96) / 2); 
             y <= ((oled_pixel_index / 96) / 2) + 32; 
        end else if (zoom_level == 2 && cursor_x >= 48 && cursor_y < 32) begin 
             x <= ((oled_pixel_index % 96) / 2) + 48; 
             y <= ((oled_pixel_index / 96) / 2);
        end else if (zoom_level == 2 && cursor_x >= 48 && cursor_y >= 32) begin 
             x <= ((oled_pixel_index % 96) / 2) + 48; 
             y <= ((oled_pixel_index / 96) / 2) + 32;
       
       end

        
       

        oled_pixel_data <= 16'h0000; 

        // Drawing axes
        if (x == 10) oled_pixel_data <= 16'hFFFF; 
        if (y == 56) oled_pixel_data <= 16'hFFFF; 
        

        // Drawing the first graph in green
        drawLine(x_point1, y_point1, x_point2, y_point2, slope1, intercept1, 16'h07E0); // Green
        drawLine(x_point2, y_point2, x_point3, y_point3, slope2, intercept2, 16'h07E0); 
        highlightPoints(x_point1, y_point1, x_point2, y_point2, x_point3, y_point3, 16'hF800); 
        
        // Drawing the second graph in blue
        drawLine(x_point4, y_point4, x_point5, y_point5, slope3, intercept3, 16'h001F); // Blue
        drawLine(x_point5, y_point5, x_point6, y_point6, slope4, intercept4, 16'h001F); 
        highlightPoints(x_point4, y_point4, x_point5, y_point5, x_point6, y_point6, 16'h07FF); 
        
        // Drawing the third graph in red
        drawLine(x_point7, y_point7, x_point8, y_point8, slope5, intercept5, 16'hF800); //red
        drawLine(x_point8, y_point8, x_point9, y_point9, slope6, intercept6, 16'hF800); 
        highlightPoints(x_point7, y_point7, x_point8, y_point8, x_point9, y_point9, 16'hFA10); 
        
        cursor_x <= mouse_xpos[11:3]; // Scaling 
        cursor_y <= mouse_ypos[11:3];
               
               
 
         
        


        
        if (x == cursor_x && y == cursor_y) begin
            oled_pixel_data <= 16'hFFFF; // White
        end

        end

  
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
