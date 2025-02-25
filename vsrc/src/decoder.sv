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

    wire [6:0] f7 = raw_instr[6:0];
    wire [2:0] f3 = raw_instr[14:12];

    always_comb begin
        ctl = '0;  // 默认初始化
        case (raw_instr[6:0])  // 根据 opcode 解码指令
            OPCODE_RTYPE: begin
                case (f3)
                    FUNC3_ADD: begin
                        if (f7 == FUNC7_SUB) begin
                            ctl.op = SUB;
                            ctl.aluop = ALU_SUB;
                        end else begin
                            ctl.op = ADD;
                            ctl.aluop = ALU_ADD;
                        end
                        ctl.reg_write = 1;
                    end
                    FUNC3_XOR: begin
                        ctl.op = XOR;
                        ctl.aluop = ALU_XOR;
                        ctl.reg_write = 1;
                    end
                    FUNC3_OR: begin
                        ctl.op = OR;
                        ctl.aluop = ALU_OR;
                        ctl.reg_write = 1;
                    end
                    FUNC3_AND: begin
                        ctl.op = AND;
                        ctl.aluop = ALU_AND;
                        ctl.reg_write = 1;
                    end
                    default: ctl.op = UNKNOWNN;  // 默认操作
                endcase
            end

            OPCODE_ITYPE: begin
                imm = {{52{raw_instr[31]}}, raw_instr[31:20]};  // I-type 指令的立即数
                case (f3)
                    FUNC3_ADDI: begin
                        ctl.op = ADDI;
                        ctl.aluop = ALU_ADD;
                        ctl.reg_write = 1;
                        ctl.alusrc = 1;
                    end
                    FUNC3_XORI: begin
                        ctl.op = XORI;
                        ctl.aluop = ALU_XOR;
                        ctl.reg_write = 1;
                        ctl.alusrc = 1;
                    end
                    FUNC3_ORI: begin
                        ctl.op = ORI;
                        ctl.aluop = ALU_OR;
                        ctl.reg_write = 1;
                        ctl.alusrc = 1;
                    end
                    FUNC3_ANDI: begin
                        ctl.op = ANDI;
                        ctl.aluop = ALU_AND;
                        ctl.reg_write = 1;
                        ctl.alusrc = 1;
                    end
                    default: ctl.op = UNKNOWNN;  // 默认操作
                endcase
            end

            OPCODE_OPIMM: begin
                case (f3)
                    FUNC3_ADD: begin
                        if (f7 == FUNC7_SUB) begin
                            ctl.op = ADDIW;
                            ctl.aluop = ALU_SUB;
                        end else begin
                            ctl.op = ADDIW;
                            ctl.aluop = ALU_ADD;
                        end
                        ctl.reg_write = 1;
                    end
                    FUNC3_ANDI: begin
                        imm = {{52{raw_instr[31]}}, raw_instr[31:20]}; 
                        ctl.op = ADDIW;
                        ctl.aluop = ALU_AND;
                        ctl.reg_write = 1;
                        ctl.alusrc = 1;
                    end
                    default: ctl.op = UNKNOWNN;  // 默认操作
                endcase

            end

            default: ctl.op = UNKNOWNN;  // 默认操作
        endcase
    end

endmodule

`endif