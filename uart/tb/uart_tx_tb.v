`timescale 1ns/1ps

module uart_tx_tb;

    reg        clk;
    reg        reset_n;
    reg        start;
    reg  [7:0] data_in;
    wire       sample_tick;
    wire       tx;
    wire       busy;
    integer    i;

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
        .tx(tx),
        .busy(busy)
    );

    always #5 clk = ~clk;

    initial begin
        clk     = 0;
        reset_n = 0;
        start   = 0;
        data_in = 0;

        repeat (3) @(posedge clk);
        reset_n = 1;

        @(posedge clk);
        data_in = 8'hA5;
        start   = 1;
        @(posedge clk);
        start   = 0;

        @(negedge tx);
        repeat (8) @(posedge sample_tick);
        if (tx !== 1'b0) $fatal(1, "bad start bit");

        for (i = 0; i < 8; i = i + 1) begin
            repeat (16) @(posedge sample_tick);
            if (tx !== data_in[i]) $fatal(1, "bad data bit %0d", i);
        end

        repeat (16) @(posedge sample_tick);
        if (tx !== 1'b1) $fatal(1, "bad stop bit");
        repeat (8) @(posedge sample_tick);
        #1;
        if (busy !== 1'b0) $fatal(1, "busy stayed high");

        $display("UART TX PASS");
        $finish;
    end

endmodule
