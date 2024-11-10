# UART Communication System

This repository contains a Verilog-based implementation of a **UART (Universal Asynchronous Receiver/Transmitter) communication system**. The system is modular and includes four main components: `UART_TOP`, `BAUD_GENERATOR`, `TRANSMITTER`, and `UART_RX`. It allows configurable baud rates and supports both serial data transmission and reception with error handling.

---

## Table of Contents
- [Project Overview](#project-overview)
- [Module Descriptions](#module-descriptions)
  - [UART_TOP Module](#uart_top-module)
  - [BAUD_GENERATOR Module](#baud_generator-module)
  - [TRANSMITTER Module](#transmitter-module)
  - [UART_RX Module](#uart_rx-module)

---

## Project Overview

This UART communication system supports serial data exchange between devices with the ability to set different baud rates. It’s designed to meet common embedded system requirements for UART communication and offers features such as:
- **Synchronized Data Transmission and Reception**
- **Configurable Baud Rates** (2400, 9600, 19200, and 38400 baud)
- **Error Detection** in received data
- **State Machine Control** for both transmitter and receiver

---

## Module Descriptions

### UART_TOP Module

The `UART_TOP` module integrates all submodules and controls the communication flow by coordinating the baud generator, transmitter, and receiver modules.

#### Inputs
- `clk`, `rst`: System clock and reset signals
- `tx_enable`: Enables data transmission
- `baud_sel`: 2-bit signal to set baud rate
- `TX_BYTE`: 8-bit data input for transmission

#### Outputs
- `rx_bussy`, `rx_error`, `rx_valid`: Status flags for receiver
- `RX_DATA`: 8-bit data output from received data
- `TX_VALID`, `TX_BUSSY`: Transmitter status flags
- `tx_clk`, `rx_clk`, `rx_tick`: Clocks and sampling pulse for data synchronization

### BAUD_GENERATOR Module

The `BAUD_GENERATOR` module generates transmission (`tx_clk`) and reception (`rx_clk`) clocks based on the selected baud rate (`baud_sel`). It ensures correct timing for data synchronization.

#### Inputs
- `clk_in`: System clock
- `rst`: Reset signal
- `baud_sel`: 2-bit baud rate selection input

#### Outputs
- `tx_clk`: Clock signal for transmission
- `rx_clk`: Clock signal for reception
- `rx_tick`: Sampling pulse for reliable data reception

Baud Rate options:
- **2400, 9600, 19200, and 38400 baud**, controlled by `baud_sel`.

### TRANSMITTER Module

The `TRANSMITTER` module is responsible for serial data transmission. It uses a finite state machine to transmit each bit of `TX_BYTE` over `tx_out` with start and stop bits, ensuring UART protocol compliance.

#### Inputs
- `clk`, `rst`: System clock and reset
- `tx_clk`: Transmission clock from `BAUD_GENERATOR`
- `tx_enable`: Signal to initiate transmission
- `TX_BYTE`: 8-bit data to be transmitted

#### Outputs
- `tx_out`: Serial data output line
- `TX_BUSSY`: Indicates active transmission
- `TX_VALID`: Indicates transmission completion

### UART_RX Module

The `UART_RX` module manages data reception. It identifies start and stop bits, samples data bits, and detects errors when incorrect bits are received.

#### Inputs
- `clk`, `rst`: System clock and reset
- `rx_en`: Enables data reception
- `rx_clk`: Reception clock from `BAUD_GENERATOR`
- `rx_in`: Serial data input line
- `rx_tick`: Sampling pulse for accurate data reading

#### Outputs
- `rx_bussy`: Indicates receiver activity
- `rx_error`: Flags an error if start or stop bits are invalid
- `rx_valid`: Indicates valid data
- `RX_DATA`: Stores 8-bit received data
