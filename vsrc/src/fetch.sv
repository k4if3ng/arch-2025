`ifndef __FETCH_SV
`define __FETCH_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif 

module fetch 
    import common::*;
    import pipes::*;(
    input  word_t   pc,
    input  u32      raw_instr,
    output fetch_data_t dataF
);

    assign dataF.instr.pc = pc;
    assign dataF.instr.raw_instr = raw_instr;

endmodule

`endif