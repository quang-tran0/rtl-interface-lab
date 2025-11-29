# RTL Interface Lab

Small protocol exercises built while learning RTL design and verification.

## Protocols

- UART: fixed 8-N-1 transmit and receive
- I2C: one-byte master write with ACK/NACK
- SPI: 8-bit master supporting modes 0 through 3

![UART, I2C, and SPI connections](assets/serial_interfaces.png)

## Layout

Each protocol currently keeps hand-written RTL in `rtl/` and directed tests in `tb/`.

## Tools

The examples use QuestaSim commands:

```sh
cd uart
vlib work
vlog rtl/*.v tb/uart_loopback_tb.v
vsim -c uart_loopback_tb -do "run -all; quit -f"
```

Later commits follow the progression from Verilog into SystemVerilog and reusable verification.
