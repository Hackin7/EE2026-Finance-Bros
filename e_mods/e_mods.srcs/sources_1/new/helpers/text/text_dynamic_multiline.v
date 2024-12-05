module text_dynamic_multiline#(
    parameter STR_LEN=15
)(
    input [31:0] xpos, ypos, // Current pixel position
    input [15:0] colour, 
    input [8*STR_LEN-1:0] line1, 
    input [8*STR_LEN-1:0] line2, 
    input [8*STR_LEN-1:0] line3, 
    input [8*STR_LEN-1:0] line4, 
    input [8*STR_LEN-1:0] line5, 
    input [8*STR_LEN-1:0] line6,
    input [8*STR_LEN-1:0] line7,
    output [15:0] oled_pixel_data
);
    //constants library
    constants constant();

    text_dynamic #(STR_LEN) text_module(
		.x(xpos), .y(ypos), 
		.color(colour), //xpos > 49 ? constant.CYAN : constant.WHITE), 
        .background(constant.BLACK), 
		.text_y_pos(
			ypos < 10 ? 0 : 
			ypos < 20 ? 10 : 
			ypos < 30 ? 20 : 
			ypos < 40 ? 30 : 
			ypos < 50 ? 40 :
			ypos < 60 ? 50 :
			60
		), 
		.string(
			ypos < 10 ? line1 : 
			ypos < 20 ? line2 : 
			ypos < 30 ? line3 : 
			ypos < 40 ? line4 : 
			ypos < 50 ? line5 :
			ypos < 60 ? line6 :
			line7
		), 
		.offset(0), //9*6), 
		.repeat_flag(0), 
        .x_pos_offset(0), 
        .pixel_data(oled_pixel_data)
    );
endmodule