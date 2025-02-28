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
    input  word_t       aluout,
    output mem_data_t   dataM
);

    always_comb begin
        dataM.ctl = dataE.ctl;
        dataM.rs1 = dataE.rs1;
        dataM.rs2 = dataE.rs2;
        dataM.dst = dataE.dst;
        dataM.instr = dataE.instr;
        dataM.writedata = dataE.ctl.mem_to_reg ? memout : aluout;
    end


endmodule
`endif