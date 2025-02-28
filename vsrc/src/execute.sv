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
    // input  word_t           alusrca, alusrcb,
    input  decode_data_t    dataD,
    // input  u1               is_word,
    output exec_data_t      dataE
);

    word_t aluout;

    alu alu(
        .srca(dataD.srca),
        .srcb(dataD.ctl.alusrc ? dataD.imm : dataD.srcb),
        .aluop(dataD.ctl.aluop),
        .aluout(aluout)
    );

    // assign dataE.dst = dataD.dst;
    // assign dataE.rs1 = dataD.rs1;
    // assign dataE.rs2 = dataD.rs2;
    // assign dataE.ctl = dataD.ctl;
    // assign dataE.instr = dataD.instr;
    // assign dataE.aluout = dataD.ctl.is_word ? aluout : {{32{aluout[31]}}, aluout[31:0]};

    always_comb begin
        dataE.dst = dataD.dst;
        dataE.rs1 = dataD.rs1;
        dataE.rs2 = dataD.rs2;
        dataE.ctl = dataD.ctl;
        dataE.instr = dataD.instr;
        dataE.aluout = ~dataD.ctl.is_word ? aluout : {{32{aluout[31]}}, aluout[31:0]};
    end

endmodule

`endif