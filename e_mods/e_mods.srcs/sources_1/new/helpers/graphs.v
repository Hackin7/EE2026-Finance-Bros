module graphs(
    input reset, input clk,
    input btnC, input btnU, input btnL, input btnR, input btnD, input [2:0] stock_id,
    //input [15:0] sw, output [15:0] led, output [6:0] seg, output dp, output [3:0] an,
    input [12:0] oled_pixel_index, output reg [15:0] oled_pixel_data,
    input signed [31:0] x_point1, y_point1, x_point2, y_point2, x_point3, y_point3,
    input signed [31:0] x_point4, y_point4, x_point5, y_point5, x_point6, y_point6,
    input signed [31:0] x_point7, y_point7, x_point8, y_point8, x_point9, y_point9,
    input [11:0] mouse_xpos, input [11:0] mouse_ypos, mouse_left_click, mouse_right_click
);
    constants constant();

    wire signed [31:0] slope1, slope2, slope3, slope4, slope5, slope6;
    wire signed [31:0] intercept1, intercept2, intercept3, intercept4, intercept5, intercept6;
    reg [3:0] zoom_level = 1;
 
    reg [6:0] x;
    reg [5:0] y; 
    
    reg [6:0] cursor_x;
    reg [5:0] cursor_y;
    
    reg prev_btnC=0, prev_btnU=0, prev_btnL=0, prev_btnR=0, prev_btnD=0;
        
//    reg debounce = 0;
//    reg [31:0] debounce_timer = 0;
//    parameter DEBOUNCE_TIME = 30_000_000; // 100ms


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
  
   always @(posedge clk) begin
        if (mouse_right_click && zoom_level == 1) begin
            zoom_level <= 2;
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

        oled_pixel_data <= 16'h0000; 

        // Drawing axes
        if (x == 10) oled_pixel_data <= 16'hFFFF; // White
        if (y == 56) oled_pixel_data <= 16'hFFFF; // White
        
// Drawing the first graph in green
        drawLine(
            stock_id == 0 ? x_point1 : (stock_id == 1 ? x_point4 : x_point7),
            stock_id == 0 ? y_point1 : (stock_id == 1 ? y_point4 : y_point7), 
            stock_id == 0 ? x_point2 : (stock_id == 1 ? x_point5 : x_point8), 
            stock_id == 0 ? y_point2 : (stock_id == 1 ? y_point5 : y_point8), 
            stock_id == 0 ? slope1 : (stock_id == 1 ? slope3 : slope5), 
            stock_id == 0 ? intercept1 : (stock_id == 1 ? intercept3 : intercept5), 
            stock_id == 0 ? constant.GREEN : (stock_id == 1 ? constant.BLUE : constant.RED)
        );
        
        drawLine(
            stock_id == 0 ? x_point2 : (stock_id == 1 ? x_point5 : x_point8),
            stock_id == 0 ? y_point2 : (stock_id == 1 ? y_point5 : y_point8), 
            stock_id == 0 ? x_point3 : (stock_id == 1 ? x_point6 : x_point9), 
            stock_id == 0 ? y_point3 : (stock_id == 1 ? y_point6 : y_point9), 
            stock_id == 0 ? slope2 : (stock_id == 1 ? slope4 : slope6), 
            stock_id == 0 ? intercept2 : (stock_id == 1 ? intercept4 : intercept6), 
            stock_id == 0 ? constant.GREEN : (stock_id == 1 ? constant.BLUE : constant.RED)
        );
        
        highlightPoints(
            stock_id == 0 ? x_point1 : (stock_id == 1 ? x_point4 : x_point7), 
            stock_id == 0 ? y_point1 : (stock_id == 1 ? y_point4 : y_point7), 
            stock_id == 0 ? x_point2 : (stock_id == 1 ? x_point5 : x_point8), 
            stock_id == 0 ? y_point2 : (stock_id == 1 ? y_point5 : y_point8), 
            stock_id == 0 ? x_point3 : (stock_id == 1 ? x_point6 : x_point9), 
            stock_id == 0 ? y_point3 : (stock_id == 1 ? y_point6 : y_point9), 
            constant.CYAN
            );

        
         cursor_x <= mouse_xpos[11:3]; // Scaling 
         cursor_y <= mouse_ypos[11:3]; 
              
        
        
        if (x == cursor_x && y == cursor_y) begin
            oled_pixel_data <= 16'hFFFF; // White color for cursor
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


//        task button_control();
//            begin
//                if (debounce) begin
//                    debounce_timer <= debounce_timer + 1;
//                    if (debounce_timer > DEBOUNCE_TIME-1) begin
//                        debounce <= 0;
//                        debounce_timer <= 0;
//                    end
//                end else begin
//                    /*if (prev_btnU == 1 && btnU == 0) begin
//                        key_in_value <= key_in_value + 1;
//                        debounce <= 1;
//                    end*/
//                    if (prev_btnL == 1 && btnL == 0) begin
//                        stock_id = stock_id == 0 ? 2 : stock_id - 1;
//                        debounce <= 1;
//                    end
//                    if (prev_btnR == 1 && btnR == 0) begin
//                        stock_id = stock_id == 2 ? 0 : stock_id + 1;
//                        debounce <= 1;
//                    end
//                    prev_btnC <= btnC; prev_btnU <= btnU; prev_btnL <= btnL; 
//                    prev_btnR <= btnR; prev_btnD <= btnD;
//                end
//            end
//            endtask

endmodule