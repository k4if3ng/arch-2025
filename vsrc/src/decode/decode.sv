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
    input  word_t       csr_data,

    input  excep_data_t excep_rdata
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
    assign csr_raddr = dataF.instr.raw_instr[31:20];
    assign dataD.csr_waddr = dataF.instr.raw_instr[31:20];
    assign dataD.csr_data = csr_data;
    assign dataD.excep_wdata.mstatus = excep_rdata.mstatus;
    assign dataD.excep_wdata.mtvec = excep_rdata.mtvec;
    assign dataD.excep_wdata.mepc = excep_rdata.mepc;
    assign dataD.excep_wdata.mcause = 0;
    assign dataD.excep_wdata.mtval = 0;
    assign dataD.excep_wdata.csrop = ctl.op == MRET ? CSR_OP_MRET :
                                    ctl.op == ECALL ? CSR_OP_ECALL :
                                    ctl.op == EBREAK ? CSR_OP_EBREAK :
                                    CSR_OP_NONE;

endmodule

`endif