# RTL Interface Lab

Small protocol exercises built while learning RTL design.

## Protocols

- UART: fixed 8-N-1 transmit and receive
- I2C: one-byte master write with ACK/NACK
- SPI: 8-bit master supporting modes 0 through 3

![UART, I2C, and SPI connections](assets/serial_interfaces.png)

## Layout

Each protocol currently keeps hand-written RTL in `rtl/` and directed tests in `tb/`.

## Simulation

Run all QuestaSim tests for each protocol with:

```sh
make -C uart/sim all
make -C i2c/sim all
make -C spi/sim all
```
