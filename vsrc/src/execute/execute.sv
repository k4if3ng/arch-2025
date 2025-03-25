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

    alu alu(
        .srca(dataD.ctl.op inside {AUIPC, BEQ, BNE, BLT, BGE, BLTU, BGEU, JAL} ? dataD.instr.pc : alusrca),
        .srcb(dataD.ctl.is_imm ? dataD.imm : alusrcb),
        .aluop(dataD.ctl.aluop),
        .aluout(aluout)
    );

    always_comb begin
        dataE.ctl = dataD.ctl;
        dataE.dst = dataD.dst;
        dataE.instr = dataD.instr;
        dataE.rd = alusrcb;
        dataE.pcjump = aluout & ~64'b1;
        if (dataD.ctl.op inside {ADDW, SUBW, ADDIW, SLLW, SRLW, SRAW, SLLIW, SRLIW, SRAIW}) begin
            dataE.aluout = {{32{aluout[31]}}, aluout[31:0]};
        end else if (dataD.ctl.op inside {JAL, JALR }) begin
            dataE.aluout = dataD.instr.pc + 4;
        end else begin
            dataE.aluout = aluout;
        end
        case (dataD.ctl.op)
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
            default:begin
                dataE.ctl.branch = 0;
            end
        endcase
    end

endmodule

`endif