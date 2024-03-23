

module test_trade_module_master();
// Simulation Inputs
    reg clk;
    reg rst;
    
    // Simulation Outputs
    parameter DBITS = 8;
    parameter UART_FRAME_SIZE = 8;
    parameter BOF_PAYLOAD = {"A", "B", "C", "D", "E", "F", "G", "H"};

    trade_packet_former trade_packet();
    trade_packet_parser trade_packet_recv();
    reg [UART_FRAME_SIZE*DBITS-1:0] uart_rx = {"A", "A", "A", "A", "A", "A", "A", "]"};
    wire [UART_FRAME_SIZE*DBITS-1:0] uart_tx;
    wire uart_tx_trigger;

    reg trigger = 1;
    
    wire [167:0]   debug_accounts;
    wire [95:0]   debug_stocks;
    wire [32-1:0] debug_admin_fees;
    wire [32-1:0] debug_general;

    // Instantiation of the module to be simulated
    trade_module_master 
        #(
         .DBITS(DBITS), .UART_FRAME_SIZE(UART_FRAME_SIZE), .RX_TIMEOUT(5) //100_000_000)
        )
        trade_slave (
        .clk_100MHz(clk), .reset(),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .uart_tx_trigger(uart_tx_trigger),
        .debug_accounts(debug_accounts),
        .debug_stocks(debug_stocks),
        .debug_admin_fees(debug_admin_fees),
        .debug_general(debug_general)
    );

    initial begin

       uart_rx = BOF_PAYLOAD;
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
	   uart_rx = {"[", 
        trade_packet_recv.TYPE_BUY, 
        8'd1, 
        8'd0, 
        8'd0, // qty 
        8'd15, // price 14, 
         "A", "]"}; //  trade_packet_recv.TYPE_OK
	   rst = 0; 
	   #10 clk = 0; #10 clk = 1;
	   #10 clk = 0; #10 clk = 1;
	   #10 clk = 0; #10 clk = 1;
       #10 clk = 0; #10 clk = 1; 
       #10 clk = 0; #10 clk = 1;

       #10 clk = 0; #10 clk = 0; 
       uart_rx = BOF_PAYLOAD;
       #10 clk = 0; #10 clk = 1;
       #10 clk = 0; #10 clk = 1;
       #10 clk = 0; #10 clk = 1; 
       #10 clk = 0; #10 clk = 1;
       
	   uart_rx = {"[", 
        trade_packet_recv.TYPE_SELL, 
        8'd1, 
        8'd0, 
        8'd1, // qty 
        8'd15, // price 14, 
         "A", "]"
       }; //  trade_packet_recv.TYPE_OK
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
    end
endmodule