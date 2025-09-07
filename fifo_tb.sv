`timescale 1ns / 1ps

`include "scoreboard.sv"
`include "assertions.sv"

module fifo_tb;
    parameter DEPTH = 32;
    parameter WIDTH = 8;

    logic clk, reset_n, write_en, read_en;
    logic [WIDTH-1:0] data_in, data_out;
    logic full, empty, almost_full, almost_empty;
    int num_tests = 50;

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

    fifo_assertions #(
        .DEPTH(DEPTH)
    ) sva (
        .clk(clk),
        .reset_n(reset_n),
        .write_en(write_en),
        .read_en(read_en),
        .full(full),
        .empty(empty),
        .count(dut.count)
    );

    Scoreboard sb = new();

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset_n = 0;
        write_en = 0;
        read_en = 0;
        data_in = 0;

        repeat(5) @(posedge clk);
        reset_n = 1;

        // Random Test
        for (int i = 0; i < num_tests; i++) begin
            @(posedge clk);
            write_en = $urandom_range(0,1);
            read_en = $urandom_range(0,1);
            data_in = $urandom_range(0, 2**WIDTH-1);

            if (write_en && !full)
                sb.write(data_in);

            if (read_en && !empty) begin
                bit [7:0] expected = sb.read();
                if (data_out !== expected) begin
                    $error("Mismatch: expected %0h, got %0h at cycle %0d", expected, data_out, i);
                end
            end
        end


        // Edge case tests
        $display("===Starting edge-case tests===");
        
        // Overflow attempt
        repeat(DEPTH) begin
            @(posedge clk);
            write_en = 1; data_in = $urandom();
        end
        @(posedge clk) write_en = 1;

        // Underflow attempt
        repeat(DEPTH) begin
            @(posedge clk);
            read_en = 1;
        end
        @(posedge clk) read_en = 1;

        $display("===All tests completed===");
        $finish;
    end

endmodule