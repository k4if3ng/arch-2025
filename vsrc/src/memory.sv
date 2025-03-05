`ifndef __MEMORY_SV
`define __MEMORY_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module memory
    import common::*;
    import pipes::*;(
    input  exec_data_t  dataE,
    input  word_t       memout,
    output mem_data_t   dataM
);

    always_comb begin
        dataM.ctl = dataE.ctl;
        dataM.dst = dataE.dst;
        dataM.instr = dataE.instr;
        dataM.writedata = dataE.ctl.mem_to_reg ? memout : dataE.aluout;
    end

endmodule
`endif