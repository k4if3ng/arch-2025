`ifndef __EXECUTE_SV
`define __EXECUTE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "src/alu.sv"
`endif

module execute
    import common::*;
    import pipes::*;(
    input  decode_data_t    dataD,
    output exec_data_t      dataE
);

    alu alu(
        .srca(dataD.srca),
        .srcb(dataD.ctl.alusrc ? dataD.imm : dataD.srcb),
        .aluop(dataD.ctl.aluop),
        .aluout(dataE.aluout)
    );

    assign dataE.dst = dataD.dst;
    assign dataE.ctl = dataD.ctl;
    assign dataE.instr = dataD.instr;


endmodule

`endif