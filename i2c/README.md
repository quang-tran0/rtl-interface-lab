# I2C

A small Verilog I2C master exercise for writing one byte.

## Features

- Generated SCL timing
- START and STOP conditions
- One MSB-first byte write
- ACK/NACK detection

## Ports

| Signal | Direction | Purpose |
| --- | --- | --- |
| `clk`, `reset_n` | input | Clock and active-low reset |
| `start`, `data_in[7:0]` | input | Begin a byte write |
| `scl` | output | Serial clock |
| `sda` | inout | Open-drain serial data |
| `busy`, `done` | output | Transfer status |
| `ack_error` | output | High when the byte is NACKed |

## Simulation

```sh
vlib work
vlog rtl/*.v tb/i2c_ack_tb.v
vsim -c i2c_ack_tb -do "run -all; quit -f"
```

This version does not support reads, addressing, arbitration, or clock stretching.
