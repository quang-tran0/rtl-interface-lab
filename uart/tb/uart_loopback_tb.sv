`timescale 1ns/1ps

module uart_loopback_tb;

    logic       clk;
    logic       reset_n;
    logic       start;
    logic [7:0] data_in;
    logic       sample_tick;
    logic       serial;
    logic       busy;
    logic [7:0] data_out;
    logic       data_valid;

    uart_baud_gen #(.CLOCKS_PER_TICK(2)) baud_gen (
        .clk(clk),
        .reset_n(reset_n),
        .sample_tick(sample_tick)
    );

    uart_tx tx_dut (
        .clk(clk),
        .reset_n(reset_n),
        .sample_tick(sample_tick),
        .start(start),
        .data_in(data_in),
        .tx(serial),
        .busy(busy)
    );

    uart_rx rx_dut (
        .clk(clk),
        .reset_n(reset_n),
        .sample_tick(sample_tick),
        .rx(serial),
        .data_out(data_out),
        .data_valid(data_valid)
    );

    always #5 clk = ~clk;

    initial begin
        clk     = 0;
        reset_n = 0;
        start   = 0;
        data_in = 8'h5A;

        repeat (3) @(posedge clk);
        reset_n = 1;
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;

        wait (data_valid);
        #1;
        if (data_out !== data_in)
            $fatal(1, "loopback received %02h expected %02h", data_out, data_in);

        $display("UART LOOPBACK PASS");
        $finish;
    end

endmodule
