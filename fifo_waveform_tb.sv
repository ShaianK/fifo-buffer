`timescale 1ns / 1ps

module fifo_waveform_tb;
    parameter DEPTH = 32;
    parameter WIDTH = 8;

    logic clk, reset_n, write_en, read_en;
    logic [WIDTH-1:0] data_in, data_out;
    logic full, empty, almost_full, almost_empty;

    // DUT
    FIFO #(
        .DEPTH(DEPTH),
        .WIDTH(WIDTH)
    ) dut (
        .clk(clk), 
        .reset_n(reset_n),
        .write_en(write_en), 
        .read_en(read_en), 
        .data_in(data_in),
        .data_out(data_out),
        .full(full), 
        .empty(empty),
        .almost_full(almost_full), 
        .almost_empty(almost_empty)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
      	$dumpfile("fifo_waveform_tb.vcd"); 
      	$dumpvars;
        
        clk = 0;
        reset_n = 0;
        write_en = 0;
        read_en = 0;
        data_in = 0;

        // Reset
        @(posedge clk);
        reset_n = 1;

        // Write 4 values
        repeat(4) begin
            @(posedge clk);
            write_en = 1;
            data_in = $random;
        end
        write_en = 0;

        // Read 4 values
        repeat(4) begin
            @(posedge clk);
            read_en = 1;
        end
        read_en = 0;

        // Idle and end
        repeat(2) @(posedge clk);
        $finish;
    end

endmodule