`ifndef __DECODE_SV
`define __DECODE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "src/decoder.sv"
`else

`endif

module decode
    import common::*;
    import pipes::*;(
    input  fetch_data_t  dataF,
    output decode_data_t dataD,

    output creg_addr_t  ra1, ra2,
    input word_t       rd1, rd2,

    input u1            fwd_valid_a, fwd_valid_b,
    input word_t        fwd_aluout,

    input u1            fwd_valid_a_, fwd_valid_b_,
    input word_t        fwd_aluout_
);

    control_t ctl;

    decoder decoder(
        .raw_instr(dataF.instr.raw_instr),
        .imm(dataD.imm),
        .ctl(ctl)
    );

    assign dataD.ctl = ctl;
    assign dataD.dst = dataF.instr.raw_instr[11:7];
    assign dataD.instr = dataF.instr;
    assign ra1 = dataF.instr.raw_instr[19:15];
    assign ra2 = dataF.instr.raw_instr[24:20];
    assign dataD.rs1 = dataF.instr.raw_instr[19:15];
    assign dataD.rs2 = dataF.instr.raw_instr[24:20];
    assign dataD.srca = fwd_valid_a ? fwd_aluout : fwd_valid_a_ ? fwd_aluout_ : rd1;
    assign dataD.srcb = fwd_valid_b ? fwd_aluout : fwd_valid_b_ ? fwd_aluout_ : rd2;
    // assign dataD.srca = rd1;
    // assign dataD.srcb = rd2;
    // assign dataD.imm = dataF.instr.raw_instr[31:20];

endmodule

`endif