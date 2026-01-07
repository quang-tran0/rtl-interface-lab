module uart_rx #(
    parameter TICKS_PER_BIT = 16
) (
    input  logic       clk,
    input  logic       reset_n,
    input  logic       sample_tick,
    input  logic       rx,
    output logic [7:0] data_out,
    output logic       data_valid
);

    typedef enum logic [1:0] {IDLE, START, DATA, STOP} state_t;
    state_t state;
    logic [3:0] tick_count;
    logic [2:0] bit_count;
    logic [7:0] data_reg;

    always_ff @(posedge clk or negedge reset_n) begin
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
