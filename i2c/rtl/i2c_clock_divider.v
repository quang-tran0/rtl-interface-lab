module i2c_clock_divider #(
    parameter CLOCKS_PER_HALF = 250
) (
    input  wire clk,
    input  wire reset_n,
    output reg  half_tick
);

    integer count;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            count     <= 0;
            half_tick <= 1'b0;
        end else if (count == CLOCKS_PER_HALF - 1) begin
            count     <= 0;
            half_tick <= 1'b1;
        end else begin
            count     <= count + 1;
            half_tick <= 1'b0;
        end
    end

endmodule
