`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//  STUDENT A NAME: 
//  STUDENT B NAME:
//  STUDENT C NAME: 
//  STUDENT D NAME:  
//
//////////////////////////////////////////////////////////////////////////////////


module top (
    // Control
    input clk,
    // LEDs, Switches, Buttons
    input btnC, btnU, btnL, btnR, btnD, input [15:0] sw, output [15:0] led,
    // 7 Segment Display
    output [6:0] seg, output dp, output [3:0] an,
    // UART
    input rx, output tx,
    // OLED PMOD
    inout [7:0] JB,
    inout mouse_ps2_clk, mouse_ps2_data
);
    
    //// Setup ///////////////////////////////////////////////////////////////////////////////////////////////////////
    //// Clocks /////////////////////////////////////////////
    wire clk_6_25mhz;
    clk_counter #(8, 8, 32) clk6p25m (clk, clk_6_25mhz);

    wire clk_100hz;
    clk_counter #(2_000_000, 2_000_000, 32) clk100 (clk, clk_100hz);
    
    wire clk_10hz;
    clk_counter #(10_000_000, 10_000_000, 32) clk10 (clk, clk_10hz);
    //// 3.A OLED Setup //////////////////////////////////////
    // Inputs
    wire [7:0] Jx;
    assign JB[7:0] = Jx;
    // Outputs
    wire [12:0] oled_pixel_index;
    wire [15:0] oled_pixel_data;
    wire [7:0] oled_xpos;
    wire [7:0] oled_ypos;
    // Module
    Oled_Display display(
        .clk(clk_6_25mhz), .reset(0), 
        .frame_begin(), .sending_pixels(), .sample_pixel(), .pixel_index(oled_pixel_index), .pixel_data(oled_pixel_data), 
        .cs(Jx[0]), .sdin(Jx[1]), .sclk(Jx[3]), .d_cn(Jx[4]), .resn(Jx[5]), .vccen(Jx[6]), .pmoden(Jx[7])); //to SPI
    
    //// 3.B Mouse Setup /////////////////////////////////////
    /*wire mouse_reset; // cannot hardcode to 1 for some reason
    wire [11:0] mouse_xpos;
    wire [11:0] mouse_ypos;
    wire [3:0] mouse_zpos;
    wire mouse_left_click;
    wire mouse_middle_click;
    wire mouse_right_click;
    wire mouse_new_event;
    MouseCtl mouse(
        .clk(clk), .rst(mouse_reset), .value(11'b0), .setx(0), .sety(0), .setmax_x(96), .setmax_y(64),
        .xpos(mouse_xpos), .ypos(mouse_ypos), .zpos(mouse_zpos), 
        .left(mouse_left_click), .middle(mouse_middle_click), .right(mouse_right_click), .new_event(mouse_new_event),
        .ps2_clk(mouse_ps2_clk), .ps2_data(mouse_ps2_data)
    );*/
    
    /* Money animating -------------------------------------------*/
    reg [15:0] money_bill_img[255:0];
    initial begin
            $readmemh("bill.mem", money_bill_img);
    end
    
    wire clk_money;
    clk_counter #(10_000_000, 10_000_000, 32) clkmoney (clk, clk_money);
    reg [7:0] money_y = 0;
    
    always @ (posedge clk_money) begin
        money_y <= money_y == 64 ? -50 : money_y + 1;
    end
    
    task display_bill(input [7:0] x, input[7:0] y);
    begin
        if (
            (x <= oled_xpos && oled_xpos < x+16 && y <= oled_ypos && oled_ypos < y + 16)
        ) begin
            if (!btnC && money_bill_img[(oled_ypos - y) * 16 + (oled_xpos-x)] != ~15'h0) begin
                pixel_data = money_bill_img[(oled_ypos - y) * 16 + (oled_xpos-x)];
            end
        end
    end
    endtask
    /// Raycasting ////////////////////////////////////////////////
    
    
    constants constant();
    parameter BW_INT=8;
    parameter BW_DEC=8;
    parameter BW = BW_INT + BW_DEC;
    parameter FOV = 60;
    
    
    
    reg signed [15:0] sin_array [65535:0]; // 2nd index is size of array, not bit
    reg signed [15:0] cos_array [65535:0];
    //reg [15:0] sqrt_array [65535:0];
    initial begin
        //$display("Loading rom.");
        $readmemh("sin.mem", sin_array);
        $readmemh("cos.mem", cos_array);
        //$readmemh("sqrt.mem", sqrt_array);
    end
    
    
    function [BW:0] min(input [BW:0] a, input [BW:0] b);
    begin
        min = a < b ? a : b;
    end
    endfunction
    
    function [BW-1:0] abs_cos(input [BW-1:0] a); 
    begin
        if (cos_array[a] < 0) begin
            abs_cos = -cos_array[a];
        end else begin
            abs_cos = cos_array[a];
        end
    end
    endfunction 
    /* -----------------------------------------------------*/
    
    parameter world_width = 8;
    reg [63:0] world_map = 
    {
        8'b11111111,
        8'b10000001,
        8'b10000001,
        8'b10000001,
        8'b10000001,
        8'b10000001,
        8'b10000001,
        8'b11111111
    };
    
    reg [12:0] prev_pixel_index = 0;
    reg [BW-1:0] distance=9;
    
    // Player Variables
    reg [BW-1+8:0] x_precise = (2 << BW_DEC) << 8;
    reg [BW-1+8:0] y_precise = (2 << BW_DEC) << 8;
    wire [BW-1:0] x = x_precise[BW-1+8:8];
    wire [BW-1:0] y = y_precise[BW-1+8:8];
    reg [BW-1+1:0] angle = 90 << BW_DEC; // add 1 bit to range 360
    wire [BW-1:0] angle_processed = (
        angle + (48 << BW_DEC) > (360 << BW_DEC) ? (angle+(48 << BW_DEC)) -  (360 << BW_DEC):
        angle + (48 << BW_DEC) > (180 << BW_DEC) ? (360 << BW_DEC) - (angle+(48 << BW_DEC)) :
        (angle+(48 << BW_DEC))
    );
    
    // Calculations
    reg [7:0] raycast_step = 0;
    //wire [BW-1:0] raycast_angle = angle + oled_xpos;
    wire signed [BW-1+1:0] raycast_angle = (
        angle + (oled_xpos << BW_DEC) > (360 << BW_DEC) 
            ? angle + (oled_xpos << BW_DEC) - (360 << BW_DEC)
        : angle + (oled_xpos << BW_DEC) > (180 << BW_DEC) 
            ? (360 << BW_DEC) - (angle + (oled_xpos << BW_DEC)) 
        : angle + (oled_xpos << BW_DEC)
    );
    
    wire signed [BW-1:0] dx = cos_array[raycast_angle];
    wire signed [BW-1:0] dy = sin_array[raycast_angle];
    reg signed [BW-1:0] raycast_x = 0;
    reg signed [BW-1:0] raycast_y = 0;
    wire [7:0] map_index = (raycast_y >> BW_DEC)*world_width + (raycast_x >> BW_DEC);
    wire [BW-1:0] d_angle = oled_pixel_index < 48 ? (48 - oled_pixel_index) << BW_DEC : (oled_pixel_index-48) << BW_DEC;
    
    //wire signed [BW-1:0] raycast_x_delta = raycast_x < x ? (x - raycast_x) : (raycast_x - x);
    //wire signed [BW-1:0] raycast_y_delta = raycast_y < y ? (y - raycast_y) : (raycast_y - y);
    //wire [BW-1:0] dist_sq = (raycast_x_delta * raycast_x_delta) + (raycast_y_delta * raycast_y_delta);
          
    
    
    assign led = (
        sw[0] ? raycast_x : 
        sw[1] ? raycast_y : 
        sw[2] ? angle[16:1] :  
        sw[3] ? raycast_step : 
        sw[4] ? cos_array[angle] : 
        sw[5] ? {world_map[map_index], map_index} : 
        sw[6] ? raycast_angle: 
        sw[7] ? distance:
        16'hffff
    );
    
    always @ (posedge clk) begin
        if (world_map[map_index] == 0) begin // && world_map_blue[map_index]==0) begin
            raycast_x <= raycast_x + (dx>>1);
            raycast_y <= raycast_y + (dy>>1);
            raycast_step <= raycast_step + 1;
            
            if (raycast_step > 50) begin
                raycast_step <= 0;
                raycast_x <= x;
                raycast_y <= y;
            end
        end else begin
           // trigger
           distance <= (
                raycast_step 
                //* (abs_cos(d_angle) >> 3)
            ); //sqrt_array[dist_sq];
           raycast_step <= 0;
           raycast_x <= x;
           raycast_y <= y;
        end
    end
    
    always @ (posedge clk_100hz) begin
    
        if (btnL)  begin
            angle[16:8] <= angle[16:8] == 0 ? 360 : angle[16:8] - (1);
        end
        if (btnR)  begin
            angle[16:8] <= angle[16:8] == 360 ? 0 : angle[16:8]  + (1);
        end
        
        if (btnU)  begin
            x_precise <= x_precise + (cos_array[angle_processed] );
            y_precise <= y_precise + (sin_array[angle_processed]);
        end
        if (btnD)  begin
            x_precise <= x_precise - (cos_array[angle_processed]);
            y_precise <= y_precise - (sin_array[angle_processed]);
        end
    end
    
    ///////////////////////////////////////////////////////////////////
    reg [15:0] pixel_data = 16'h0000;
    assign oled_pixel_data = pixel_data;
    
    wire [7:0] colour_factor = (1 + distance/(8));
    assign oled_xpos = oled_pixel_index % 96;
    assign oled_ypos = oled_pixel_index / 96;
    always @(*) begin
        if (oled_ypos <= 32) begin
            pixel_data = constant.CYAN;
        end
        if (oled_ypos >= 32) begin
            pixel_data = constant.GREEN;
        end
        if (32 - (sw/distance) <= oled_ypos && oled_ypos <= 32 + ((sw)/distance)) begin
            pixel_data = {(5'b11111 / colour_factor), 6'b11111 / colour_factor, 5'b0};
            /*
            if (world_map_blue[map_index] != 0) begin
                pixel_data = {(5'b0 / colour_factor), 6'b0 / colour_factor, 5'b11111};
            end else if (world_map[map_index] != 0) begin
                pixel_data = {(5'b11111 / colour_factor), 6'b11111 / colour_factor, 5'b0};
            end*/
        end
        
        
        display_bill(0, money_y+30);
        display_bill(17, money_y);
        display_bill(36, money_y+20);
        display_bill(53, money_y);
        display_bill(70, money_y+30);
    end
endmodule

