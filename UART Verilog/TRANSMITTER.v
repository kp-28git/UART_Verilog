module TRANSMITTER (
    input clk, rst, tx_clk, tx_enable,  // Clock, reset, and control signals
    input [7:0] TX_BYTE,                // Byte of data to be transmitted
    output reg tx_out, tx_en, TX_VALID, // UART output and status
    output TX_BUSSY                     // Busy flag
);

    // State machine states for transmitting data
    parameter IDEAL = 2'd0, STARTING = 2'd1, DATA = 2'd2, STOP = 2'd3;

    reg [1:0] current_state = IDEAL;    // Holds the current state
    reg [3:0] bit_index = 4'd8;         // Bit position tracker for TX_BYTE
    reg [7:0] TX_DATA = 0;              // Temporary storage for data byte

    // Set TX_BUSSY flag when transmitting data
    assign TX_BUSSY = (current_state == DATA);

    // State machine for controlling UART transmission
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDEAL;
            tx_out <= 1'b1; // Idle state is high for the transmission line
            TX_VALID <= 1'b0; // Not valid until stop bit is sent
        end else begin
            case (current_state)
                IDEAL: begin
                    tx_out <= 1'b1; // Idle state, transmission line high
                    if (tx_enable) begin
                        TX_DATA <= TX_BYTE; // Load byte into buffer
                        current_state <= STARTING; // Start transmission
                    end
                end

                STARTING: begin
                    tx_out <= 1'b0; // Start bit, line goes low
                    current_state <= DATA; // Move to data state
                end

                DATA: begin
                    tx_out <= TX_DATA[bit_index]; // Transmit bit-by-bit
                    if (bit_index == 4'd0) current_state <= STOP; // All bits sent
                    else bit_index <= bit_index - 1; // Move to next bit
                end

                STOP: begin
                    tx_out <= 1'b1; // Stop bit, line goes high
                    current_state <= IDEAL; // Return to idle state
                    TX_VALID <= 1'b1; // Transmission complete
                end

                default: current_state <= IDEAL; // Default to idle state
            endcase
        end
    end
endmodule
