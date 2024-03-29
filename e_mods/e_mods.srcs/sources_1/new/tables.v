module tables(
    input reset, input clk,
    input btnC, btnU, btnL, btnR, btnD, input [15:0] sw, output [15:0] led,
    output [6:0] seg, output dp, output [3:0] an,
    input [12:0] oled_pixel_index, output [15:0] pixel_data
    
);

    reg [15:0] oled_pixel_data = 16'h0000;
    assign pixel_data = oled_pixel_data;
    reg [7:0] xpos;
    reg [7:0] ypos; 

   



    always @(posedge clk) begin
        xpos <= oled_pixel_index % 96; 
        ypos <= oled_pixel_index / 96; 

        oled_pixel_data <= 16'h0000; 

        // Drawing axes
        if (xpos == 28) oled_pixel_data <= 16'hFFFF; 
        if (ypos == 12) oled_pixel_data <= 16'hFFFF; 

       
     
    end
endmodule
