`ifndef __DECODE_SV
`define __DECODE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "include/csr.sv"
`include "src/decode/decoder.sv"
`else

`endif

module decode
    import common::*;
    import pipes::*;
    import csr_pkg::*;(
    input  fetch_data_t  dataF,
    output decode_data_t dataD,

    output creg_addr_t  ra1, 
    output creg_addr_t  ra2,
    input  word_t       rd1, 
    input  word_t       rd2,

    output csr_addr_t   csr_raddr,
    input  word_t       csr_data
);

    control_t ctl;
    u64 imm;

    decoder decoder(
        .raw_instr(dataF.instr.raw_instr),
        .imm(imm),
        .ctl(ctl)
    );

    assign dataD.ctl = ctl;
    assign dataD.dst = dataF.instr.raw_instr[11:7];
    assign dataD.instr = dataF.instr;
    assign dataD.imm = imm;
    assign ra1 = dataF.instr.raw_instr[19:15];
    assign ra2 = dataF.instr.raw_instr[24:20];
    assign dataD.rs1 = dataF.instr.raw_instr[19:15];
    assign dataD.rs2 = dataF.instr.raw_instr[24:20];
    assign dataD.srca = rd1;
    assign dataD.srcb = rd2;
    assign csr_raddr = ctl.op == ECALL ? CSR_MTVEC : dataF.instr.raw_instr[31:20];
    assign dataD.csr_waddr = ctl.op == ECALL ? CSR_MEPC : dataF.instr.raw_instr[31:20];
    assign dataD.csr_data = ctl.op == ECALL ? dataF.instr.pc : csr_data;

endmodule

`endif