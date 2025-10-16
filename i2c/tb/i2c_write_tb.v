`timescale 1ns/1ps

module i2c_write_tb;

    reg        clk;
    reg        reset_n;
    reg        start;
    reg  [7:0] data_in;
    wire       half_tick;
    wire       scl;
    wire       sda;
    wire       busy;
    wire       done;
    reg  [7:0] seen_data;
    integer    i;

    pullup(sda);

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
        .done(done)
    );

    always #5 clk = ~clk;

    initial begin
        clk       = 0;
        reset_n   = 0;
        start     = 0;
        data_in   = 8'hA6;
        seen_data = 0;

        repeat (3) @(posedge clk);
        reset_n = 1;
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;

        @(negedge sda);
        if (scl !== 1'b1) $fatal(1, "start did not occur while scl high");

        for (i = 7; i >= 0; i = i - 1) begin
            @(posedge scl);
            seen_data[i] = sda;
        end

        wait (done);
        if (seen_data !== data_in)
            $fatal(1, "saw %02h expected %02h", seen_data, data_in);
        if (scl !== 1'b1 || sda !== 1'b1)
            $fatal(1, "bus not idle after stop");

        $display("I2C WRITE PASS");
        $finish;
    end

endmodule
