module i2c_master (
    input  wire clk,
    input  wire reset_n,
    input  wire half_tick,
    input  wire start,
    output reg  scl,
    inout  wire sda,
    output reg  busy,
    output reg  done
);

    reg [2:0] state;
    reg       sda_low;

    localparam IDLE         = 3'd0;
    localparam START        = 3'd1;
    localparam STOP_LOW     = 3'd2;
    localparam STOP_HIGH    = 3'd3;
    localparam STOP_RELEASE = 3'd4;

    assign sda = sda_low ? 1'b0 : 1'bz;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state   <= IDLE;
            scl     <= 1'b1;
            sda_low <= 1'b0;
            busy    <= 1'b0;
            done    <= 1'b0;
        end else begin
            done <= 1'b0;
            case (state)
                IDLE: if (start) begin
                    // start while scl is high
                    sda_low <= 1'b1;
                    busy    <= 1'b1;
                    state   <= START;
                end

                START: if (half_tick) begin
                    scl   <= 1'b0;
                    state <= STOP_LOW;
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
