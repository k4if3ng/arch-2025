`ifndef __DREG_SV
`define __DREG_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module dreg
    import common::*;
    import pipes::*;(
    input  logic        clk, reset,
    input  fetch_data_t dataF_new,
    input  logic        enable, flush,
    output fetch_data_t dataF
);

    always_ff @( posedge clk ) begin
        if (reset | flush) begin
            dataF <= '0;
        end else if (enable) begin
            dataF <= dataF_new;
        end
    end

endmodule

`endif