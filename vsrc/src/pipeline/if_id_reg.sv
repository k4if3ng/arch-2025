`ifndef __if_id_reg_SV
`define __if_id_reg_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module if_id_reg
    import common::*;
    import pipes::*;(
    input  logic        clk, reset,
    input  fetch_data_t dataF_new,
    input  logic        enable, flush, stall,
    output fetch_data_t dataF
);

    always_ff @( posedge clk ) begin
        if (reset | flush) begin
            dataF <= '0;
        end else if (~stall) begin
            dataF <= dataF_new;
        end
    end

endmodule

`endif