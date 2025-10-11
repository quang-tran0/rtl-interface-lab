module i2c_master (
    input  wire clk,
    input  wire reset_n,
    input  wire half_tick,
    input  wire start,
    input  wire [7:0] data_in,
    output reg  scl,
    inout  wire sda,
    output reg  busy,
    output reg  done
);

    reg [2:0] state;
    reg       sda_low;
    reg [7:0] data_reg;
    reg [2:0] bit_count;

    localparam IDLE         = 3'd0;
    localparam START        = 3'd1;
    localparam BIT_HIGH     = 3'd2;
    localparam BIT_LOW      = 3'd3;
    localparam STOP_LOW     = 3'd4;
    localparam STOP_HIGH    = 3'd5;
    localparam STOP_RELEASE = 3'd6;

    assign sda = sda_low ? 1'b0 : 1'bz;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state   <= IDLE;
            scl     <= 1'b1;
            sda_low <= 1'b0;
            data_reg <= 0;
            bit_count <= 0;
            busy    <= 1'b0;
            done    <= 1'b0;
        end else begin
            done <= 1'b0;
            case (state)
                IDLE: if (start) begin
                    // start while scl is high
                    sda_low <= 1'b1;
                    data_reg <= data_in;
                    busy    <= 1'b1;
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
                        state <= STOP_LOW;
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
