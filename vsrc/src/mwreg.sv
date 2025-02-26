`ifndef __MWBREG_SV
`define __MWBREG_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module mwreg
    import common::*;
    import pipes::*;(
    input  logic        clk, reset,
    input  mem_data_t dataM_new,
    input  logic        enable, flush,
    output mem_data_t dataM
);

    always_ff @(posedge clk) begin
        if (reset | flush) begin
            dataM <= '0;
        end else if (enable) begin
            dataM <= dataM_new;
        end
    end

endmodule

`endif
