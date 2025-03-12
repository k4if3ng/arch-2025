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
            default: begin
                aluout = srcb;
            end
        endcase
    end



endmodule
`endif