`timescale 1ns/1ps

module uart_rx_tb;

    reg        clk;
    reg        reset_n;
    reg        rx;
    wire       sample_tick;
    wire [7:0] data_out;
    wire       data_valid;
    reg  [7:0] sent_data;
    integer    i;

    uart_baud_gen #(.CLOCKS_PER_TICK(2)) baud_gen (
        .clk(clk),
        .reset_n(reset_n),
        .sample_tick(sample_tick)
    );

    uart_rx rx_dut (
        .clk(clk),
        .reset_n(reset_n),
        .sample_tick(sample_tick),
        .rx(rx),
        .data_out(data_out),
        .data_valid(data_valid)
    );

    always #5 clk = ~clk;

    initial begin
        clk       = 0;
        reset_n   = 0;
        rx        = 1;
        sent_data = 8'h3C;

        repeat (3) @(posedge clk);
        reset_n = 1;
        repeat (2) @(posedge clk);

        // start bit
        rx = 0;
        repeat (16) @(posedge sample_tick);

        for (i = 0; i < 8; i = i + 1) begin
            rx = sent_data[i];
            repeat (16) @(posedge sample_tick);
        end

        // stop bit
        rx = 1;
        wait (data_valid);
        #1;
        if (data_out !== sent_data)
            $fatal(1, "received %02h expected %02h", data_out, sent_data);

        $display("UART RX PASS");
        $finish;
    end

endmodule
