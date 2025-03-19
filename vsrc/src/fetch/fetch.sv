`ifndef __FETCH_SV
`define __FETCH_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif 

module fetch 
    import common::*;
    import pipes::*;(
    input  word_t       pc,
    input  ibus_resp_t  iresp,
    output ibus_req_t   ireq,
    output fetch_data_t dataF
);

    assign ireq.addr  = pc;
    assign ireq.valid = 1'b1;
    assign dataF.instr.pc = pc;
    assign dataF.instr.raw_instr = iresp.data;

endmodule

`endif