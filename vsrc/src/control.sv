`ifndef __CONTROL_SV
`define __CONTROL_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module control
    import common::*;
    import pipes::*;(
    input  u1           invalid,
    input  u1           jump,
    input  u1           csr,
    input  u1           load_use_hazard,
    output u1           stallpc, stallF, stallD, stallE, stallM,
    output u1           flushpc, flushF, flushD, flushE, flushM
);
    
    assign stallpc = invalid | load_use_hazard | csr;
    assign stallF = invalid | load_use_hazard;
    assign stallD = invalid | load_use_hazard;
    assign stallE = stallD;
    assign stallM = stallE;
    assign flushpc = csr;
    assign flushF = jump;
    assign flushD = jump;
    assign flushE = 0;
    assign flushM = 0;


endmodule
`endif