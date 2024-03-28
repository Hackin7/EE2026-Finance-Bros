module seg_val_mapping(
    input [14:0] display_num, 
    output [6:0] seg0, 
    output [6:0] seg1,  
    output [6:0] seg2,   
    output [6:0] seg3
);
    seg_num_mapping(display_num % 10, seg0);
    seg_num_mapping(display_num / 10 % 10, seg1);
    seg_num_mapping(display_num / 100 % 10, seg2);
    seg_num_mapping(display_num / 1000 % 10, seg3);
endmodule