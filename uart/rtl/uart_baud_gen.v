module uart_baud_gen #(
    parameter CLOCKS_PER_TICK = 27
) (
    input  wire clk,
    input  wire reset_n,
    output reg  sample_tick
);

    integer count;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            count       <= 0;
            sample_tick <= 1'b0;
        end else if (count == CLOCKS_PER_TICK - 1) begin
            count       <= 0;
            sample_tick <= 1'b1;
        end else begin
            count       <= count + 1;
            sample_tick <= 1'b0;
        end
    end

endmodule
