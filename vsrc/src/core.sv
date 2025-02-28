`ifndef __CORE_SV
`define __CORE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "src/fetch.sv"
`include "src/decode.sv"
`include "src/execute.sv"
`include "src/if_id_reg.sv"
`include "src/id_ex_reg.sv"
`include "src/ex_mem_reg.sv"
`include "src/mem_wb_reg.sv"
`include "src/pcselect.sv"
`include "src/regfile.sv"
`include "src/alu.sv"
`include "src/decoder.sv"
`include "src/memory.sv"
`include "src/forward.sv"
// `include "src/mux.sv"
`endif

module core
	import common::*;
	import pipes::*;(
	input  logic       clk, reset,
	output ibus_req_t  ireq,
	input  ibus_resp_t iresp,
	output dbus_req_t  dreq,
	input  dbus_resp_t dresp,
	input  logic       trint, swint, exint
);
	/* TODO: Add your CPU-Core here. */
	u1 stallpc;
	assign stallpc = ireq.valid && ~iresp.data_ok;
	u1 stallF, stallD, stallE, stallM, stallW;
	u1 flushF, flushD, flushE, flushM, flushW;

	// for test
	assign stallF = stallpc;
	assign stallD = stallF;
	assign stallE = stallD;
	assign stallM = stallE;

	assign flushF = 0;
	assign flushD = 0;
	assign flushE = 0;
	assign flushM = 0;

	u64 pc, pc_nxt;

	assign ireq.valid = 1'b1;
	assign ireq.addr  = pc;

	assign dreq.valid = 1'b0;

	u32 raw_instr;

	assign raw_instr = iresp.data;

	fetch_data_t 	dataF, dataF_nxt;
	decode_data_t 	dataD, dataD_nxt;
	exec_data_t 	dataE, dataE_nxt;
	mem_data_t 		dataM, dataM_nxt;
	// wb_data_t 		dataW;

	// word_t memout = dresp.data;
	// word_t regs_nxt[31:0];

	creg_addr_t ra1, ra2;
	word_t rd1, rd2;

	word_t fwd_aluout;
	u1 fwd_valid_a, fwd_valid_b;

	word_t fwd_aluout_;
	u1 fwd_valid_a_, fwd_valid_b_;
	
	word_t alusrca, alusrcb;

	assign alusrca = fwd_valid_a_ ? fwd_aluout_ : fwd_valid_a ? fwd_aluout : dataD.srca;
	assign alusrcb = fwd_valid_b_ ? fwd_aluout_ : fwd_valid_b ? fwd_aluout : dataD.ctl.alusrc ? dataD.imm : dataD.srcb;


	u1 is_word;

	assign is_word = 0;

	always_ff @(posedge clk) begin
		if (reset) begin
			pc <= PCINIT;
		end else if (stallpc) begin
			pc <= pc;
		end else begin
			pc <= pc_nxt;
		end
	end


	if_id_reg if_id_reg(
		.clk	(clk),
		.reset  (reset),
		.dataF_new(dataF_nxt),
		.enable (1'b1),
		.flush  (flushF),
		.stall  (stallF),
		.dataF  (dataF)
	);

	id_ex_reg id_ex_reg(
		.clk	(clk),
		.reset  (reset),
		.dataD_new(dataD_nxt),
		.enable (1'b1),
		.flush  (flushD),
		.stall  (stallD),
		.dataD  (dataD)
	);

	ex_mem_reg ex_mem_reg(
		.clk	(clk),
		.reset  (reset),
		.dataE_new(dataE_nxt),
		.enable (1'b1),
		.flush  (flushE),
		.stall  (stallE),
		.dataE  (dataE)
	);

	mem_wb_reg mem_wb_reg(
		.clk	(clk),
		.reset  (reset),
		.dataM_new(dataM_nxt),
		.enable (1'b1),
		.flush  (flushM),
		.stall  (stallM),
		.dataM  (dataM)
	);

	fetch fetch(
		.pc			(pc),
		.flushF		(flushF),
		.stallF		(stallF),
		.raw_instr 	(raw_instr),
		.dataF     	(dataF_nxt)
	);

	pcselect pcselect(
		.pcplus4 	(pc + 4),
		.pc_selected(pc_nxt)
	);

	decode decode(
		.dataF (dataF),
		.dataD (dataD_nxt),
		.ra1   (ra1),
		.ra2   (ra2),
		.rd1   (rd1),
		.rd2   (rd2),
		.fwd_valid_a (fwd_valid_a),
		.fwd_valid_b (fwd_valid_b),
		.fwd_aluout  (fwd_aluout),
		.fwd_valid_a_ (fwd_valid_a_),
		.fwd_valid_b_ (fwd_valid_b_),
		.fwd_aluout_  (fwd_aluout_)
	);

	execute execute(
		// .alusrca(alusrca),
		// .alusrcb(alusrcb),
		.dataD (dataD),
		// .is_word(is_word),
		.dataE (dataE_nxt)
	);


	regfile regfile(
		.clk    (clk),
		.reset  (reset),
		.ra1    (ra1),
		.ra2    (ra2),
		.rd1    (rd1),
		.rd2    (rd2),
		.wvalid (dataM.ctl.reg_write),
		.wa     (dataM.dst),
		.wd     (dataM.writedata)
	);

	memory memory(
		.dataE  (dataE),
		.memout (0),
		.aluout (dataE.aluout),
		.dataM  (dataM_nxt)
	);

	forward ex_forward(
		// .clk	(clk),
		// .reset  (reset),
		.aluout (dataE_nxt.aluout),
		.dst    (dataE_nxt.dst),
		.dst_valid (dataE_nxt.ctl.reg_write),
		.srca    (ra1),
		.srcb    (ra2),
		.alusrc  (0),
		.fwd_aluout (fwd_aluout),
		.fwd_valid_a (fwd_valid_a),
		.fwd_valid_b (fwd_valid_b)
	);

	forward mem_forward(
		// .clk	(clk),
		// .reset  (reset),
		.aluout (dataM_nxt.writedata),
		.dst    (dataM_nxt.dst),
		.dst_valid (dataM_nxt.ctl.reg_write),
		.srca    (ra1),
		.srcb    (ra2),
		.alusrc  (0),
		.fwd_aluout (fwd_aluout_),
		.fwd_valid_a (fwd_valid_a_),
		.fwd_valid_b (fwd_valid_b_)
	);


`ifdef VERILATOR
	DifftestInstrCommit DifftestInstrCommit(
		.clock              (clk),
		.coreid             (0),
		.index              (0),
		.valid              (!stallpc),
		.pc                 (dataM.instr.pc),
		.instr              (dataM.instr.raw_instr),
		.skip               (0),
		.isRVC              (0),
		.scFailed           (0),
		.wen                (dataM.ctl.reg_write),
		.wdest              ({3'b000, dataM.dst}),
		.wdata              (dataM.writedata)
	);

	DifftestArchIntRegState DifftestArchIntRegState (
		.clock              (clk),
		.coreid             (0),
		.gpr_0              (regfile.regs_nxt[0]),
		.gpr_1              (regfile.regs_nxt[1]),
		.gpr_2              (regfile.regs_nxt[2]),
		.gpr_3              (regfile.regs_nxt[3]),
		.gpr_4              (regfile.regs_nxt[4]),
		.gpr_5              (regfile.regs_nxt[5]),
		.gpr_6              (regfile.regs_nxt[6]),
		.gpr_7              (regfile.regs_nxt[7]),
		.gpr_8              (regfile.regs_nxt[8]),
		.gpr_9              (regfile.regs_nxt[9]),
		.gpr_10             (regfile.regs_nxt[10]),
		.gpr_11             (regfile.regs_nxt[11]),
		.gpr_12             (regfile.regs_nxt[12]),
		.gpr_13             (regfile.regs_nxt[13]),
		.gpr_14             (regfile.regs_nxt[14]),
		.gpr_15             (regfile.regs_nxt[15]),
		.gpr_16             (regfile.regs_nxt[16]),
		.gpr_17             (regfile.regs_nxt[17]),
		.gpr_18             (regfile.regs_nxt[18]),
		.gpr_19             (regfile.regs_nxt[19]),
		.gpr_20             (regfile.regs_nxt[20]),
		.gpr_21             (regfile.regs_nxt[21]),
		.gpr_22             (regfile.regs_nxt[22]),
		.gpr_23             (regfile.regs_nxt[23]),
		.gpr_24             (regfile.regs_nxt[24]),
		.gpr_25             (regfile.regs_nxt[25]),
		.gpr_26             (regfile.regs_nxt[26]),
		.gpr_27             (regfile.regs_nxt[27]),
		.gpr_28             (regfile.regs_nxt[28]),
		.gpr_29             (regfile.regs_nxt[29]),
		.gpr_30             (regfile.regs_nxt[30]),
		.gpr_31             (regfile.regs_nxt[31])
	);

    DifftestTrapEvent DifftestTrapEvent(
		.clock              (clk),
		.coreid             (0),
		.valid              (0),
		.code               (0),
		.pc                 (0),
		.cycleCnt           (0),
		.instrCnt           (0)
	);

	DifftestCSRState DifftestCSRState(
		.clock              (clk),
		.coreid             (0),
		.priviledgeMode     (3),
		.mstatus            (0),
		.sstatus            (0 /* mstatus & 64'h800000030001e000 */),
		.mepc               (0),
		.sepc               (0),
		.mtval              (0),
		.stval              (0),
		.mtvec              (0),
		.stvec              (0),
		.mcause             (0),
		.scause             (0),
		.satp               (0),
		.mip                (0),
		.mie                (0),
		.mscratch           (0),
		.sscratch           (0),
		.mideleg            (0),
		.medeleg            (0)
	);
`endif
endmodule
`endif