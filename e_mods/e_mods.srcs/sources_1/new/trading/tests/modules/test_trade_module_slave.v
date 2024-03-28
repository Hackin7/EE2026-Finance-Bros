
module test_trade_module_slave();
    // Simulation Inputs
    reg clk;
    reg rst;
    
    // Simulation Outputs
    parameter DBITS = 8;
    parameter UART_FRAME_SIZE = 8;

    trade_packet_former trade_packet();
    trade_packet_parser trade_packet_recv();
    reg [UART_FRAME_SIZE*DBITS-1:0] uart_rx = {"A", "A", "A", "A", "A", "A", "A", "]"};
    wire [UART_FRAME_SIZE*DBITS-1:0] uart_tx;
    wire uart_tx_trigger;
    wire uart_rx_clear;

    reg trigger = 1;
    
    wire [7:0] send_status;
    wire [7:0] fsm_state;
    wire [32-1:0] fsm_timer;

    // Instantiation of the module to be simulated
    trade_module_slave 
        #(
         .DBITS(DBITS), .UART_FRAME_SIZE(UART_FRAME_SIZE), .RX_TIMEOUT(5) //100_000_000)
        )
        trade_slave (
        .clk_100MHz(clk), .reset(),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .uart_tx_trigger(uart_tx_trigger),
        .uart_rx_clear(uart_rx_clear),
        // Trade Parameters
        .tx_type(trade_packet.TYPE_BUY), //0
        .tx_account_id(4),
        .tx_stock_id(1),
        .tx_qty(2),
        .tx_price(3),
        .trigger(trigger),
        .send_status(send_status),

        // Debugging Ports
        //.sw(sw), .led(led)
        .fsm_state(fsm_state), .fsm_timer(fsm_timer)
    );
    
    // Stimuli
    initial begin

       uart_rx = {"A", "A", "A", "A", "A", "A", "A", "]"};
	   clk = 0; rst = 1; 
       trigger = 1;
	   #10 clk = 0; #10 clk = 1;
       trigger = 0;
	   #10 clk = 0; #10 clk = 1;
	   rst = 0;
       #10 clk = 0; #10 clk = 1;
       #10 clk = 0; #10 clk = 1;
	   #10 clk = 0; #10 clk = 1;
	   #10 clk = 0; #10 clk = 1;
       #10 clk = 0; #10 clk = 1;
       #10 clk = 0; #10 clk = 1;
       #10 clk = 0; #10 clk = 1;
       #10 clk = 0; #10 clk = 1;
       #10 clk = 0; #10 clk = 1;
       #10 clk = 0; #10 clk = 1;
       #10 clk = 0; #10 clk = 1;
       #10 clk = 0; #10 clk = 1;
	   uart_rx = {"[", trade_packet_recv.TYPE_OK, "[", "A", "A", "A", "A", "]"}; //  trade_packet_recv.TYPE_OK
	   rst = 0; 
	   #10 clk = 0; #10 clk = 1;
	   #10 clk = 0; #10 clk = 1;
	   #10 clk = 0; #10 clk = 1;
       // uart_rx = {"[", trade_packet_recv.TYPE_OK, "A", "A", "A", "A", "A", "]"}; //  trade_packet_recv.TYPE_OK
	   #10 clk = 0; #10 clk = 1; 
       #10 clk = 0; #10 clk = 1;
       #10 clk = 0; #10 clk = 1;
       #10 clk = 0; #10 clk = 1;
       #10 clk = 0; #10 clk = 1; 
       #10 clk = 0; #10 clk = 1;
       #10 clk = 0; #10 clk = 1;
       #10 clk = 0; #10 clk = 1;
       trigger = 1;
       #10 clk = 0; #10 clk = 1; 
       #10 clk = 0; #10 clk = 1; 
       #10 clk = 0; #10 clk = 1;
       #10 clk = 0; #10 clk = 1;
       #10 clk = 0; #10 clk = 1;
       #10 clk = 0; #10 clk = 1; 
       #10 clk = 0; #10 clk = 1;
       #10 clk = 0; #10 clk = 1;
       #10 clk = 0; #10 clk = 1;
       #10 clk = 0; #10 clk = 1; 
    end
endmodule