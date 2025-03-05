`ifndef __MWBREG_SV
`define __MWBREG_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module mem_wb_reg
    import common::*;
    import pipes::*;(
    input  logic        clk, reset,
    input  mem_data_t   dataM_nxt,
    input  logic        flush, stall,
    output mem_data_t   dataM
);

    always_ff @(posedge clk) begin
        if (reset | flush) begin
            dataM <= '0;
        end else if (~stall) begin
            dataM <= dataM_nxt;
        end
    end

endmodule

`endif
