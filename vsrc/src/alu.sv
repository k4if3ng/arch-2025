`ifndef __ALU_SV
`define __ALU_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module alu
    import common::*;
    import pipes::*;(
    input word_t      srca, srcb,
    input alu_ctl_t   ctl,
    output word_t     result,
);

    shamt_t shamt;
    assign shamt = srca[4:0];
    // arith_t temp;

    always_comb begin
        exception = 1'b0;
        result = '0;

        unique case (ctl.aluop)
            ALU_ADD: begin
                result = srca + srcb;
            end
            ALU_SUB: begin
                result = srca - srcb;
            end
            ALU_SLL: begin
                result = srca << shamt;
            end
            ALU_SRL: begin
                result = srca >> shamt;
            end
            ALU_SRA: begin
                result = signed'(srca) >>> shamt;
            end
            ALU_SLT: begin
                result = (signed'(srca) < signed'(srcb)) ? 32'b1 : 32'b0;
            end
            ALU_AND: begin
                result = srca & srcb;
            end
            ALU_OR: begin
                result = srca | srcb;
            end
            ALU_XOR: begin
                result = srca ^ srcb;
            end
            ALU_SLTU: begin
                result = (srca < srcb) ? 32'b1 : 32'b0;
            end

        endcase
    end



endmodule
`endif