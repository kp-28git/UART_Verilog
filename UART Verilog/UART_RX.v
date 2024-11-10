module UART_RX (
    input clk, rst, rx_en, rx_clk, rx_in, rx_tick, // Control signals and input data
    output rx_bussy, rx_error, rx_valid,           // Status flags
    output reg [7:0] RX_DATA                      // Received data
);

    // State machine states for UART reception
    parameter IDEAL = 3'd0, START = 3'd1, DATA = 3'd2, STOP = 3'd3, ERROR = 3'd4;
    
    reg [2:0] current_state = IDEAL;    // Current state of the receiver FSM
    reg [3:0] count = 4'd0;             // Bit count during reception
    reg [7:0] RX_BUFFER = 8'd0;         // Buffer for received data

    // Flag assignments
    assign rx_bussy = (current_state == DATA);  // Receiver busy during data reception
    assign rx_error = (current_state == ERROR); // Error flag
    assign rx_valid = (current_state == STOP);  // Data valid after stop bit

    // State machine for controlling UART reception
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDEAL;
        end else begin
            case (current_state)
                IDEAL: begin
                    if (rx_en && !rx_in) begin  // Wait for start bit (low)
                        current_state <= START;
                    end
                end

                START: begin
                    if (rx_tick) begin
                        if (!rx_in) begin // Valid start bit detected
                            current_state <= DATA;
                            count <= 4'd8; // Start receiving 8 data bits
                        end else current_state <= ERROR; // Invalid start bit
                    end
                end

                DATA: begin
                    if (rx_tick) begin
                        RX_BUFFER[count] <= rx_in; // Store received bit
                        if (count == 0) current_state <= STOP; // Done receiving data
                        else count <= count - 1;
                    end
                end

                STOP: begin
                    if (rx_tick && rx_in) begin  // Valid stop bit (high)
                        RX_DATA <= RX_BUFFER; // Store received byte
                        current_state <= IDEAL;
                    end else current_state <= ERROR; // Invalid stop bit
                end

                ERROR: begin
                    if (!rx_en) current_state <= IDEAL; // Reset to IDEAL if disabled
                end

                default: current_state <= IDEAL; // Default to IDEAL state
            endcase
        end
    end
endmodule
