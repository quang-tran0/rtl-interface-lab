`timescale 1ns/1ps

module i2c_ack_tb;

    reg        clk;
    reg        reset_n;
    reg        start;
    reg  [7:0] data_in;
    reg        slave_low;
    wire       half_tick;
    wire       scl;
    wire       sda;
    wire       busy;
    wire       done;
    wire       ack_error;

    pullup(sda);
    assign sda = slave_low ? 1'b0 : 1'bz;

    i2c_clock_divider #(.CLOCKS_PER_HALF(2)) divider (
        .clk(clk),
        .reset_n(reset_n),
        .half_tick(half_tick)
    );

    i2c_master dut (
        .clk(clk),
        .reset_n(reset_n),
        .half_tick(half_tick),
        .start(start),
        .data_in(data_in),
        .scl(scl),
        .sda(sda),
        .busy(busy),
        .done(done),
        .ack_error(ack_error)
    );

    always #5 clk = ~clk;

    initial begin
        clk       = 0;
        reset_n   = 0;
        start     = 0;
        data_in   = 8'h52;
        slave_low = 0;

        repeat (3) @(posedge clk);
        reset_n = 1;

        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        repeat (8) @(posedge scl);
        @(negedge scl);
        slave_low = 1;
        @(posedge scl);
        #1;
        if (ack_error !== 1'b0) $fatal(1, "ack was missed");
        @(negedge scl);
        slave_low = 0;
        wait (done);

        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        repeat (8) @(posedge scl);
        @(negedge scl);
        @(posedge scl);
        #1;
        if (ack_error !== 1'b1) $fatal(1, "nack was missed");
        wait (done);

        $display("I2C ACK/NACK PASS");
        $finish;
    end

endmodule
