module text_num_val_mapping #(
    parameter STR_LEN=4
)(
    input [14:0] display_num, 
    output [8*STR_LEN-1:0] string
);
    wire [3:0] digit1 = (display_num % 10);
    wire [3:0] digit2 = (display_num / 10) % 10;
    wire [3:0] digit3 = (display_num / 100) % 10;
    wire [3:0] digit4 = (display_num / 1000) % 10;

    function [7:0] digitToChar(input [3:0] digit);
    begin
        if (digit == 0) digitToChar = "0";
        else if (digit == 1) digitToChar = "1";
        else if (digit == 2) digitToChar = "2";
        else if (digit == 3) digitToChar = "3";
        else if (digit == 4) digitToChar = "4";
        else if (digit == 5) digitToChar = "5";
        else if (digit == 6) digitToChar = "6";
        else if (digit == 7) digitToChar = "7";
        else if (digit == 8) digitToChar = "8";
        else if (digit == 9) digitToChar = "9";
        else if (digit == 10) digitToChar = "A";
        else if (digit == 11) digitToChar = "B";
        else if (digit == 12) digitToChar = "C";
        else if (digit == 13) digitToChar = "D";
        else if (digit == 14) digitToChar = "E";
        else if (digit == 15) digitToChar = "F";
        else digitToChar = " ";
    end
    endfunction

    assign string = {
        digitToChar(digit4), 
        digitToChar(digit3), 
        digitToChar(digit2), 
        digitToChar(digit1)
    };
endmodule