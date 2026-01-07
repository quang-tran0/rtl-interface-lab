module uart_tx #(
    parameter TICKS_PER_BIT = 16
) (
    input  logic       clk,
    input  logic       reset_n,
    input  logic       sample_tick,
    input  logic       start,
    input  logic [7:0] data_in,
    output logic       tx,
    output logic       busy
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
            tx         <= 1'b1;
            busy       <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    tx   <= 1'b1;
                    busy <= 1'b0;
                    if (start) begin
                        data_reg   <= data_in;
                        tick_count <= 0;
                        tx         <= 1'b0;
                        busy       <= 1'b1;
                        state      <= START;
                    end
                end

                START: if (sample_tick) begin
                    if (tick_count == TICKS_PER_BIT - 1) begin
                        tick_count <= 0;
                        bit_count  <= 0;
                        tx         <= data_reg[0];
                        state      <= DATA;
                    end else begin
                        tick_count <= tick_count + 1'b1;
                    end
                end

                DATA: if (sample_tick) begin
                    if (tick_count == TICKS_PER_BIT - 1) begin
                        tick_count <= 0;
                        if (bit_count == 7) begin
                            tx    <= 1'b1;
                            state <= STOP;
                        end else begin
                            bit_count <= bit_count + 1'b1;
                            tx        <= data_reg[bit_count + 1'b1];
                        end
                    end else begin
                        tick_count <= tick_count + 1'b1;
                    end
                end

                STOP: if (sample_tick) begin
                    if (tick_count == TICKS_PER_BIT - 1) begin
                        tick_count <= 0;
                        busy       <= 1'b0;
                        state      <= IDLE;
                    end else begin
                        tick_count <= tick_count + 1'b1;
                    end
                end
            endcase
        end
    end

endmodule
