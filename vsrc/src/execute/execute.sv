`ifndef __EXECUTE_SV
`define __EXECUTE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "src//execute/alu.sv"
`endif

module execute
    import common::*;
    import pipes::*;(
    input  word_t           alusrca, 
    input  word_t           alusrcb,
    input  decode_data_t    dataD,
    output exec_data_t      dataE
);

    word_t aluout;

    word_t srca, srcb;

    assign srca = dataD.ctl.op inside {AUIPC, BEQ, BNE, BLT, BGE, BLTU, BGEU, JAL} ? dataD.instr.pc : alusrca;
    assign srcb = dataD.ctl.is_imm ? dataD.imm : alusrcb;

    alu alu(
        .srca(srca),
        .srcb(srcb),
        .aluop(dataD.ctl.aluop),
        .aluout(aluout)
    );

    always_comb begin
        dataE.ctl = dataD.ctl;
        dataE.dst = dataD.dst;
        dataE.instr = dataD.instr;
        dataE.rd = alusrcb;
        dataE.pcjump = aluout & ~64'b1;
        dataE.ctl.branch = 0;
        dataE.csr_addr = dataD.csr_addr;
        dataE.csr_data = 0;
        dataE.aluout = aluout;
        

        unique case (dataD.ctl.op)
            ADDW, SUBW, ADDIW, SLLW, SRLW, SRAW, SLLIW, SRLIW, SRAIW:begin
                dataE.aluout = {{32{aluout[31]}}, aluout[31:0]};
            end
            JAL, JALR:begin
                dataE.aluout = dataD.instr.pc + 4;
            end
            BEQ:begin
                dataE.ctl.branch = alusrca == alusrcb;
            end
            BNE:begin
                dataE.ctl.branch = alusrca != alusrcb;
            end
            BLT:begin
                dataE.ctl.branch = signed'(alusrca) < signed'(alusrcb);
            end
            BGE:begin
                dataE.ctl.branch = signed'(alusrca) >= signed'(alusrcb);
            end
            BLTU:begin
                dataE.ctl.branch = alusrca < alusrcb;
            end
            BGEU:begin
                dataE.ctl.branch = alusrca >= alusrcb;
            end

            // csr
            CSRRW:begin
                dataE.aluout = dataD.csr_data;
                dataE.csr_data = srca;
            end
            CSRRS:begin
                dataE.aluout = dataD.csr_data;
                dataE.csr_data = srca | dataD.csr_data;
            end
            CSRRC:begin
                dataE.aluout = dataD.csr_data;
                dataE.csr_data = ~srca & dataD.csr_data;
            end
            CSRRWI:begin
                dataE.aluout = dataD.csr_data;
                dataE.csr_data = srcb;
            end
            CSRRSI:begin
                dataE.aluout = dataD.csr_data;
                dataE.csr_data = srcb | dataD.csr_data;
            end
            CSRRCI:begin
                dataE.aluout = dataD.csr_data;
                dataE.csr_data = ~srcb & dataD.csr_data;
            end
            default:begin
                dataE.ctl.branch = 0;
                dataE.csr_data = 0;
                dataE.aluout = aluout;
            end
        endcase
    end

endmodule

`endif