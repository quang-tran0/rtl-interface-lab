module spi_master #(
    parameter CLOCK_DIVIDER = 2
) (
    input  wire       clk,
    input  wire       reset_n,
    input  wire       start,
    input  wire [7:0] tx_data,
    input  wire       miso,
    output reg        sclk,
    output reg        mosi,
    output reg        cs_n,
    output reg  [7:0] rx_data,
    output reg        busy,
    output reg        done
);

    integer    clock_count;
    reg [2:0]  bit_count;
    reg [7:0]  tx_reg;
    reg [7:0]  rx_reg;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            clock_count <= 0;
            bit_count   <= 0;
            tx_reg      <= 0;
            rx_reg      <= 0;
            rx_data     <= 0;
            sclk        <= 1'b0;
            mosi        <= 1'b0;
            cs_n        <= 1'b1;
            busy        <= 1'b0;
            done        <= 1'b0;
        end else begin
            done <= 1'b0;
            if (!busy) begin
                sclk <= 1'b0;
                cs_n <= 1'b1;
                if (start) begin
                    tx_reg      <= tx_data;
                    bit_count   <= 3'd7;
                    clock_count <= 0;
                    mosi        <= tx_data[7];
                    cs_n        <= 1'b0;
                    busy        <= 1'b1;
                end
            end else if (clock_count == CLOCK_DIVIDER - 1) begin
                clock_count <= 0;
                if (!sclk) begin
                    // sample rx bit
                    sclk              <= 1'b1;
                    rx_reg[bit_count] <= miso;
                end else begin
                    sclk <= 1'b0;
                    if (bit_count == 0) begin
                        rx_data <= rx_reg;
                        cs_n    <= 1'b1;
                        busy    <= 1'b0;
                        done    <= 1'b1;
                    end else begin
                        bit_count <= bit_count - 1'b1;
                        mosi      <= tx_reg[bit_count - 1'b1];
                    end
                end
            end else begin
                clock_count <= clock_count + 1;
            end
        end
    end

endmodule
