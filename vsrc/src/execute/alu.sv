`ifndef __ALU_SV
`define __ALU_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module alu
    import common::*;
    import pipes::*;(
    input  word_t      srca, srcb,
    input  alu_op_t    aluop,
    output word_t      aluout
);

    shamt_t shamt;
    assign shamt = srcb[5: 0];

    always_comb begin
        aluout = '0;

        unique case (aluop)
            ALU_ADD: begin
                aluout = srca + srcb;
            end
            ALU_SUB: begin
                aluout = srca - srcb;
            end
            ALU_AND: begin
                aluout = srca & srcb;
            end
            ALU_OR: begin
                aluout = srca | srcb;
            end
            ALU_XOR: begin
                aluout = srca ^ srcb;
            end
            ALU_SLLW: begin
                aluout = {32'b0, {srca[31:0] << shamt[4:0]}};
            end
            ALU_SRLW: begin
                aluout = {32'b0, {srca[31:0] >> shamt[4:0]}};
            end
            ALU_SRAW: begin
                aluout = signed'({{32{srca[31]}}, srca[31:0]}) >>> shamt[4:0];
            end
            ALU_SLL: begin
                aluout = srca << shamt;
            end
            ALU_SRL: begin
                aluout = srca >> shamt;
            end
            ALU_SRA: begin
                aluout = signed'(srca) >>> shamt;
            end
            ALU_SLT: begin
                aluout = (signed'(srca) < signed'(srcb)) ? 64'b1 : 64'b0;
            end
            ALU_SLTU: begin
                aluout = (srca < srcb) ? 64'b1 : 64'b0;
            end
            ALU_LUI: begin
                aluout = srcb;
            end
            ALU_PASS_A: begin
                aluout = srca;
            end
            default: begin
                aluout = '0;
            end
        endcase
    end



endmodule
`endif