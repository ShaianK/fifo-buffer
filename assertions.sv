module fifo_assertions #(
    parameter DEPTH = 32,
    parameter WIDTH = 8,
    parameter POINTER_WIDTH = $clog2(DEPTH)
)
(
    input logic clk, reset_n,
    input logic write_en, read_en,
    input logic full, empty,
    input logic [POINTER_WIDTH:0] count
);

    // No overflow
    property no_overflow;
        @(posedge clk) disable iff (!reset_n)
        !(write_en && full);
    endproperty
    assert property(no_overflow) else $error("FIFO overflow detected!");

    // No underflow
    property no_underflow;
        @(posedge clk) disable iff (!reset_n)
        !(read_en && empty);
    endproperty
    assert property(no_underflow) else $error("FIFO underflow detected!");

    // Count bounds
    property count_within_bounds;
        @(posedge clk) disable iff (!reset_n)
        count <= DEPTH;
    endproperty
    assert property(count_within_bounds) else $error("FIFO count out of bounds!");

endmodule