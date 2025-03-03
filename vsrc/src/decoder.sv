`ifndef __DECODER_SV
`define __DECODER_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module decoder
    import common::*;
    import pipes::*;(
    input u32 raw_instr,
    output word_t imm,
    output control_t ctl
);

    wire [6:0] opcode = raw_instr[6:0];
    wire [6:0] f7 = raw_instr[31:25];
    wire [2:0] f3 = raw_instr[14:12];

    always_comb begin
        ctl = '0;
        ctl.is_word = 0;
        case (opcode)
            OPCODE_RTYPE: begin
                case (f3)
                    FUNC3_ADD: begin
                        if (f7 == FUNC7_SUB) begin
                            ctl.aluop = ALU_SUB;
                            ctl.op = SUB;
                        end else begin
                            ctl.aluop = ALU_ADD;
                            ctl.op = ADD;
                        end
                        ctl.reg_write = 1;
                    end
                    FUNC3_XOR: begin
                        ctl.aluop = ALU_XOR;
                        ctl.reg_write = 1;
                        ctl.op = XOR;
                    end
                    FUNC3_OR: begin
                        ctl.aluop = ALU_OR;
                        ctl.reg_write = 1;
                        ctl.op = OR;
                    end
                    FUNC3_AND: begin
                        ctl.aluop = ALU_AND;
                        ctl.reg_write = 1;
                        ctl.op = AND;
                    end
                    default: begin
                        ctl.aluop = NOP;
                        ctl.op = UNKNOWN;
                    end
                endcase
            end

            OPCODE_ITYPE: begin
                imm = {{52{raw_instr[31]}}, raw_instr[31:20]};  // I-type 指令的立即数
                case (f3)
                    FUNC3_ADDI: begin
                        ctl.aluop = ALU_ADD;
                        ctl.reg_write = 1;
                        ctl.is_imm = 1;
                        ctl.op = ADDI;
                    end
                    FUNC3_XORI: begin
                        ctl.aluop = ALU_XOR;
                        ctl.reg_write = 1;
                        ctl.is_imm = 1;
                        ctl.op = XORI;
                    end
                    FUNC3_ORI: begin
                        ctl.aluop = ALU_OR;
                        ctl.reg_write = 1;
                        ctl.is_imm = 1;
                        ctl.op = ORI;
                    end
                    FUNC3_ANDI: begin
                        ctl.aluop = ALU_AND;
                        ctl.reg_write = 1;
                        ctl.is_imm = 1;
                        ctl.op = ANDI;
                    end
                    default: begin
                        ctl.aluop = NOP;
                        ctl.op = UNKNOWN;
                    end
                endcase
            end

            OPCODE_RTYPEW: begin
                case (f3)
                    FUNC3_ADD: begin
                        if (f7 == FUNC7_SUB) begin
                            ctl.aluop = ALU_SUB;
                            ctl.op = SUBW;
                        end else begin
                            ctl.aluop = ALU_ADD;
                            ctl.op = ADDW;
                        end
                        ctl.reg_write = 1;
                        ctl.is_word = 1;
                    end
                    default: begin
                        ctl.aluop = NOP;
                        ctl.op = UNKNOWN;
                    end
                endcase
            end

            OPCODE_ITYPEW: begin
                imm = {{52{raw_instr[31]}}, raw_instr[31:20]};  // I-type 指令的立即数
                case (f3)
                    FUNC3_ADDI: begin
                        ctl.aluop = ALU_ADD;
                        ctl.reg_write = 1;
                        ctl.is_imm = 1;
                        ctl.is_word = 1;
                        ctl.op = ADDIW;
                    end
                    default: begin
                        ctl.aluop = NOP;
                        ctl.op = UNKNOWN;
                    end
                endcase
            end

            default: begin
                ctl.aluop = NOP;
            end
        endcase
    end

endmodule

`endif