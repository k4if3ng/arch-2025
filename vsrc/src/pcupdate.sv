`ifndef __PCUPDATE_SV
`define __PCUPDATE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module pcupdate
    import common::*;
    import pipes::*;(
    input  logic        clk, reset,
    input  logic        stall,
    input  word_t       pc_nxt,
    output word_t       pc
);

    always_ff @(posedge clk) begin
        if (reset) begin
            pc <= PCINIT;
        end else if (stall) begin
            pc <= pc;
        end else begin
            pc <= pc_nxt;
        end
    end

endmodule
`endif