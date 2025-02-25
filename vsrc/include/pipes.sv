`ifndef __PIPES_SV
`define __PIPES_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif

package pipes;
	import common::*;
/* Define instrucion decoding rules here */


parameter F7_ADDI = 7'b0010011;
parameter F3_ADDI = 7'b000;
    
/* Define pipeline structures here */

typedef struct packed {
	u32 raw_instr;
} fetch_data_t;

typedef enum logic [5:0] {
	ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND,
	ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI,
	LUI, AUIPC
} decode_op_t;

typedef enum logic [4:0] {
	ALU_ADD, ALU_SUB, ALU_SLL, ALU_SLT, ALU_SLTU, 
    ALU_XOR, ALU_SRL, ALU_SRA, ALU_OR, ALU_AND
} alu_op_t;

typedef struct packed {
	decode_op_t op;
	alu_op_t aluop;
	u1 reg_write;
	u1 alu_src;
	u1 mem_read, mem_write;
	u1 mem_to_reg;
} control_t;

typedef struct packed {
	word_t srca, srcb;
	control_t ctl;
	creg_addr_t dst;
} decode_data_t;


endpackage

`endif