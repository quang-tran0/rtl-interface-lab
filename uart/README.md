# UART

A small UART transmitter and receiver written as a first Verilog exercise.

## Features

- 8 data bits, no parity, 1 stop bit
- 16 sampling ticks per bit
- Fixed baud rate selected by the divider parameter

## Ports

| Signal | Direction | Purpose |
| --- | --- | --- |
| `clk`, `reset_n` | input | Clock and active-low reset |
| `start`, `data_in[7:0]` | input | Start a transmit byte |
| `tx`, `busy` | output | Serial transmit and status |
| `rx` | input | Serial receive |
| `data_out[7:0]`, `data_valid` | output | Received byte and pulse |

## Simulation

```sh
vlib work
vlog rtl/*.v tb/uart_loopback_tb.v
vsim -c uart_loopback_tb -do "run -all; quit -f"
```

The testbenches are directed checks for transmit, receive, and loopback.
