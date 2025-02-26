`ifndef __EMMREG_SV
`define __EMMREG_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module emreg
    import common::*;
    import pipes::*;(
    input  logic        clk, reset,
    input  exec_data_t dataE_new,
    input  logic        enable, flush,
    output exec_data_t dataE
);

    always_ff @(posedge clk) begin
        if (reset | flush) begin
            dataE <= '0;
        end else if (enable) begin
            dataE <= dataE_new;
        end
    end

endmodule

`endif
