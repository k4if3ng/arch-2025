`ifndef __DECODER_SV
`define __DECODER_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
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
        imm = '0;
        case (opcode)
            OPCODE_RTYPE: begin
                ctl.reg_write = 1;
                case (f3)
                    FUNC3_ADD: begin
                        case (f7)
                            FUNC7_ADD: begin
                                ctl.aluop = ALU_ADD;
                                ctl.op = ADD;
                            end
                            FUNC7_SUB: begin
                                ctl.aluop = ALU_SUB;
                                ctl.op = SUB;
                            end
                            FUNC7_RVM: begin
                                ctl.mduop = MDU_MUL;
                                ctl.op = MUL;
                            end
                            default: begin
                                ctl = 0;
                            end
                        endcase
                    end
                    FUNC3_XOR: begin
                        case (f7)
                            FUNC7_XOR: begin
                                ctl.aluop = ALU_XOR;
                                ctl.op = XOR;
                            end
                            FUNC7_RVM: begin
                                ctl.mduop = MDU_DIV;
                                ctl.op = DIV;
                            end 
                            default: begin
                                ctl = 0;
                            end
                        endcase
                    end
                    FUNC3_OR: begin
                        case (f7)
                            FUNC7_OR: begin
                                ctl.aluop = ALU_OR;
                                ctl.op = OR;
                            end
                            FUNC7_RVM: begin
                                ctl.mduop = MDU_REM;
                                ctl.op = REM;
                            end
                            default: begin
                                ctl = 0;
                            end
                        endcase
                    end
                    FUNC3_AND: begin
                        case (f7)
                            FUNC7_AND: begin
                                ctl.aluop = ALU_AND;
                                ctl.op = AND;
                            end
                            FUNC7_RVM: begin
                                ctl.mduop = MDU_REMU;
                                ctl.op = REMU;
                            end
                            default: begin
                                ctl = 0;
                            end
                        endcase
                    end
                    FUNC3_SLL: begin
                        ctl.aluop = ALU_SLL;
                        ctl.op = SLL;
                    end
                    FUNC3_SRL: begin
                        case (f7)
                            FUNC7_SRL: begin
                                ctl.aluop = ALU_SRL;
                                ctl.op = SRL;
                            end
                            FUNC7_SRA: begin
                                ctl.aluop = ALU_SRA;
                                ctl.op = SRA;
                            end
                            default: begin
                                ctl = 0;
                            end
                        endcase
                    end
                    FUNC3_SLT: begin
                        ctl.op = SLT;
                        ctl.aluop = ALU_SLT;
                    end
                    FUNC3_SLTU: begin
                        ctl.op = SLTU;
                        ctl.aluop = ALU_SLTU;
                    end
                    default: begin
                        ctl = 0;
                    end
                endcase
            end

            OPCODE_ITYPE: begin
                imm = {{52{raw_instr[31]}}, raw_instr[31:20]};  // I-type 指令的立即数
                ctl.reg_write = 1;
                ctl.is_imm = 1;
                case (f3)
                    FUNC3_ADDI: begin
                        ctl.aluop = ALU_ADD;
                        ctl.op = ADDI;
                    end
                    FUNC3_XORI: begin
                        ctl.aluop = ALU_XOR;
                        ctl.op = XORI;
                    end
                    FUNC3_ORI: begin
                        ctl.aluop = ALU_OR;
                        ctl.op = ORI;
                    end
                    FUNC3_ANDI: begin
                        ctl.aluop = ALU_AND;
                        ctl.op = ANDI;
                    end
                    FUNC3_SLLI: begin
                        ctl.aluop = ALU_SLL;
                        ctl.op = SLLI;
                    end
                    FUNC3_SRLI: begin
                        case (f7[6:1])
                            FUNC6_SRLI: begin
                                ctl.aluop = ALU_SRL;
                                ctl.op = SRLI;
                            end
                            FUNC6_SRAI: begin
                                ctl.aluop = ALU_SRA;
                                ctl.op = SRAI;
                            end
                            default: begin
                                ctl = 0;
                            end
                        endcase
                    end
                    FUNC3_SLTI: begin
                        ctl.op = SLTI;
                        ctl.aluop = ALU_SLT;
                    end
                    FUNC3_SLTIU: begin
                        ctl.op = SLTIU;
                        ctl.aluop = ALU_SLTU;
                    end
                    default: begin
                        ctl = 0;
                    end
                endcase
            end

            OPCODE_RTYPEW: begin
                ctl.reg_write = 1;
                case (f3)
                    FUNC3_ADD: begin
                        case (f7) 
                            FUNC7_ADD: begin
                                ctl.aluop = ALU_ADD;
                                ctl.op = ADDW;
                            end
                            FUNC7_SUB: begin
                                ctl.aluop = ALU_SUB;
                                ctl.op = SUBW;
                            end
                            FUNC7_RVM: begin
                                ctl.mduop = MDU_MULW;
                                ctl.op = MULW;
                            end
                            default: begin
                                ctl = 0;
                            end
                        endcase
                    end
                    FUNC3_SLL: begin
                        ctl.aluop = ALU_SLLW;
                        ctl.op = SLLW;
                    end
                    FUNC3_SRL: begin
                        case (f7)
                            FUNC7_SRL: begin
                                ctl.aluop = ALU_SRLW;
                                ctl.op = SRLW;
                            end
                            FUNC7_SRA: begin
                                ctl.aluop = ALU_SRAW;
                                ctl.op = SRAW;
                            end
                            default: begin
                                ctl = 0;
                            end
                        endcase
                    end
                    default: begin
                        ctl = 0;
                    end
                endcase
            end

            OPCODE_ITYPEW: begin
                imm = {{52{raw_instr[31]}}, raw_instr[31:20]};  // I-type 指令的立即数
                ctl.is_imm = 1;
                ctl.reg_write = 1;
                case (f3)
                    FUNC3_ADDI: begin
                        ctl.aluop = ALU_ADD;
                        ctl.op = ADDIW;
                    end
                    FUNC3_SLLI: begin
                        ctl.aluop = ALU_SLLW;
                        ctl.op = SLLIW;
                    end
                    FUNC3_SRLI: begin
                        case (f7[6:1])
                            FUNC6_SRLI: begin
                                ctl.aluop = ALU_SRLW;
                                ctl.op = SRLIW;
                            end
                            FUNC6_SRAI: begin
                                ctl.aluop = ALU_SRAW;
                                ctl.op = SRAIW;
                            end
                            default: begin
                                ctl = 0;
                            end
                        endcase
                    end
                    default: begin
                        ctl = 0;
                    end
                endcase
            end

            OPCODE_LOAD: begin
                imm = {{52{raw_instr[31]}}, raw_instr[31:20]};  // I-type 指令的立即数
                ctl.mem_access = 1;
                ctl.mem_to_reg = 1;
                ctl.reg_write = 1;
                ctl.aluop = ALU_ADD;
                ctl.is_imm = 1;
                case (f3)
                    FUNC3_LD: begin
                        ctl.op = LD;
                    end
                    FUNC3_LB: begin
                        ctl.op = LB;
                    end
                    FUNC3_LH: begin
                        ctl.op = LH;
                    end
                    FUNC3_LW: begin
                        ctl.op = LW;
                    end
                    FUNC3_LBU: begin
                        ctl.op = LBU;
                    end
                    FUNC3_LHU: begin
                        ctl.op = LHU;
                    end
                    FUNC3_LWU: begin
                        ctl.op = LWU;
                    end
                    default: begin
                        ctl = 0;
                    end
                endcase
            end
            
            OPCODE_BTYPE: begin
                imm = {{52{raw_instr[31]}}, raw_instr[7], raw_instr[30:25], raw_instr[11:8], 1'b0};  // B-type 指令的立即数
                ctl.aluop = ALU_ADD;
                ctl.is_imm = 1;
                case (f3)
                    FUNC3_BEQ: begin
                        ctl.op = BEQ;
                    end
                    FUNC3_BNE: begin
                        ctl.op = BNE;
                    end
                    FUNC3_BLT: begin
                        ctl.op = BLT;
                    end
                    FUNC3_BGE: begin
                        ctl.op = BGE;
                    end
                    FUNC3_BLTU: begin
                        ctl.op = BLTU;
                    end
                    FUNC3_BGEU: begin
                        ctl.op = BGEU;
                    end
                    default: begin
                        ctl = '0;
                    end
                endcase
            end

            OPCODE_STORE: begin
                imm = {{52{raw_instr[31]}}, raw_instr[31:25], raw_instr[11:7]};  // S-type 指令的立即数
                ctl.mem_access = 1;
                ctl.aluop = ALU_ADD;
                ctl.is_imm = 1;
                case (f3)
                    FUNC3_SD: begin
                        ctl.op = SD;
                    end
                    FUNC3_SB: begin
                        ctl.op = SB;
                    end
                    FUNC3_SH: begin
                        ctl.op = SH;
                    end
                    FUNC3_SW: begin
                        ctl.op = SW;
                    end
                    default: begin
                        ctl = 0;  // 无效的操作
                    end
                endcase
            end
            

            OPCODE_LUI: begin
                imm = {{32{raw_instr[31]}}, raw_instr[31:12], 12'b0};  // U-type 指令的立即数
                ctl.aluop = ALU_LUI;
                ctl.reg_write = 1;
                ctl.is_imm = 1;
                ctl.op = LUI;
            end

            OPCODE_AUIPC: begin
                imm = {{32{raw_instr[31]}}, raw_instr[31:12], 12'b0};  // U-type 指令的立即数
                ctl.aluop = ALU_ADD;
                ctl.reg_write = 1;
                ctl.is_imm = 1;
                ctl.op = AUIPC;
            end

            OPCODE_JAL: begin
                imm = {{44{raw_instr[31]}}, raw_instr[19:12], raw_instr[20], raw_instr[30:21], 1'b0};  // J-type 指令的立即数
                ctl.aluop = ALU_ADD;
                ctl.reg_write = 1;
                ctl.is_imm = 1;
                ctl.jump = 1;
                ctl.op = JAL;
            end

            OPCODE_JALR: begin
                imm = {{52{raw_instr[31]}}, raw_instr[31:20]};  // I-type 指令的立即数
                ctl.aluop = ALU_ADD;
                ctl.reg_write = 1;
                ctl.is_imm = 1;
                ctl.jump = 1;
                ctl.op = JALR;
            end

            OPCODE_SYSTEM: begin
                imm = {{59{1'b0}}, raw_instr[19:15]};
                ctl.reg_write = 1;
                ctl.csr = 1;
                ctl.aluop = ALU_PASS_A;
                case (f3)
                    FUNC3_CSRRW: begin
                        ctl.op = CSRRW;
                    end
                    FUNC3_CSRRS: begin
                        ctl.op = CSRRS;
                    end
                    FUNC3_CSRRC: begin
                        ctl.op = CSRRC;
                    end
                    FUNC3_CSRRWI: begin
                        ctl.op = CSRRWI;
                        ctl.is_imm = 1;
                    end
                    FUNC3_CSRRSI: begin
                        ctl.op = CSRRSI;
                        ctl.is_imm = 1;
                    end
                    FUNC3_CSRRCI: begin
                        ctl.op = CSRRCI;
                        ctl.is_imm = 1;
                    end
                    default: begin
                        ctl = 0;
                    end
                endcase
            end

            default: begin
                ctl = 0;
            end
        endcase
    end

endmodule

`endif