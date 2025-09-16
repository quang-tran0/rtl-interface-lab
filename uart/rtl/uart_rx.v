module uart_rx #(
    parameter TICKS_PER_BIT = 16
) (
    input  wire       clk,
    input  wire       reset_n,
    input  wire       sample_tick,
    input  wire       rx,
    output reg  [7:0] data_out,
    output reg        data_valid
);

    reg [1:0] state;
    reg [3:0] tick_count;
    reg [2:0] bit_count;
    reg [7:0] data_reg;

    localparam IDLE  = 2'd0;
    localparam START = 2'd1;
    localparam DATA  = 2'd2;
    localparam STOP  = 2'd3;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state      <= IDLE;
            tick_count <= 0;
            bit_count  <= 0;
            data_reg   <= 0;
            data_out   <= 0;
            data_valid <= 1'b0;
        end else begin
            data_valid <= 1'b0;
            case (state)
                IDLE: begin
                    tick_count <= 0;
                    if (!rx)
                        state <= START;
                end

                START: if (sample_tick) begin
                    if (tick_count == (TICKS_PER_BIT / 2) - 1) begin
                        tick_count <= 0;
                        bit_count  <= 0;
                        if (!rx)
                            state <= DATA;
                        else
                            state <= IDLE;
                    end else begin
                        tick_count <= tick_count + 1'b1;
                    end
                end

                DATA: if (sample_tick) begin
                    if (tick_count == TICKS_PER_BIT - 1) begin
                        tick_count          <= 0;
                        data_reg[bit_count] <= rx;
                        if (bit_count == 7) begin
                            state <= STOP;
                        end else begin
                            bit_count <= bit_count + 1'b1;
                        end
                    end else begin
                        tick_count <= tick_count + 1'b1;
                    end
                end

                STOP: if (sample_tick) begin
                    if (tick_count == TICKS_PER_BIT - 1) begin
                        tick_count <= 0;
                        if (rx) begin
                            data_out   <= data_reg;
                            data_valid <= 1'b1;
                        end
                        state <= IDLE;
                    end else begin
                        tick_count <= tick_count + 1'b1;
                    end
                end
            endcase
        end
    end

endmodule
