`ifndef __EMMREG_SV
`define __EMMREG_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module ex_mem_reg
    import common::*;
    import pipes::*;(
    input  logic        clk, reset,
    input  exec_data_t  dataE_nxt,
    input  logic        enable, flush, stall,
    output exec_data_t  dataE
);

    always_ff @(posedge clk) begin
        if (reset | flush) begin
            dataE <= '0;
        end else if (stall) begin
            dataE <= dataE;
        end else if (enable) begin
            dataE <= dataE_nxt;
        end
    end

endmodule

`endif
