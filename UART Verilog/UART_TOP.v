module UART_TOP (
    input clk, rst,              // System clock and reset
    input tx_enable,             // Enable signal for transmission
    input [1:0] baud_sel,        // Baud rate selection (for speed)
    input [7:0] TX_BYTE,         // Byte of data to be transmitted

    output rx_bussy, rx_error, rx_valid,   // Receiver status outputs
    output [7:0] RX_DATA,        // Data received from UART
    output TX_VALID, TX_BUSSY,   // Transmitter status outputs
    output tx_clk, rx_clk,       // Transmitter and receiver clock signals
    output rx_tick, data, enable // Other control signals
);

    // Baud rate generator to create the necessary clock signals
    BAUD_GENERATOR bg (
        .clk_in(clk), .rst(rst), .tx_clk(tx_clk), .rx_clk(rx_clk),
        .baud_sel(baud_sel), .rx_tick(rx_tick)
    );

    // UART Receiver for handling incoming data
    UART_RX rx (
        .clk(clk), .rst(rst), .rx_en(enable), .rx_clk(rx_clk), 
        .rx_in(data), .rx_tick(rx_tick), 
        .rx_bussy(rx_bussy), .rx_valid(rx_valid), .rx_error(rx_error), 
        .RX_DATA(RX_DATA)
    );

    // UART Transmitter for sending outgoing data
    TRANSMITTER tx (
        .clk(clk), .rst(rst), .tx_clk(tx_clk), .tx_out(data), 
        .TX_BYTE(TX_BYTE), .TX_BUSSY(TX_BUSSY), .TX_VALID(TX_VALID), 
        .tx_enable(tx_enable), .tx_en(enable), .ind()
    );

endmodule
