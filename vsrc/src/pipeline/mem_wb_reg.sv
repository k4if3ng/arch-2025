`ifndef __MEM_WB_REG_SV
`define __MEM_WB_REG_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module mem_wb_reg
    import common::*;
    import pipes::*;(
    input  logic        clk, reset,
    input  mem_data_t   dataM_nxt,
    input  logic        flushM, stallM,
    output mem_data_t   dataM
);

    always_ff @(posedge clk) begin
        if (reset | flushM) begin
            dataM <= '0;
        end else if (~stallM) begin
            dataM <= dataM_nxt;
        end
    end

endmodule

`endif
