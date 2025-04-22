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
    input  u1           flushpc,
    input  ibus_resp_t  iresp,
    output ibus_req_t   ireq,
    output fetch_data_t dataF
);

    assign ireq.addr  = pc;
    assign ireq.valid = 1'b1;
    assign dataF.instr.pc = flushpc ? 0 : pc;
    assign dataF.instr.raw_instr = flushpc ? 0 : iresp.data;

endmodule

`endif