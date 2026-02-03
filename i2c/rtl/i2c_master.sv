module i2c_master (
    input  logic       clk,
    input  logic       reset_n,
    input  logic       half_tick,
    input  logic       start,
    input  logic [7:0] data_in,
    output logic       scl,
    inout  wire sda,
    output logic busy,
    output logic done,
    output logic ack_error
);

    typedef enum logic [3:0] {
        IDLE, START, BIT_HIGH, BIT_LOW, ACK_LOW,
        ACK_HIGH, STOP_LOW, STOP_HIGH, STOP_RELEASE
    } state_t;

    state_t state;
    logic       sda_low;
    logic [7:0] data_reg;
    logic [2:0] bit_count;

    assign sda = sda_low ? 1'b0 : 1'bz;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state   <= IDLE;
            scl     <= 1'b1;
            sda_low <= 1'b0;
            data_reg <= 0;
            bit_count <= 0;
            busy    <= 1'b0;
            done    <= 1'b0;
            ack_error <= 1'b0;
        end else begin
            done <= 1'b0;
            case (state)
                IDLE: if (start) begin
                    // start while scl is high
                    sda_low <= 1'b1;
                    data_reg <= data_in;
                    busy    <= 1'b1;
                    ack_error <= 1'b0;
                    state   <= START;
                end

                START: if (half_tick) begin
                    scl       <= 1'b0;
                    bit_count <= 3'd7;
                    sda_low   <= ~data_reg[7];
                    state     <= BIT_HIGH;
                end

                BIT_HIGH: if (half_tick) begin
                    scl <= 1'b1;
                    if (bit_count == 0)
                        state <= ACK_LOW;
                    else begin
                        bit_count <= bit_count - 1'b1;
                        state     <= BIT_LOW;
                    end
                end

                BIT_LOW: if (half_tick) begin
                    scl     <= 1'b0;
                    sda_low <= ~data_reg[bit_count];
                    state   <= BIT_HIGH;
                end

                ACK_LOW: if (half_tick) begin
                    // wait for ack
                    scl     <= 1'b0;
                    sda_low <= 1'b0;
                    state   <= ACK_HIGH;
                end

                ACK_HIGH: if (half_tick) begin
                    scl       <= 1'b1;
                    ack_error <= sda;
                    state     <= STOP_LOW;
                end

                STOP_LOW: if (half_tick) begin
                    sda_low <= 1'b1;
                    scl     <= 1'b0;
                    state   <= STOP_HIGH;
                end

                STOP_HIGH: if (half_tick) begin
                    scl   <= 1'b1;
                    state <= STOP_RELEASE;
                end

                STOP_RELEASE: if (half_tick) begin
                    sda_low <= 1'b0;
                    busy    <= 1'b0;
                    done    <= 1'b1;
                    state   <= IDLE;
                end
            endcase
        end
    end

endmodule
