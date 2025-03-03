`ifndef __PIPES_SV
`define __PIPES_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif

package pipes;
	import common::*;

/* Define instrucion decoding rules here */

parameter OPCODE_RTYPE = 7'b0110011;    // R-type 指令的 opcode
parameter OPCODE_ITYPE = 7'b0010011;    // I-type 指令的 opcode
parameter OPCODE_LOAD = 7'b0000011;     // Load 指令的 opcode
parameter OPCODE_STORE = 7'b0100011;    // Store 指令的 opcode
parameter OPCODE_ITYPEW = 7'b0011011;    // 扩展的 I-type 指令的 opcode
parameter OPCODE_RTYPEW = 7'b0111011;    // 扩展的 R-type 指令的 opcode

parameter FUNC3_ADD = 3'b000;           // funct3: ADD
parameter FUNC3_XOR = 3'b100;           // funct3: XOR
parameter FUNC3_OR  = 3'b110;           // funct3: OR
parameter FUNC3_AND = 3'b111;           // funct3: AND
parameter FUNC3_ADDI = 3'b000;          // funct3: ADDI
parameter FUNC3_XORI = 3'b100;          // funct3: XORI
parameter FUNC3_ORI  = 3'b110;          // funct3: ORI
parameter FUNC3_ANDI = 3'b111;          // funct3: ANDI
parameter FUNC7_SUB = 7'b0100000;       // funct7: SUB
parameter FUNC7_ADD = 7'b0000000;       // funct7: ADD

/* Define pipeline structures here */

typedef enum logic [5:0] {
	ADD, SUB, XOR, OR, AND, ADDI, XORI, ORI, ANDI,
	ADDW, SUBW, ADDIW, UNKNOWN
} instr_op_t;

typedef enum logic [4:0] {
	NOP, ALU_ADD, ALU_SUB, ALU_XOR, ALU_OR, ALU_AND,
	ALU_ADDW, ALU_SUBW
} alu_op_t;

typedef struct packed {
	instr_op_t op;
	alu_op_t aluop;
	u1 reg_write;
	u1 is_imm;
	u1 mem_read, mem_write;
	u1 mem_to_reg;
	u1 is_word;
} control_t;

typedef struct packed {
	word_t pc;
	u32 raw_instr;
} instr_data_t;

typedef struct packed {
	instr_data_t instr;
	word_t pcplus4;
} fetch_data_t;

typedef struct packed {
	word_t srca, srcb;
	creg_addr_t rs1, rs2;
	word_t imm;
	control_t ctl;
	creg_addr_t dst;
	instr_data_t instr;
} decode_data_t;

typedef struct packed {
	control_t ctl;
	word_t aluout;
	creg_addr_t dst;
	instr_data_t instr;
} exec_data_t;

typedef struct packed {
	control_t ctl;
	word_t writedata;
	creg_addr_t dst;
	instr_data_t instr;
} mem_data_t;

typedef struct packed {
	creg_addr_t dst;
	word_t data;
	u1 valid;
} fwd_data_t;

typedef struct packed {
	creg_addr_t rs1, rs2;
	word_t srca, srcb;
	word_t imm;
	u1 is_imm;
} decode_t;

endpackage
`endif