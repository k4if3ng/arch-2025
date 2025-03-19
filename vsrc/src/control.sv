`ifndef __CONTROL_SV
`define __CONTROL_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module control
    import common::*;
    import pipes::*;(
);


endmodule
`endif