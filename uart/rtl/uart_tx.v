module uart_tx #(
    parameter TICKS_PER_BIT = 16
) (
    input  wire       clk,
    input  wire       reset_n,
    input  wire       sample_tick,
    input  wire       start,
    input  wire [7:0] data_in,
    output reg        tx,
    output reg        busy
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
