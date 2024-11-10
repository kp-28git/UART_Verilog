module BAUD_GENERATOR (
    input clk_in, rst,             // System clock and reset
    input [1:0] baud_sel,          // Baud rate selection
    output reg tx_clk = 0, rx_clk = 0, rx_tick = 0  // UART clock outputs
);

    // Baud rate constants for different communication speeds
    parameter TX_BAUD_2400 = 15'd20832, TX_BAUD_9600 = 15'd5200,
              TX_BAUD_19200 = 15'd2608, TX_BAUD_38400 = 15'd1296;

    parameter RX_BAUD_2400 = 11'd1302, RX_BAUD_9600 = 11'd325,
              RX_BAUD_19200 = 11'd163, RX_BAUD_38400 = 11'd81;

    reg [14:0] tx_count = 0;           // Counter for transmitter clock
    reg [10:0] rx_count = 0;           // Counter for receiver clock
    reg [4:0] baud_tick_count = 0;     // Counter for rx_tick pulse generation

    reg [14:0] TX_MAX_COUNT = TX_BAUD_9600;  // Default baud rate for transmitter
    reg [10:0] RX_MAX_COUNT = RX_BAUD_9600;  // Default baud rate for receiver

    // Set baud rate constants based on baud_sel input
    always @(*) begin
        case (baud_sel)
            2'd0: begin TX_MAX_COUNT = TX_BAUD_2400; RX_MAX_COUNT = RX_BAUD_2400; end
            2'd1: begin TX_MAX_COUNT = TX_BAUD_9600; RX_MAX_COUNT = RX_BAUD_9600; end
            2'd2: begin TX_MAX_COUNT = TX_BAUD_19200; RX_MAX_COUNT = RX_BAUD_19200; end
            2'd3: begin TX_MAX_COUNT = TX_BAUD_38400; RX_MAX_COUNT = RX_BAUD_38400; end
            default: begin TX_MAX_COUNT = TX_BAUD_9600; RX_MAX_COUNT = RX_BAUD_9600; end
        endcase
    end

    // Generate transmitter clock (tx_clk)
    always @(posedge clk_in or posedge rst) begin
        if (rst) begin
            tx_clk <= 0;
            tx_count <= 0;
        end else begin
            if (tx_count == TX_MAX_COUNT) begin
                tx_clk <= ~tx_clk; // Toggle tx_clk at baud rate intervals
                tx_count <= 0;     // Reset counter
            end else begin
                tx_count <= tx_count + 1; // Increment counter
            end
        end
    end

    // Generate receiver clock (rx_clk)
    always @(posedge clk_in or posedge rst) begin
        if (rst) begin
            rx_clk <= 0;
            rx_count <= 0;
        end else begin
            if (rx_count == RX_MAX_COUNT) begin
                rx_clk <= ~rx_clk; // Toggle rx_clk at baud rate intervals
                rx_count <= 0;     // Reset counter
            end else begin
                rx_count <= rx_count + 1; // Increment counter
            end
        end
    end

    // Generate rx_tick signal (sample incoming data at correct intervals)
    always @(posedge clk_in or posedge rst or posedge rx_clk) begin
        if (rst) begin
            baud_tick_count <= 0;
            rx_tick <= 0;
        end else if (rx_clk) begin
            if (baud_tick_count == 5'd7) rx_tick <= 1; // Generate tick after 7 cycles
            if (baud_tick_count == 5'd16) baud_tick_count <= 0; // Reset counter after 16 cycles
            else baud_tick_count <= baud_tick_count + 1;
        end
    end

endmodule
