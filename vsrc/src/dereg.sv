`ifndef __DEREG_SV
`define __DEREG_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module dereg
    import common::*;
    import pipes::*;(
    input  logic        clk, reset,
    input  decode_data_t dataD_new,
    input  logic        enable, flush,
    output decode_data_t dataD
);

    always_ff @(posedge clk) begin
        if (reset | flush) begin
            dataD <= '0;
        end else if (enable) begin
            dataD <= dataD_new;
        end
    end

endmodule

`endif
