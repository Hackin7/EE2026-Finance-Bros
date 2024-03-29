module tables(
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

   



    always @(posedge clk) begin
        x <= oled_pixel_index % 96; 
        y <= oled_pixel_index / 96; 

        oled_pixel_data <= 16'h0000; 

        // Drawing axes
        if (x == 28) oled_pixel_data <= 16'hFFFF; 
        if (y == 12) oled_pixel_data <= 16'hFFFF; 

       
     
    end
endmodule
