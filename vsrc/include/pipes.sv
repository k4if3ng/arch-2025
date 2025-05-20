`ifndef __PIPES_SV
`define __PIPES_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/csr.sv"
`endif

package pipes;
	import common::*;
	import csr_pkg::*;

/* Define instrucion decoding rules here */
parameter OPCODE_RTYPE = 7'b0110011;    // R-type 指令的 opcode
parameter OPCODE_ITYPE = 7'b0010011;    // I-type 指令的 opcode
parameter OPCODE_LOAD = 7'b0000011;     // Load 指令的 opcode
parameter OPCODE_STORE = 7'b0100011;    // Store 指令的 opcode
parameter OPCODE_ITYPEW = 7'b0011011;    // 扩展的 I-type 指令的 opcode
parameter OPCODE_RTYPEW = 7'b0111011;    // 扩展的 R-type 指令的 opcode
parameter OPCODE_LUI = 7'b0110111;      // LUI 指令的 opcode
parameter OPCODE_AUIPC = 7'b0010111;    // AUIPC 指令的 opcode
parameter OPCODE_BTYPE = 7'b1100011;   // Branch 指令的 opcode
parameter OPCODE_JALR = 7'b1100111;     // JALR 指令的 opcode
parameter OPCODE_JAL = 7'b1101111;      // JAL 指令的 opcode
// parameter OPCODE_RV32M = 7'b0110011;    // RV32M 指令的 opcode
// parameter OPCODE_RV64M = 7'b0111011;    // RV64M 指令的 opcode
parameter OPCODE_SYSTEM = 7'b1110011;      // CSR 指令的 opcode

parameter FUNC3_ADD = 3'b000;           // funct3: ADD
parameter FUNC3_XOR = 3'b100;           // funct3: XOR
parameter FUNC3_OR  = 3'b110;           // funct3: OR
parameter FUNC3_AND = 3'b111;           // funct3: AND
parameter FUNC3_ADDI = 3'b000;          // funct3: ADDI
parameter FUNC3_XORI = 3'b100;          // funct3: XORI
parameter FUNC3_ORI  = 3'b110;          // funct3: ORI
parameter FUNC3_ANDI = 3'b111;          // funct3: ANDI
parameter FUNC3_SLL = 3'b001;           // funct3: SLL
parameter FUNC3_SRL = 3'b101;           // funct3: SRL
parameter FUNC3_SRA = 3'b101;           // funct3: SRA
parameter FUNC3_SLT = 3'b010;           // funct3: SLT
parameter FUNC3_SLTU = 3'b011;          // funct3: SLTU
parameter FUNC3_SLLI = 3'b001;          // funct3: SLLI
parameter FUNC3_SRLI = 3'b101;          // funct3: SRLI
parameter FUNC3_SRAI = 3'b101;          // funct3: SRAI
parameter FUNC3_SLTI = 3'b010;          // funct3: SLTI
parameter FUNC3_SLTIU = 3'b011;         // funct3: SLTIU
parameter FUNC3_SLLW = 3'b001;          // funct3: SLLW
parameter FUNC3_SRLW = 3'b101;          // funct3: SRLW
parameter FUNC3_SRAW = 3'b101;          // funct3: SRAW
parameter FUNC3_SLLIW = 3'b001;         // funct3: SLLIW
parameter FUNC3_SRLIW = 3'b101;         // funct3: SRLIW
parameter FUNC3_SRAIW = 3'b101;         // funct3: SRAIW
parameter FUNC3_BEQ = 3'b000;           // funct3: BEQ
parameter FUNC3_BNE = 3'b001;           // funct3: BNE
parameter FUNC3_BLT = 3'b100;           // funct3: BLT
parameter FUNC3_BGE = 3'b101;           // funct3: BGE
parameter FUNC3_BLTU = 3'b110;          // funct3: BLTU
parameter FUNC3_BGEU = 3'b111;          // funct3: BGEU

parameter FUNC7_SUB = 7'b0100000;       // funct7: SUB
parameter FUNC7_ADD = 7'b0000000;       // funct7: ADD
parameter FUNC7_XOR = 7'b0000000;       // funct7: XOR
parameter FUNC7_OR = 7'b0000000;        // funct7: OR
parameter FUNC7_AND = 7'b0000000;       // funct7: AND
parameter FUNC7_RVM = 7'b0000001;       // funct7: MUL, MULW...
parameter FUNC7_SRL = 7'b0000000;       // funct7: SRL
parameter FUNC7_SRA = 7'b0100000;       // funct7: SRA

parameter FUNC6_SRLI = 6'b000000;       // funct6: SRLI
parameter FUNC6_SRAI = 6'b010000;       // funct6: SRAI

parameter FUNC3_LD = 3'b011;            // funct3: LD
parameter FUNC3_LB = 3'b000;            // funct3: LB
parameter FUNC3_LH = 3'b001;            // funct3: LH
parameter FUNC3_LW = 3'b010;            // funct3: LW
parameter FUNC3_LBU = 3'b100;           // funct3: LBU
parameter FUNC3_LHU = 3'b101;           // funct3: LHU
parameter FUNC3_LWU = 3'b110;           // funct3: LWU
parameter FUNC3_SD = 3'b011;            // funct3: SD
parameter FUNC3_SB = 3'b000;            // funct3: SB
parameter FUNC3_SH = 3'b001;            // funct3: SH
parameter FUNC3_SW = 3'b010;            // funct3: SW

parameter FUNC3_LUI = 3'b011;           // funct3: LUI

parameter FUNC3_MUL = 3'b000;           // funct3: MUL
parameter FUNC3_DIV = 3'b100;           // funct3: DIV
parameter FUNC3_DIVU = 3'b101;          // funct3: DIVU
parameter FUNC3_REM = 3'b110;           // funct3: REM
parameter FUNC3_REMU = 3'b111;          // funct3: REMU
parameter FUNC3_MULW = 3'b000;          // funct3: MULW
parameter FUNC3_DIVW = 3'b100;          // funct3: DIVW
parameter FUNC3_DIVUW = 3'b101;         // funct3: DIVUW
parameter FUNC3_REMW = 3'b110;          // funct3: REMW
parameter FUNC3_REMUW = 3'b111;         // funct3: REMUW

parameter FUNC3_CSRRW = 3'b001;         // funct3: CSRRW
parameter FUNC3_CSRRS = 3'b010;         // funct3: CSRRS
parameter FUNC3_CSRRC = 3'b011;         // funct3: CSRRC
parameter FUNC3_CSRRWI = 3'b101;        // funct3: CSRRWI
parameter FUNC3_CSRRSI = 3'b110;        // funct3: CSRRSI
parameter FUNC3_CSRRCI = 3'b111;        // funct3: CSRRCI
parameter FUNC3_ECALL = 3'b000;        	// funct3: MRET

parameter FUNC7_MRET = 7'b0011000;        // funct7: MRET
parameter INST_MRET = 32'h00000073;        // MRET
parameter INST_ECALL = 32'h00000073;        // ECALL


typedef enum logic [6:0] {
	UNKNOWN,
	ADD, SUB, XOR, OR, AND, ADDI, XORI, ORI, ANDI,
	SLL, SRL, SRA, SLT, SLTU, SLLI, SRLI, SRAI, SLTI, SLTIU,
	ADDW, SUBW, ADDIW,
	SLLW, SRLW, SRAW, SLLIW, SRLIW, SRAIW,
	MUL, DIV, DIVU, REM, REMU, MULW, DIVW, DIVUW, REMW, REMUW,
	LD, SD, LB, LH, LW, LBU, LHU, LWU, SB, SH, SW, LUI, AUIPC,
	BEQ, BNE, BLT, BGE, BLTU, BGEU,
	JALR, JAL,
	CSRRW, CSRRS, CSRRC, CSRRWI, CSRRSI, CSRRCI,
	MRET, ECALL
} instr_op_t;

typedef enum logic [4:0] {
	ALU_NOP, ALU_PASS_A,
	ALU_ADD, ALU_SUB, ALU_XOR, ALU_OR, ALU_AND, ALU_LUI,
	ALU_SLL, ALU_SRL, ALU_SRA,
	ALU_SLLW, ALU_SRLW, ALU_SRAW,
	ALU_SLT, ALU_SLTU
} alu_op_t;

typedef enum logic [3:0] {
    MDU_NOP,
    MDU_MUL, MDU_DIV, MDU_DIVU, MDU_REM, MDU_REMU,
	MDU_MULW, MDU_DIVW, MDU_DIVUW, MDU_REMW, MDU_REMUW 
} mdu_op_t;

typedef struct packed {
	instr_op_t op;
	alu_op_t aluop;
	mdu_op_t mduop;
	u1 reg_write;
	u1 is_imm;
	u1 mem_access;
	u1 mem_to_reg;
	u1 jump;
	u1 csr;
} control_t;

typedef struct packed {
	word_t pc;
	u32 raw_instr;
} instr_data_t;

typedef struct packed {
	instr_data_t instr;
} fetch_data_t;

typedef struct packed {
	creg_addr_t rs1, rs2;
	word_t srca, srcb;
	word_t imm;
	csr_addr_t csr_waddr;
	word_t csr_data;
	control_t ctl;
	creg_addr_t dst;
	instr_data_t instr;
	excep_data_t excep_wdata;
	mstatus_t excep_mstatus;
	priv_t priv;
} decode_data_t;

typedef struct packed {
	control_t ctl;
	word_t rd;
	word_t aluout;
	word_t csr_data;
	csr_addr_t csr_waddr;
	creg_addr_t dst;
	instr_data_t instr;
	word_t pcjump;
	excep_data_t excep_wdata;
	mstatus_t excep_mstatus;
	priv_t priv;
	priv_t priv_nxt;
} exec_data_t;

typedef struct packed {
	control_t ctl;
	word_t writedata;
	word_t csr_data;
	csr_addr_t csr_waddr;
	creg_addr_t dst;
	instr_data_t instr;
	word_t mem_addr;
	excep_data_t excep_wdata;
	mstatus_t excep_mstatus;
	priv_t priv;
} mem_data_t;

typedef struct packed {
	creg_addr_t dst;
	word_t data;
	u1 valid;
} fwd_data_t;

typedef struct packed {
	creg_addr_t rs1, rs2;
	word_t srca, srcb;
} decode_t;

typedef enum logic [1:0] {
	IDLE, WAITING, OVER
} mem_access_state_t;

endpackage
`endif