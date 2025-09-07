`timescale 1ns / 1ps

module FIFO #(
    parameter DEPTH = 32,
    parameter WIDTH = 8,
    parameter ALMOST_FULL_LEVEL = DEPTH-4,
    parameter ALMOST_EMPTY_LEVEL = 4
)
(
    input  logic              clk,
    input  logic              reset_n,
    input  logic              write_en,
    input  logic [WIDTH-1:0]  data_in,
    input  logic              read_en,
    output logic [WIDTH-1:0]  data_out,
    output logic              full,
    output logic              empty,
    output logic              almost_full, // "early warning"
    output logic              almost_empty
);

    localparam PTR_WIDTH = $clog2(DEPTH);

    logic [WIDTH-1:0] mem [0:DEPTH-1];
    logic [PTR_WIDTH:0] write_ptr, read_ptr;
    logic [PTR_WIDTH:0] count;

    // Write
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            write_ptr <= 0;
        end 
        else if(write_en && !full) begin // Never write to full FIFO
            mem[write_ptr[PTR_WIDTH-1:0]] <= data_in;
            write_ptr <= write_ptr + 1;
        end
    end

    // Read
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            read_ptr <= 0;
            data_out <= 0;
        end 
        else if(read_en && !empty) begin // Never read from empty FIFO
            data_out   <= mem[read_ptr[PTR_WIDTH-1:0]];
            read_ptr <= read_ptr + 1;
        end
    end

    // Count
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            count <= 0;
        end else begin
            case ({write_en && !full, read_en && !empty})
                2'b10: count <= count + 1;
                2'b01: count <= count - 1;
                default: count <= count;
            endcase
        end
    end

    assign full = (count == DEPTH);
    assign empty = (count == 0);
    assign almost_full = (count >= ALMOST_FULL_LEVEL);
    assign almost_empty = (count <= ALMOST_EMPTY_LEVEL);

endmodule