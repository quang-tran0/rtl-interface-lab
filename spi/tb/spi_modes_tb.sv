`timescale 1ns/1ps

module spi_modes_tb;

    logic       clk;
    logic       reset_n;
    logic       start;
    logic [7:0] tx_data;
    logic [3:0] sclk;
    logic [3:0] mosi;
    logic [3:0] cs_n;
    logic [3:0] done;
    logic [7:0] rx_data0;
    logic [7:0] rx_data1;
    logic [7:0] rx_data2;
    logic [7:0] rx_data3;

    spi_master #(.CLOCK_DIVIDER(2), .CPOL(0), .CPHA(0)) mode0 (
        .clk(clk), .reset_n(reset_n), .start(start), .tx_data(tx_data),
        .miso(mosi[0]), .sclk(sclk[0]), .mosi(mosi[0]), .cs_n(cs_n[0]),
        .rx_data(rx_data0), .busy(), .done(done[0])
    );

    spi_master #(.CLOCK_DIVIDER(2), .CPOL(0), .CPHA(1)) mode1 (
        .clk(clk), .reset_n(reset_n), .start(start), .tx_data(tx_data),
        .miso(mosi[1]), .sclk(sclk[1]), .mosi(mosi[1]), .cs_n(cs_n[1]),
        .rx_data(rx_data1), .busy(), .done(done[1])
    );

    spi_master #(.CLOCK_DIVIDER(2), .CPOL(1), .CPHA(0)) mode2 (
        .clk(clk), .reset_n(reset_n), .start(start), .tx_data(tx_data),
        .miso(mosi[2]), .sclk(sclk[2]), .mosi(mosi[2]), .cs_n(cs_n[2]),
        .rx_data(rx_data2), .busy(), .done(done[2])
    );

    spi_master #(.CLOCK_DIVIDER(2), .CPOL(1), .CPHA(1)) mode3 (
        .clk(clk), .reset_n(reset_n), .start(start), .tx_data(tx_data),
        .miso(mosi[3]), .sclk(sclk[3]), .mosi(mosi[3]), .cs_n(cs_n[3]),
        .rx_data(rx_data3), .busy(), .done(done[3])
    );

    always #5 clk = ~clk;

    initial begin
        clk     = 0;
        reset_n = 0;
        start   = 0;
        tx_data = 8'hC3;

        repeat (3) @(posedge clk);
        reset_n = 1;
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;

        wait (&done);
        #1;
        if (rx_data0 !== tx_data || rx_data1 !== tx_data ||
            rx_data2 !== tx_data || rx_data3 !== tx_data)
            $fatal(1, "spi mode loopback mismatch");
        if (sclk !== 4'b1100 || cs_n !== 4'b1111)
            $fatal(1, "spi modes did not return idle");

        $display("SPI MODES PASS");
        $finish;
    end

endmodule
