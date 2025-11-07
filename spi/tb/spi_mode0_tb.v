`timescale 1ns/1ps

module spi_mode0_tb;

    reg        clk;
    reg        reset_n;
    reg        start;
    reg  [7:0] tx_data;
    wire       sclk;
    wire       mosi;
    wire       miso;
    wire       cs_n;
    wire [7:0] rx_data;
    wire       busy;
    wire       done;

    assign miso = mosi;

    spi_master #(.CLOCK_DIVIDER(2)) dut (
        .clk(clk),
        .reset_n(reset_n),
        .start(start),
        .tx_data(tx_data),
        .miso(miso),
        .sclk(sclk),
        .mosi(mosi),
        .cs_n(cs_n),
        .rx_data(rx_data),
        .busy(busy),
        .done(done)
    );

    always #5 clk = ~clk;

    initial begin
        clk     = 0;
        reset_n = 0;
        start   = 0;
        tx_data = 8'h96;

        repeat (3) @(posedge clk);
        reset_n = 1;
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;

        wait (done);
        #1;
        if (rx_data !== tx_data)
            $fatal(1, "received %02h expected %02h", rx_data, tx_data);
        if (cs_n !== 1'b1 || sclk !== 1'b0)
            $fatal(1, "spi bus did not return idle");

        $display("SPI MODE 0 PASS");
        $finish;
    end

endmodule
