`ifndef __PCSELECT_SV
`define __PCSELECT_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif 

module pcselect 
    import common::*;
    import pipes::*;(
    input u64 pcplus4,
    output u64 pc_selected
);

    assign pc_selected = pcplus4;

endmodule
`endif