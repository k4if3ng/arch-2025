`ifndef __FETCH_SV
`define __FETHC_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif 

module fetch 
    import common::*;
    import pipes::*;(

    input u32 raw_instr,
    output fetch_data_t dataF
);

    assign dataF.raw_instr = raw_instr;

endmodule

`endif