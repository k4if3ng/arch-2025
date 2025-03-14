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
        case (opcode)
            OPCODE_RTYPE: begin
                case (f3)
                    FUNC3_ADD: begin
                        case (f7)
                            FUNC7_ADD: begin
                                ctl.aluop = ALU_ADD;
                                ctl.reg_write = 1;
                                ctl.op = ADD;
                            end
                            FUNC7_SUB: begin
                                ctl.aluop = ALU_SUB;
                                ctl.reg_write = 1;
                                ctl.op = SUB;
                            end
                            FUNC7_RVM: begin
                                ctl.mduop = MDU_MUL;
                                ctl.reg_write = 1;
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
                                ctl.reg_write = 1;
                                ctl.op = XOR;
                            end
                            FUNC7_RVM: begin
                                ctl.mduop = MDU_DIV;
                                ctl.reg_write = 1;
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
                                ctl.reg_write = 1;
                                ctl.op = OR;
                            end
                            FUNC7_RVM: begin
                                ctl.mduop = MDU_REM;
                                ctl.reg_write = 1;
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
                                ctl.reg_write = 1;
                                ctl.op = AND;
                            end
                            FUNC7_RVM: begin
                                ctl.mduop = MDU_REMU;
                                ctl.reg_write = 1;
                                ctl.op = REMU;
                            end
                            default: begin
                                ctl = 0;
                            end
                        endcase
                    end
                    FUNC3_DIVU: begin
                        ctl.mduop = MDU_DIVU;
                        ctl.reg_write = 1;
                        ctl.op = DIVU;
                    end
                    default: begin
                        ctl = 0;
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
                        ctl = 0;
                    end
                endcase
            end

            OPCODE_RTYPEW: begin
                case (f3)
                    FUNC3_ADDW: begin
                        case (f7) 
                            FUNC7_ADDW: begin
                                ctl.aluop = ALU_ADD;
                                ctl.reg_write = 1;
                                ctl.op = ADDW;
                            end
                            FUNC7_SUBW: begin
                                ctl.aluop = ALU_SUB;
                                ctl.reg_write = 1;
                                ctl.op = SUBW;
                            end
                            FUNC7_RVM: begin
                                ctl.mduop = MDU_MULW;
                                ctl.reg_write = 1;
                                ctl.op = MULW;
                            end
                            default: begin
                                ctl = 0;
                            end
                        endcase
                    end
                    FUNC3_DIVW: begin
                        ctl.mduop = MDU_DIVW;
                        ctl.reg_write = 1;
                        ctl.op = DIVW;
                    end
                    FUNC3_DIVUW: begin
                        ctl.mduop = MDU_DIVUW;
                        ctl.reg_write = 1;
                        ctl.op = DIVUW;
                    end
                    FUNC3_REMW: begin
                        ctl.mduop = MDU_REMW;
                        ctl.reg_write = 1;
                        ctl.op = REMW;
                    end
                    FUNC3_REMUW: begin
                        ctl.mduop = MDU_REMUW;
                        ctl.reg_write = 1;
                        ctl.op = REMUW;
                    end
                    default: begin
                        ctl = 0;
                    end
                endcase
            end

            OPCODE_ITYPEW: begin
                imm = {{52{raw_instr[31]}}, raw_instr[31:20]};  // I-type 指令的立即数
                case (f3)
                    FUNC3_ADDIW: begin
                        ctl.aluop = ALU_ADD;
                        ctl.reg_write = 1;
                        ctl.is_imm = 1;
                        ctl.op = ADDIW;
                    end
                    default: begin
                        ctl = 0;
                    end
                endcase
            end

            OPCODE_LOAD: begin
                imm = {{52{raw_instr[31]}}, raw_instr[31:20]};  // I-type 指令的立即数
                ctl.mem_read = 1;
                ctl.mem_to_reg = 1;
                ctl.reg_write = 1;  // 确保将加载的数据写入寄存器
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
                        ctl = 0;  // 无效的操作
                    end
                endcase
            end
            

            OPCODE_STORE: begin
                imm = {{52{raw_instr[31]}}, raw_instr[31:25], raw_instr[11:7]};  // S-type 指令的立即数
                ctl.mem_write = 1;
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
                ctl.aluop = ALU_NOP;
                ctl.reg_write = 1;
                ctl.is_imm = 1;
                ctl.op = LUI;
            end

            OPCODE_AUIPC: begin
                imm = {{32{raw_instr[31]}}, raw_instr[31:12], 12'b0};  // U-type 指令的立即数
                ctl.aluop = ALU_ADD;
                ctl.reg_write = 1;
                ctl.op = ALUPC;
            end

            default: begin
                ctl = 0;
            end
        endcase
    end

endmodule

`endif