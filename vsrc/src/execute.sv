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

    word_t aluout;

    alu alu(
        .srca(dataD.srca),
        .srcb(dataD.ctl.alusrc ? dataD.imm : dataD.srcb),
        .aluop(dataD.ctl.aluop),
        .aluout(aluout)
    );

    assign dataE.dst = dataD.dst;
    assign dataE.ctl = dataD.ctl;
    assign dataE.instr = dataD.instr;
    assign dataE.aluout = dataD.ctl.is_word ? aluout : {{32{aluout[31]}}, aluout[31:0]};


endmodule

`endif