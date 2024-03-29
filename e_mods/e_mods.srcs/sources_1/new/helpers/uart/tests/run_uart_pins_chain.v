

module run_uart_pins_chain (
    // Control
    input clk,
    // LEDs, Switches, Buttons
    input btnC, btnU, btnL, btnR, btnD, input [15:0] sw, output [15:0] led,
    // 7 Segment Display
    output [6:0] seg, output dp, output [3:0] an,
    // UART
    input rxUSB, output txUSB,
    input rx0, rx1, rx2,
    output tx0, tx1, tx2,
    // OLED PMOD
    inout [7:0] JB,
    inout mouse_ps2_clk, mouse_ps2_data
);
    assign tx0 = rxUSB;
    assign txUSB = rx0;
endmodule