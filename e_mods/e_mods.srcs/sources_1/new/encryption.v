`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.04.2024 17:29:55
// Design Name: 
// Module Name: encryption
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module encryption(
    input [63:0] data_in,
    input action,
    output [63:0] data_out
    );
    
    reg [63:0] initial_permutation_table = {8'd58, 8'd50, 8'd42, 8'd34, 8'd26, 8'd18, 8'd10, 8'd2,
                                            8'd60, 8'd52, 8'd44, 8'd36, 8'd28, 8'd20, 8'd12, 8'd4,
                                            8'd62, 8'd54, 8'd46, 8'd38, 8'd30, 8'd22, 8'd14, 8'd6,
                                            8'd64, 8'd56, 8'd48, 8'd40, 8'd32, 8'd24, 8'd16, 8'd8,
                                            8'd57, 8'd49, 8'd41, 8'd33, 8'd25, 8'd17,  8'd9, 8'd1,
                                            8'd59, 8'd51, 8'd43, 8'd35, 8'd27, 8'd19, 8'd11, 8'd3,
                                            8'd61, 8'd53, 8'd45, 8'd37, 8'd29, 8'd21, 8'd13, 8'd5,
                                            8'd63, 8'd55, 8'd47, 8'd39, 8'd31, 8'd23, 8'd15, 8'd7};
                                            
    reg [63:0] final_permutation_table = {8'd40, 8'd8, 8'd48, 8'd16, 8'd56, 8'd24, 8'd64, 8'd32,
                                          8'd39, 8'd7, 8'd47, 8'd15, 8'd55, 8'd23, 8'd63, 8'd31,
                                          8'd38, 8'd6, 8'd46, 8'd14, 8'd54, 8'd22, 8'd62, 8'd30,
                                          8'd37, 8'd5, 8'd45, 8'd13, 8'd53, 8'd21, 8'd61, 8'd29,
                                          8'd36, 8'd4, 8'd44, 8'd12, 8'd52, 8'd20, 8'd60, 8'd28,
                                          8'd35, 8'd3, 8'd43, 8'd11, 8'd51, 8'd19, 8'd59, 8'd27,
                                          8'd34, 8'd2, 8'd42, 8'd10, 8'd50, 8'd18, 8'd58, 8'd26,
                                          8'd33, 8'd1, 8'd41, 8'd9, 8'd49, 8'd17, 8'd57, 8'd25};
                                          
    reg [47:0] expansion_table = {8'd32, 8'd1, 8'd2, 8'd3, 8'd4, 8'd5, 8'd4, 8'd5,
                                8'd6, 8'd7, 8'd8, 8'd9, 8'd8, 8'd9, 8'd10, 8'd11,
                                8'd12, 8'd13, 8'd12, 8'd13, 8'd14, 8'd15, 8'd16, 8'd17,
                                8'd16, 8'd17, 8'd18, 8'd19, 8'd20, 8'd21, 8'd20, 8'd21,
                                8'd22, 8'd23, 8'd24, 8'd25, 8'd24, 8'd25, 8'd26, 8'd27,
                                8'd28, 8'd29, 8'd28, 8'd29, 8'd30, 8'd31, 8'd32, 8'd1};
                                
    reg [3:0] s_boxes [7:0][3:0][15:0];
    initial begin
        s_boxes[0][0][0] = 4'd14; s_boxes[0][0][1]  = 4'd4; s_boxes[0][0][2]  = 4'd13; s_boxes[0][0][3]  = 4'd1;
        s_boxes[0][0][4]  = 4'd2; s_boxes[0][0][5]  = 4'd15; s_boxes[0][0][6]  = 4'd11; s_boxes[0][0][7]  = 4'd8;
        s_boxes[0][0][8]  = 4'd3; s_boxes[0][0][9]  = 4'd10; s_boxes[0][0][10] = 4'd6; s_boxes[0][0][11] = 4'd12;
        s_boxes[0][0][12] = 4'd5; s_boxes[0][0][13] = 4'd9; s_boxes[0][0][14] = 4'd0; s_boxes[0][0][15] = 4'd7;
        // 14, 4, 13, 1, 2, 15, 11, 8, 3, 10, 6, 12, 5, 9, 0, 7
        
        s_boxes[0][1][0] = 4'd0; s_boxes[0][1][1] = 4'd15; s_boxes[0][1][2] = 4'd7; s_boxes[0][1][3] = 4'd4;
        s_boxes[0][1][4] = 4'd14; s_boxes[0][1][5] = 4'd2; s_boxes[0][1][6] = 4'd13; s_boxes[0][1][7] = 4'd1;
        s_boxes[0][1][8] = 4'd10; s_boxes[0][1][9] = 4'd6; s_boxes[0][1][10] = 4'd12; s_boxes[0][1][11] = 4'd11;
        s_boxes[0][1][12] = 4'd9; s_boxes[0][1][13] = 4'd5; s_boxes[0][1][14] = 4'd3; s_boxes[0][1][15] = 4'd8;
        //[0, 15, 7, 4, 14, 2, 13, 1, 10, 6, 12, 11, 9, 5, 3, 8]
        
        s_boxes[0][2][0] = 4'd4; s_boxes[0][2][1] = 4'd1; s_boxes[0][2][2] = 4'd14; s_boxes[0][2][3] = 4'd8;
        s_boxes[0][2][4] = 4'd13; s_boxes[0][2][5] = 4'd6; s_boxes[0][2][6] = 4'd2; s_boxes[0][2][7] = 4'd11;
        s_boxes[0][2][8] = 4'd15; s_boxes[0][2][9] = 4'd12; s_boxes[0][2][10] = 4'd9; s_boxes[0][2][11] = 4'd7;
        s_boxes[0][2][12] = 4'd3; s_boxes[0][2][13] = 4'd10; s_boxes[0][2][14] = 4'd5; s_boxes[0][2][15] = 4'd0;
        //[4, 1, 14, 8, 13, 6, 2, 11, 15, 12, 9, 7, 3, 10, 5, 0],
        
        s_boxes[0][3][0] = 4'd15; s_boxes[0][3][1] = 4'd12; s_boxes[0][3][2] = 4'd8; s_boxes[0][3][3] = 4'd2;
        s_boxes[0][3][4] = 4'd4; s_boxes[0][3][5] = 4'd9; s_boxes[0][3][6] = 4'd1; s_boxes[0][3][7] = 4'd7;
        s_boxes[0][3][8] = 4'd5; s_boxes[0][3][9] = 4'd11; s_boxes[0][3][10] = 4'd3; s_boxes[0][3][11] = 4'd14;
        s_boxes[0][3][12] = 4'd10; s_boxes[0][3][13] = 4'd0; s_boxes[0][3][14] = 4'd6; s_boxes[0][3][15] = 4'd13;
        //[15, 12, 8, 2, 4, 9, 1, 7, 5, 11, 3, 14, 10, 0, 6, 13]],
        
        s_boxes[1][0][0] = 4'd15; s_boxes[1][0][1]  = 4'd1; s_boxes[1][0][2]  = 4'd8; s_boxes[1][0][3]  = 4'd14;
        s_boxes[1][0][4]  = 4'd6; s_boxes[1][0][5]  = 4'd11; s_boxes[1][0][6]  = 4'd3; s_boxes[1][0][7]  = 4'd4;
        s_boxes[1][0][8]  = 4'd9; s_boxes[1][0][9]  = 4'd7; s_boxes[1][0][10] = 4'd2; s_boxes[1][0][11] = 4'd13;
        s_boxes[1][0][12] = 4'd12; s_boxes[1][0][13] = 4'd0; s_boxes[1][0][14] = 4'd5; s_boxes[1][0][15] = 4'd10;
        //4'd15, 4'd1, 4'd8, 4'd14, 4'd6, 4'd11, 4'd3, 4'd4, 4'd9, 4'd7, 4'd2, 4'd13, 4'd12, 4'd0, 4'd5, 4'd10
        
        s_boxes[1][1][0] = 4'd3; s_boxes[1][1][1] = 4'd13; s_boxes[1][1][2] = 4'd4; s_boxes[1][1][3] = 4'd7;
        s_boxes[1][1][4] = 4'd15; s_boxes[1][1][5] = 4'd2; s_boxes[1][1][6] = 4'd8; s_boxes[1][1][7] = 4'd14;
        s_boxes[1][1][8] = 4'd12; s_boxes[1][1][9] = 4'd0; s_boxes[1][1][10] = 4'd1; s_boxes[1][1][11] = 4'd10;
        s_boxes[1][1][12] = 4'd6; s_boxes[1][1][13] = 4'd9; s_boxes[1][1][14] = 4'd11; s_boxes[1][1][15] = 4'd5;
    
        s_boxes[1][2][0] = 4'd0; s_boxes[1][2][1] = 4'd14; s_boxes[1][2][2] = 4'd7; s_boxes[1][2][3] = 4'd11;
        s_boxes[1][2][4] = 4'd10; s_boxes[1][2][5] = 4'd4; s_boxes[1][2][6] = 4'd13; s_boxes[1][2][7] = 4'd1;
        s_boxes[1][2][8] = 4'd5; s_boxes[1][2][9] = 4'd8; s_boxes[1][2][10] = 4'd12; s_boxes[1][2][11] = 4'd6;
        s_boxes[1][2][12] = 4'd9; s_boxes[1][2][13] = 4'd3; s_boxes[1][2][14] = 4'd2; s_boxes[1][2][15] = 4'd15;
    
        s_boxes[1][3][0] = 4'd13; s_boxes[1][3][1] = 4'd8; s_boxes[1][3][2] = 4'd10; s_boxes[1][3][3] = 4'd1;
        s_boxes[1][3][4] = 4'd3; s_boxes[1][3][5] = 4'd15; s_boxes[1][3][6] = 4'd4; s_boxes[1][3][7] = 4'd2;
        s_boxes[1][3][8] = 4'd11; s_boxes[1][3][9] = 4'd6; s_boxes[1][3][10] = 4'd7; s_boxes[1][3][11] = 4'd12;
        s_boxes[1][3][12] = 4'd0; s_boxes[1][3][13] = 4'd5; s_boxes[1][3][14] = 4'd14; s_boxes[1][3][15] = 4'd9;
        
        s_boxes[2][0][0] = 4'd10; s_boxes[2][0][1] = 4'd0; s_boxes[2][0][2] = 4'd9; s_boxes[2][0][3] = 4'd14;
        s_boxes[2][0][4] = 4'd6;  s_boxes[2][0][5] = 4'd3;  s_boxes[2][0][6] = 4'd15; s_boxes[2][0][7] = 4'd5;
        s_boxes[2][0][8] = 4'd1;  s_boxes[2][0][9] = 4'd13; s_boxes[2][0][10] = 4'd12; s_boxes[2][0][11] = 4'd7;
        s_boxes[2][0][12] = 4'd11; s_boxes[2][0][13] = 4'd4; s_boxes[2][0][14] = 4'd2; s_boxes[2][0][15] = 4'd8;
    
        s_boxes[2][1][0] = 4'd13; s_boxes[2][1][1] = 4'd7; s_boxes[2][1][2] = 4'd0; s_boxes[2][1][3] = 4'd9;
        s_boxes[2][1][4] = 4'd3; s_boxes[2][1][5] = 4'd4; s_boxes[2][1][6] = 4'd6; s_boxes[2][1][7] = 4'd10;
        s_boxes[2][1][8] = 4'd2; s_boxes[2][1][9] = 4'd8; s_boxes[2][1][10] = 4'd5; s_boxes[2][1][11] = 4'd14;
        s_boxes[2][1][12] = 4'd12; s_boxes[2][1][13] = 4'd11; s_boxes[2][1][14] = 4'd15; s_boxes[2][1][15] = 4'd1;
    
        s_boxes[2][2][0] = 4'd13; s_boxes[2][2][1] = 4'd6; s_boxes[2][2][2] = 4'd4; s_boxes[2][2][3] = 4'd9;
        s_boxes[2][2][4] = 4'd8; s_boxes[2][2][5] = 4'd15; s_boxes[2][2][6] = 4'd3; s_boxes[2][2][7] = 4'd0;
        s_boxes[2][2][8] = 4'd11; s_boxes[2][2][9] = 4'd1; s_boxes[2][2][10] = 4'd2; s_boxes[2][2][11] = 4'd12;
        s_boxes[2][2][12] = 4'd5; s_boxes[2][2][13] = 4'd10; s_boxes[2][2][14] = 4'd14; s_boxes[2][2][15] = 4'd7;
    
        s_boxes[2][3][0] = 4'd1; s_boxes[2][3][1] = 4'd10; s_boxes[2][3][2] = 4'd13; s_boxes[2][3][3] = 4'd0;
        s_boxes[2][3][4] = 4'd6; s_boxes[2][3][5] = 4'd9; s_boxes[2][3][6] = 4'd8; s_boxes[2][3][7] = 4'd7;
        s_boxes[2][3][8] = 4'd4; s_boxes[2][3][9] = 4'd15; s_boxes[2][3][10] = 4'd14; s_boxes[2][3][11] = 4'd3;
        s_boxes[2][3][12] = 4'd11; s_boxes[2][3][13] = 4'd5; s_boxes[2][3][14] = 4'd2; s_boxes[2][3][15] = 4'd12;
        
        s_boxes[3][0][0] = 4'd7;  s_boxes[3][0][1] = 4'd13; s_boxes[3][0][2] = 4'd14; s_boxes[3][0][3] = 4'd3;
        s_boxes[3][0][4] = 4'd0;  s_boxes[3][0][5] = 4'd6;  s_boxes[3][0][6] = 4'd9;  s_boxes[3][0][7] = 4'd10;
        s_boxes[3][0][8] = 4'd1;  s_boxes[3][0][9] = 4'd2;  s_boxes[3][0][10] = 4'd8; s_boxes[3][0][11] = 4'd5;
        s_boxes[3][0][12] = 4'd11; s_boxes[3][0][13] = 4'd12; s_boxes[3][0][14] = 4'd4; s_boxes[3][0][15] = 4'd15;

        s_boxes[3][1][0] = 4'd13; s_boxes[3][1][1] = 4'd8;  s_boxes[3][1][2] = 4'd11; s_boxes[3][1][3] = 4'd5;
        s_boxes[3][1][4] = 4'd6;  s_boxes[3][1][5] = 4'd15; s_boxes[3][1][6] = 4'd0;  s_boxes[3][1][7] = 4'd3;
        s_boxes[3][1][8] = 4'd4;  s_boxes[3][1][9] = 4'd7;  s_boxes[3][1][10] = 4'd2; s_boxes[3][1][11] = 4'd12;
        s_boxes[3][1][12] = 4'd1; s_boxes[3][1][13] = 4'd10; s_boxes[3][1][14] = 4'd14; s_boxes[3][1][15] = 4'd9;

        s_boxes[3][2][0] = 4'd10; s_boxes[3][2][1] = 4'd6;  s_boxes[3][2][2] = 4'd9;  s_boxes[3][2][3] = 4'd0;
        s_boxes[3][2][4] = 4'd12; s_boxes[3][2][5] = 4'd11; s_boxes[3][2][6] = 4'd7;  s_boxes[3][2][7] = 4'd13;
        s_boxes[3][2][8] = 4'd15; s_boxes[3][2][9] = 4'd1;  s_boxes[3][2][10] = 4'd3; s_boxes[3][2][11] = 4'd14;
        s_boxes[3][2][12] = 4'd5;  s_boxes[3][2][13] = 4'd2;  s_boxes[3][2][14] = 4'd8; s_boxes[3][2][15] = 4'd4;

        s_boxes[3][3][0] = 4'd3;  s_boxes[3][3][1] = 4'd15; s_boxes[3][3][2] = 4'd0;  s_boxes[3][3][3] = 4'd6;
        s_boxes[3][3][4] = 4'd10; s_boxes[3][3][5] = 4'd1;  s_boxes[3][3][6] = 4'd13; s_boxes[3][3][7] = 4'd8;
        s_boxes[3][3][8] = 4'd9;  s_boxes[3][3][9] = 4'd4;  s_boxes[3][3][10] = 4'd5; s_boxes[3][3][11] = 4'd11;
        s_boxes[3][3][12] = 4'd12; s_boxes[3][3][13] = 4'd7;  s_boxes[3][3][14] = 4'd2; s_boxes[3][3][15] = 4'd14;

        s_boxes[4][0][0] = 4'd2;  s_boxes[4][0][1] = 4'd12; s_boxes[4][0][2] = 4'd4;  s_boxes[4][0][3] = 4'd1;
        s_boxes[4][0][4] = 4'd7;  s_boxes[4][0][5] = 4'd10; s_boxes[4][0][6] = 4'd11; s_boxes[4][0][7] = 4'd6;
        s_boxes[4][0][8] = 4'd8;  s_boxes[4][0][9] = 4'd5;  s_boxes[4][0][10] = 4'd3; s_boxes[4][0][11] = 4'd15;
        s_boxes[4][0][12] = 4'd13; s_boxes[4][0][13] = 4'd0; s_boxes[4][0][14] = 4'd14; s_boxes[4][0][15] = 4'd9;

        s_boxes[4][1][0] = 4'd14; s_boxes[4][1][1] = 4'd11; s_boxes[4][1][2] = 4'd2;  s_boxes[4][1][3] = 4'd12;
        s_boxes[4][1][4] = 4'd4;  s_boxes[4][1][5] = 4'd7;  s_boxes[4][1][6] = 4'd13; s_boxes[4][1][7] = 4'd1;
        s_boxes[4][1][8] = 4'd5;  s_boxes[4][1][9] = 4'd0;  s_boxes[4][1][10] = 4'd15; s_boxes[4][1][11] = 4'd10;
        s_boxes[4][1][12] = 4'd3; s_boxes[4][1][13] = 4'd9;  s_boxes[4][1][14] = 4'd8;  s_boxes[4][1][15] = 4'd6;

        s_boxes[4][2][0] = 4'd4;  s_boxes[4][2][1] = 4'd2;  s_boxes[4][2][2] = 4'd1;  s_boxes[4][2][3] = 4'd11;
        s_boxes[4][2][4] = 4'd10; s_boxes[4][2][5] = 4'd13; s_boxes[4][2][6] = 4'd7;  s_boxes[4][2][7] = 4'd8;
        s_boxes[4][2][8] = 4'd15; s_boxes[4][2][9] = 4'd9;  s_boxes[4][2][10] = 4'd12; s_boxes[4][2][11] = 4'd5;
        s_boxes[4][2][12] = 4'd6; s_boxes[4][2][13] = 4'd3; s_boxes[4][2][14] = 4'd0; s_boxes[4][2][15] = 4'd14;

        s_boxes[4][3][0] = 4'd11; s_boxes[4][3][1] = 4'd8;  s_boxes[4][3][2] = 4'd12; s_boxes[4][3][3] = 4'd7;
        s_boxes[4][3][4] = 4'd1;  s_boxes[4][3][5] = 4'd14; s_boxes[4][3][6] = 4'd2;  s_boxes[4][3][7] = 4'd13;
        s_boxes[4][3][8] = 4'd6;  s_boxes[4][3][9] = 4'd15; s_boxes[4][3][10] = 4'd0; s_boxes[4][3][11] = 4'd9;
        s_boxes[4][3][12] = 4'd10; s_boxes[4][3][13] = 4'd4; s_boxes[4][3][14] = 4'd5; s_boxes[4][3][15] = 4'd3;
        
        s_boxes[5][0][0] = 4'd12; s_boxes[5][0][1] = 4'd1;  s_boxes[5][0][2] = 4'd10; s_boxes[5][0][3] = 4'd15;
        s_boxes[5][0][4] = 4'd9;  s_boxes[5][0][5] = 4'd2;  s_boxes[5][0][6] = 4'd6;  s_boxes[5][0][7] = 4'd8;
        s_boxes[5][0][8] = 4'd0;  s_boxes[5][0][9] = 4'd13; s_boxes[5][0][10] = 4'd3; s_boxes[5][0][11] = 4'd4;
        s_boxes[5][0][12] = 4'd14; s_boxes[5][0][13] = 4'd7; s_boxes[5][0][14] = 4'd5; s_boxes[5][0][15] = 4'd11;

        s_boxes[5][1][0] = 4'd10; s_boxes[5][1][1] = 4'd15; s_boxes[5][1][2] = 4'd4;  s_boxes[5][1][3] = 4'd2;
        s_boxes[5][1][4] = 4'd7;  s_boxes[5][1][5] = 4'd12; s_boxes[5][1][6] = 4'd9;  s_boxes[5][1][7] = 4'd5;
        s_boxes[5][1][8] = 4'd6;  s_boxes[5][1][9] = 4'd1;  s_boxes[5][1][10] = 4'd13; s_boxes[5][1][11] = 4'd14;
        s_boxes[5][1][12] = 4'd0; s_boxes[5][1][13] = 4'd11; s_boxes[5][1][14] = 4'd3;  s_boxes[5][1][15] = 4'd8;

        s_boxes[5][2][0] = 4'd9;  s_boxes[5][2][1] = 4'd14; s_boxes[5][2][2] = 4'd15; s_boxes[5][2][3] = 4'd5;
        s_boxes[5][2][4] = 4'd2;  s_boxes[5][2][5] = 4'd8;  s_boxes[5][2][6] = 4'd12; s_boxes[5][2][7] = 4'd3;
        s_boxes[5][2][8] = 4'd7;  s_boxes[5][2][9] = 4'd0;  s_boxes[5][2][10] = 4'd4; s_boxes[5][2][11] = 4'd10;
        s_boxes[5][2][12] = 4'd1; s_boxes[5][2][13] = 4'd13; s_boxes[5][2][14] = 4'd11; s_boxes[5][2][15] = 4'd6;

        s_boxes[5][3][0] = 4'd4;  s_boxes[5][3][1] = 4'd3;  s_boxes[5][3][2] = 4'd2;  s_boxes[5][3][3] = 4'd12;
        s_boxes[5][3][4] = 4'd9;  s_boxes[5][3][5] = 4'd5;  s_boxes[5][3][6] = 4'd15; s_boxes[5][3][7] = 4'd10;
        s_boxes[5][3][8] = 4'd11; s_boxes[5][3][9] = 4'd14; s_boxes[5][3][10] = 4'd1; s_boxes[5][3][11] = 4'd7;
        s_boxes[5][3][12] = 4'd6; s_boxes[5][3][13] = 4'd0; s_boxes[5][3][14] = 4'd8; s_boxes[5][3][15] = 4'd13;

        s_boxes[6][0][0] = 4'd4;  s_boxes[6][0][1] = 4'd11; s_boxes[6][0][2] = 4'd2;  s_boxes[6][0][3] = 4'd14;
        s_boxes[6][0][4] = 4'd15; s_boxes[6][0][5] = 4'd0;  s_boxes[6][0][6] = 4'd8;  s_boxes[6][0][7] = 4'd13;
        s_boxes[6][0][8] = 4'd3;  s_boxes[6][0][9] = 4'd12; s_boxes[6][0][10] = 4'd9; s_boxes[6][0][11] = 4'd7;
        s_boxes[6][0][12] = 4'd5; s_boxes[6][0][13] = 4'd10; s_boxes[6][0][14] = 4'd6; s_boxes[6][0][15] = 4'd1;

        s_boxes[6][1][0] = 4'd13; s_boxes[6][1][1] = 4'd0;  s_boxes[6][1][2] = 4'd11; s_boxes[6][1][3] = 4'd7;
        s_boxes[6][1][4] = 4'd4;  s_boxes[6][1][5] = 4'd9;  s_boxes[6][1][6] = 4'd1;  s_boxes[6][1][7] = 4'd10;
        s_boxes[6][1][8] = 4'd14; s_boxes[6][1][9] = 4'd3;  s_boxes[6][1][10] = 4'd5; s_boxes[6][1][11] = 4'd12;
        s_boxes[6][1][12] = 4'd2; s_boxes[6][1][13] = 4'd15; s_boxes[6][1][14] = 4'd8; s_boxes[6][1][15] = 4'd6;

        s_boxes[6][2][0] = 4'd1;  s_boxes[6][2][1] = 4'd4;  s_boxes[6][2][2] = 4'd11; s_boxes[6][2][3] = 4'd13;
        s_boxes[6][2][4] = 4'd12; s_boxes[6][2][5] = 4'd3;  s_boxes[6][2][6] = 4'd7;  s_boxes[6][2][7] = 4'd14;
        s_boxes[6][2][8] = 4'd10; s_boxes[6][2][9] = 4'd15; s_boxes[6][2][10] = 4'd6; s_boxes[6][2][11] = 4'd8;
        s_boxes[6][2][12] = 4'd0; s_boxes[6][2][13] = 4'd5;  s_boxes[6][2][14] = 4'd9; s_boxes[6][2][15] = 4'd2;

        s_boxes[6][3][0] = 4'd6;  s_boxes[6][3][1] = 4'd11; s_boxes[6][3][2] = 4'd13; s_boxes[6][3][3] = 4'd8;
        s_boxes[6][3][4] = 4'd1;  s_boxes[6][3][5] = 4'd4;  s_boxes[6][3][6] = 4'd10; s_boxes[6][3][7] = 4'd7;
        s_boxes[6][3][8] = 4'd9;  s_boxes[6][3][9] = 4'd5;  s_boxes[6][3][10] = 4'd0; s_boxes[6][3][11] = 4'd15;
        s_boxes[6][3][12] = 4'd14; s_boxes[6][3][13] = 4'd2;  s_boxes[6][3][14] = 4'd3; s_boxes[6][3][15] = 4'd12;

        s_boxes[7][0][0] = 4'd13; s_boxes[7][0][1] = 4'd2;  s_boxes[7][0][2] = 4'd8;  s_boxes[7][0][3] = 4'd4;
        s_boxes[7][0][4] = 4'd6;  s_boxes[7][0][5] = 4'd15; s_boxes[7][0][6] = 4'd11; s_boxes[7][0][7] = 4'd1;
        s_boxes[7][0][8] = 4'd10; s_boxes[7][0][9] = 4'd9;  s_boxes[7][0][10] = 4'd3; s_boxes[7][0][11] = 4'd14;
        s_boxes[7][0][12] = 4'd5; s_boxes[7][0][13] = 4'd0; s_boxes[7][0][14] = 4'd12; s_boxes[7][0][15] = 4'd7;

        s_boxes[7][1][0] = 4'd1;  s_boxes[7][1][1] = 4'd15; s_boxes[7][1][2] = 4'd13; s_boxes[7][1][3] = 4'd8;
        s_boxes[7][1][4] = 4'd10; s_boxes[7][1][5] = 4'd3;  s_boxes[7][1][6] = 4'd7;  s_boxes[7][1][7] = 4'd4;
        s_boxes[7][1][8] = 4'd12; s_boxes[7][1][9] = 4'd5;  s_boxes[7][1][10] = 4'd6; s_boxes[7][1][11] = 4'd11;
        s_boxes[7][1][12] = 4'd0; s_boxes[7][1][13] = 4'd14; s_boxes[7][1][14] = 4'd9; s_boxes[7][1][15] = 4'd2;

        s_boxes[7][2][0] = 4'd7;  s_boxes[7][2][1] = 4'd11; s_boxes[7][2][2] = 4'd4;  s_boxes[7][2][3] = 4'd1;
        s_boxes[7][2][4] = 4'd9;  s_boxes[7][2][5] = 4'd12; s_boxes[7][2][6] = 4'd14; s_boxes[7][2][7] = 4'd2;
        s_boxes[7][2][8] = 4'd0;  s_boxes[7][2][9] = 4'd6;  s_boxes[7][2][10] = 4'd10; s_boxes[7][2][11] = 4'd13;
        s_boxes[7][2][12] = 4'd15; s_boxes[7][2][13] = 4'd3; s_boxes[7][2][14] = 4'd5;  s_boxes[7][2][15] = 4'd8;

        s_boxes[7][3][0] = 4'd2;  s_boxes[7][3][1] = 4'd1;  s_boxes[7][3][2] = 4'd14; s_boxes[7][3][3] = 4'd7;
        s_boxes[7][3][4] = 4'd4;  s_boxes[7][3][5] = 4'd10; s_boxes[7][3][6] = 4'd8;  s_boxes[7][3][7] = 4'd13;
        s_boxes[7][3][8] = 4'd15; s_boxes[7][3][9] = 4'd12; s_boxes[7][3][10] = 4'd9; s_boxes[7][3][11] = 4'd0;
        s_boxes[7][3][12] = 4'd3; s_boxes[7][3][13] = 4'd5;  s_boxes[7][3][14] = 4'd6; s_boxes[7][3][15] = 4'd11;
    end
    
    reg [7:0] i = 0;
    reg [63:0] result;
    function [63:0] permute(input [63:0] k, input [63:0] arr, input [7:0] n); begin
        for (i = 0; i < n; i = i + 1) begin
            result = result + k[arr[i] - 1];
        end
        permute = result;
    end
    endfunction

    reg [31:0] left, right;
    reg [47:0] right_expanded, xor_intermediate;
    reg [63:0] initial_permute;
    reg [7:0] j = 0;
    reg [47:0] rkb [15:0];
    function [63:0] encrypt(
        input [63:0] plaintext
    ); begin
        initial_permute = permute(plaintext, initial_permutation_table, 8'd64);
        left = initial_permute[31:0];
        right = initial_permute[63:32];
        for (j = 0; j < 16; j = j + 1) begin
            right_expanded = permute(right, expansion_table, 48);
            xor_intermediate = right_expanded ^ rkb[i];
        end
        
    end
    endfunction

endmodule
