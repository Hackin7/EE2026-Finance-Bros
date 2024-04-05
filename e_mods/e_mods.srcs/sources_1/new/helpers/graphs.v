module graphs(
    input reset, input clk,
    input btnC, input btnU, input btnL, input btnR, input btnD, input [2:0] stock_id,
    //input [15:0] sw, output [15:0] led, output [6:0] seg, output dp, output [3:0] an,
    input [12:0] oled_pixel_index, output reg [15:0] oled_pixel_data,
    input signed [31:0] x_point1, y_point1, x_point2, y_point2, x_point3, y_point3,
    input signed [31:0] y_point4, y_point5, y_point6, y_point7, y_point8, y_point9,
    input [11:0] mouse_xpos, input [11:0] mouse_ypos,
    input mouse_left_click, mouse_right_click
);
    constants constant();
   
    wire signed [31:0] slope1, slope2, intercept1, intercept2;
 
    reg [6:0] x;
    reg [5:0] y; 
    
    reg [6:0] cursor_x;
    reg [5:0] cursor_y;
    
    reg prev_btnC=0, prev_btnU=0, prev_btnL=0, prev_btnR=0, prev_btnD=0;
        
//    reg debounce = 0;
//    reg [31:0] debounce_timer = 0;
//    parameter DEBOUNCE_TIME = 30_000_000; // 100ms

    reg [3:0] zoom_level = 1;

    parameter scale = 128;
  
    always @(*) begin
        oled_pixel_data <= 16'h0000;
        if (zoom_level == 1) begin
            x <= oled_pixel_index % 96; 
            y <= oled_pixel_index / 96;
        end
        else if (zoom_level == 2 && cursor_x < 24 && cursor_y < 16) begin
           x <= ((oled_pixel_index % 96) / 2); 
           y <= ((oled_pixel_index / 96) / 2); 
        end else if (zoom_level == 2 && cursor_x < 24 && cursor_y >= 16 && cursor_y < 48) begin 
           x <= ((oled_pixel_index % 96) / 2); 
           y <= ((oled_pixel_index / 96) / 2) + 16; 
        end else if (zoom_level == 2 && cursor_x < 24 && cursor_y >= 48) begin  
           x <= ((oled_pixel_index % 96) / 2); 
           y <= ((oled_pixel_index / 96) / 2) + 32; 
        end else if (zoom_level == 2 && cursor_x >= 24 && cursor_x < 72 && cursor_y < 16) begin  
           x <= ((oled_pixel_index % 96) / 2) + 24; 
           y <= ((oled_pixel_index / 96) / 2);
        end else if (zoom_level == 2 && cursor_x >= 72 && cursor_y < 16) begin 
           x <= ((oled_pixel_index % 96) / 2) + 48; 
           y <= ((oled_pixel_index / 96) / 2);
        end else if (zoom_level == 2 && cursor_x >= 24 && cursor_x < 72 && cursor_y >= 16 && cursor_y < 48) begin 
           x <= ((oled_pixel_index % 96) / 2) + 24; 
           y <= ((oled_pixel_index / 96) / 2) + 16;
        end else if (zoom_level == 2 && cursor_x >= 24 && cursor_x < 72 && cursor_y >= 48) begin 
           x <= ((oled_pixel_index % 96) / 2) + 24; 
           y <= ((oled_pixel_index / 96) / 2) + 32; 
        end else if (zoom_level == 2 && cursor_x >= 72 && cursor_y >= 16 && cursor_y < 48) begin   
           x <= ((oled_pixel_index % 96) / 2) + 48; 
           y <= ((oled_pixel_index / 96) / 2) + 16;             
        end else if (zoom_level == 2 && cursor_x >= 72 && cursor_y >= 48) begin 
           x <= ((oled_pixel_index % 96) / 2) + 48; 
           y <= ((oled_pixel_index / 96) / 2) + 32;
        end
      
        drawLine(
            x_point1,
            stock_id == 0 ? y_point1 : (stock_id == 1 ? y_point4 : y_point7), 
            x_point2, 
            stock_id == 0 ? y_point2 : (stock_id == 1 ? y_point5 : y_point8), 
            slope1, intercept1, 
            stock_id == 0 ? constant.GREEN : (stock_id == 1 ? constant.BLUE : constant.RED)
        );
        
        drawLine(
            x_point2,
            stock_id == 0 ? y_point2 : (stock_id == 1 ? y_point5 : y_point8), 
            x_point3, 
            stock_id == 0 ? y_point3 : (stock_id == 1 ? y_point6 : y_point9), 
            slope2, intercept2, 
            stock_id == 0 ? constant.GREEN : (stock_id == 1 ? constant.BLUE : constant.RED)
        );
        
        highlightPoints(
            x_point1, 
            stock_id == 0 ? y_point1 : (stock_id == 1 ? y_point4 : y_point7), 
            x_point2, 
            stock_id == 0 ? y_point2 : (stock_id == 1 ? y_point5 : y_point8), 
            x_point3, 
            stock_id == 0 ? y_point3 : (stock_id == 1 ? y_point6 : y_point9), 
            constant.CYAN
            );
        // Drawing the second graph in blue
        //drawLine(x_point4, y_point4, x_point5, y_point5, slope3, intercept3, 16'h001F); // Blue
        //drawLine(x_point5, y_point5, x_point6, y_point6, slope4, intercept4, 16'h001F); 
        //highlightPoints(x_point4, y_point4, x_point5, y_point5, x_point6, y_point6, 16'h07FF); 
        
        
        // Drawing the third graph in red
        //drawLine(x_point7, y_point7, x_point8, y_point8, slope5, intercept5, 16'hF800); //red
        //drawLine(x_point8, y_point8, x_point9, y_point9, slope6, intercept6, 16'hF800); 
        //highlightPoints(x_point7, y_point7, x_point8, y_point8, x_point9, y_point9, 16'hFA10); 
        
         cursor_x <= mouse_xpos[11:3]; // Scaling 
         cursor_y <= mouse_ypos[11:3]; 
        
        if (x == cursor_x && y == cursor_y) begin
            oled_pixel_data <= 16'hFFFF; // White color for cursor
        end
    end
         
    assign slope1 = stock_id == 0 ? ((y_point2 - y_point1) * scale) / (x_point2 - x_point1) : (
                    stock_id == 1 ? ((y_point5 - y_point4) * scale) / (x_point2 - x_point1) : //was slope3
                                    ((y_point8 - y_point7) * scale) / (x_point2 - x_point1)); //was slope5
    assign slope2 = stock_id == 0 ? ((y_point3 - y_point2) * scale) / (x_point3 - x_point2) : (
                    stock_id == 1 ? ((y_point6 - y_point5) * scale) / (x_point3 - x_point2) : //was slope4
                                    ((y_point9 - y_point8) * scale) / (x_point3 - x_point2)); //was slope6
    assign intercept1 = stock_id == 0 ? (y_point1 * scale - (slope1 * x_point1)) : (
                        stock_id == 1 ? (y_point4 * scale - (slope1 * x_point1)) : //was intercept3
                                        (y_point7 * scale - (slope1 * x_point1))); //was intercept5
    assign intercept2 = stock_id == 0 ? (y_point2 * scale - (slope2 * x_point2)) : (
                        stock_id == 1 ? (y_point5 * scale - (slope2 * x_point2)) : //was intercept4
                                        (y_point8 * scale - (slope2 * x_point2))); //was intercept6
                                        
    always @(posedge clk) begin
        if (mouse_right_click) begin
            zoom_level <= zoom_level == 3 ? zoom_level : zoom_level + 1;
        end else if (mouse_left_click) begin
            zoom_level <= zoom_level == 1 ? zoom_level : zoom_level - 1;
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

