# SPI

A small Verilog SPI master for single-byte transfers.

## Features

- One active-low chip select
- 8-bit full-duplex transfers, MSB first
- Modes 0, 1, 2, and 3 through `CPOL` and `CPHA`

## Ports

| Signal | Direction | Purpose |
| --- | --- | --- |
| `clk`, `reset_n` | input | Clock and active-low reset |
| `start`, `tx_data[7:0]` | input | Begin a transfer |
| `sclk`, `mosi`, `cs_n` | output | SPI master signals |
| `miso` | input | SPI receive data |
| `rx_data[7:0]` | output | Received byte |
| `busy`, `done` | output | Transfer status |

## Simulation

```sh
vlib work
vlog rtl/*.v tb/*.v
vsim -c spi_modes_tb -do "run -all; quit -f"
```

The exercise does not support variable word lengths or multiple chip selects.
