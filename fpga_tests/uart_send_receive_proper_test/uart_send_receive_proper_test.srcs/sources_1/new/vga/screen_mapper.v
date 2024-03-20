`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.02.2024 20:01:41
// Design Name: 
// Module Name: screen_mapper
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


module screen_mapper(
    input [9:0] x, y,
    output reg [12:0] position
    );
    //assign position = x * 48 + y;
    reg [9:0] new_x;
    reg [9:0] new_y;
    
    always @* begin
        if (0 <= x && x <= 9)
            new_x = 0;
        else if (10 <= x && x <= 19)
            new_x = 1;
        else if (20 <= x && x <= 29)
            new_x = 2;
        else if (30 <= x && x <= 39)
            new_x = 3;
        else if (40 <= x && x <= 49)
            new_x = 4;
        else if (50 <= x && x <= 59)
            new_x = 5;
        else if (60 <= x && x <= 69)
            new_x = 6;
        else if (70 <= x && x <= 79)
            new_x = 7;
        else if (80 <= x && x <= 89)
            new_x = 8;
        else if (90 <= x && x <= 99)
            new_x = 9;
        else if (100 <= x && x <= 109)
            new_x = 10;
        else if (110 <= x && x <= 119)
            new_x = 11;
        else if (120 <= x && x <= 129)
            new_x = 12;
        else if ((130 <= x) && (x <= 139))
            new_x = 13;
        else if (140 <= x && x <= 149)
            new_x = 14;
        else if (150 <= x && x <= 159)
            new_x = 15;
        else if (160 <= x && x <= 169)
            new_x = 16;
        else if (170 <= x && x <= 179)
            new_x = 17;
        else if (180 <= x && x <= 189)
            new_x = 18;
        else if (190 <= x && x <= 199)
            new_x = 19;
        else if (200 <= x && x <= 209)
            new_x = 20;
        else if (210 <= x && x <= 219)
            new_x = 21;
        else if (220 <= x && x <= 229)
            new_x = 22;
        else if (230 <= x && x <= 239)
            new_x = 23;
        else if (240 <= x && x <= 249)
            new_x = 24;
        else if (250 <= x && x <= 259)
            new_x = 25;
        else if (260 <= x && x <= 269)
            new_x = 26;
        else if (270 <= x && x <= 279)
            new_x = 27;
        else if (280 <= x && x <= 289)
            new_x = 28;
        else if (290 <= x && x <= 299)
            new_x = 29;
        else if (300 <= x && x <= 309)
            new_x = 30;
        else if (310 <= x && x <= 319)
            new_x = 31;
        else if (320 <= x && x <= 329)
            new_x = 32;
        else if (330 <= x && x <= 339)
            new_x = 33;
        else if (340 <= x && x <= 349)
            new_x = 34;
        else if (350 <= x && x <= 359)
            new_x = 35;
        else if (360 <= x && x <= 369)
            new_x = 36;
        else if (370 <= x && x <= 379)
            new_x = 37;
        else if (380 <= x && x <= 389)
            new_x = 38;
        else if (390 <= x && x <= 399)
            new_x = 39;
        else if (400 <= x && x <= 409)
            new_x = 40;
        else if (410 <= x && x <= 419)
            new_x = 41;
        else if (420 <= x && x <= 429)
            new_x = 42;
        else if (430 <= x && x <= 439)
            new_x = 43;
        else if (440 <= x && x <= 449)
            new_x = 44;
        else if (450 <= x && x <= 459)
            new_x = 45;
        else if (460 <= x && x <= 469)
            new_x = 46;
        else if (470 <= x && x <= 479)
            new_x = 47;
        else if (480 <= x && x <= 489)
            new_x = 48;
        else if (490 <= x && x <= 499)
            new_x = 49;
        else if (500 <= x && x <= 509)
            new_x = 50;
        else if (510 <= x && x <= 519)
            new_x = 51;
        else if (520 <= x && x <= 529)
            new_x = 52;
        else if (530 <= x && x <= 539)
            new_x = 53;
        else if (540 <= x && x <= 549)
            new_x = 54;
        else if (550 <= x && x <= 559)
            new_x = 55;
        else if (560 <= x && x <= 569)
            new_x = 56;
        else if (570 <= x && x <= 579)
            new_x = 57;
        else if (580 <= x && x <= 589)
            new_x = 58;
        else if (590 <= x && x <= 599)
            new_x = 59;
        else if (600 <= x && x <= 609)
            new_x = 60;
        else if (610 <= x && x <= 619)
            new_x = 61;
        else if (620 <= x && x <= 629)
            new_x = 62;
        else if (630 <= x && x <= 639)
            new_x = 63;
        if (0 <= y && y <= 9)
            new_y = 0;
        else if (10 <= y && y <= 19)
            new_y = 1;
        else if (20 <= y && y <= 29)
            new_y = 2;
        else if (30 <= y && y <= 39)
            new_y = 3;
        else if (40 <= y && y <= 49)
            new_y = 4;
        else if (50 <= y && y <= 59)
            new_y = 5;
        else if (60 <= y && y <= 69)
            new_y = 6;
        else if (70 <= y && y <= 79)
            new_y = 7;
        else if (80 <= y && y <= 89)
            new_y = 8;
        else if (90 <= y && y <= 99)
            new_y = 9;
        else if (100 <= y && y <= 109)
            new_y = 10;
        else if (110 <= y && y <= 119)
            new_y = 11;
        else if (120 <= y && y <= 129)
            new_y = 12;
        else if ((130 <= y) && (y <= 139))
            new_y = 13;
        else if (140 <= y && y <= 149)
            new_y = 14;
        else if (150 <= y && y <= 159)
            new_y = 15;
        else if (160 <= y && y <= 169)
            new_y = 16;
        else if (170 <= y && y <= 179)
            new_y = 17;
        else if (180 <= y && y <= 189)
            new_y = 18;
        else if (190 <= y && y <= 199)
            new_y = 19;
        else if (200 <= y && y <= 209)
            new_y = 20;
        else if (210 <= y && y <= 219)
            new_y = 21;
        else if (220 <= y && y <= 229)
            new_y = 22;
        else if (230 <= y && y <= 239)
            new_y = 23;
        else if (240 <= y && y <= 249)
            new_y = 24;
        else if (250 <= y && y <= 259)
            new_y = 25;
        else if (260 <= y && y <= 269)
            new_y = 26;
        else if (270 <= y && y <= 279)
            new_y = 27;
        else if (280 <= y && y <= 289)
            new_y = 28;
        else if (290 <= y && y <= 299)
            new_y = 29;
        else if (300 <= y && y <= 309)
            new_y = 30;
        else if (310 <= y && y <= 319)
            new_y = 31;
        else if (320 <= y && y <= 329)
            new_y = 32;
        else if (330 <= y && y <= 339)
            new_y = 33;
        else if (340 <= y && y <= 349)
            new_y = 34;
        else if (350 <= y && y <= 359)
            new_y = 35;
        else if (360 <= y && y <= 369)
            new_y = 36;
        else if (370 <= y && y <= 379)
            new_y = 37;
        else if (380 <= y && y <= 389)
            new_y = 38;
        else if (390 <= y && y <= 399)
            new_y = 39;
        else if (400 <= y && y <= 409)
            new_y = 40;
        else if (410 <= y && y <= 419)
            new_y = 41;
        else if (420 <= y && y <= 429)
            new_y = 42;
        else if (430 <= y && y <= 439)
            new_y = 43;
        else if (440 <= y && y <= 449)
            new_y = 44;
        else if (450 <= y && y <= 459)
            new_y = 45;
        else if (460 <= y && y <= 469)
            new_y = 46;
        else if (470 <= y && y <= 479)
            new_y = 47;
        else if (480 <= y && y <= 489)
            new_y = 48;
            
        position = new_x * 48 + new_y;
    end
endmodule
