`ifndef __EX_MEM_REG_SV
`define __EX_MEM_REG_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module ex_mem_reg
    import common::*;
    import pipes::*;(
    input  logic        clk, reset,
    input  exec_data_t  dataE_nxt,
    input  logic        flush, stall,
    output exec_data_t  dataE
);

    always_ff @(posedge clk) begin
        if (reset | flush) begin
            dataE <= '0;
        end else if (~stall) begin
            dataE <= dataE_nxt;
        end
    end

endmodule

`endif
