`ifndef __id_ex_reg_SV
`define __id_ex_reg_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module id_ex_reg
    import common::*;
    import pipes::*;(
    input  logic            clk, reset,
    input  decode_data_t    dataD_nxt,
    input  logic            flushD, stallD,
    output decode_data_t    dataD
);

    always_ff @(posedge clk) begin
        if (reset | flushD) begin
            dataD <= '0;
        end else if (~stallD) begin
            dataD <= dataD_nxt;
        end
    end

endmodule

`endif
