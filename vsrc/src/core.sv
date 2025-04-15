`ifndef __CORE_SV
`define __CORE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "src/fetch/pcselect.sv"
`include "src/fetch/pcupdate.sv"
`include "src/fetch/fetch.sv"
`include "src/decode/decode.sv"
`include "src/execute/execute.sv"
`include "src/memory/memory.sv"
`include "src/pipeline/if_id_reg.sv"
`include "src/pipeline/id_ex_reg.sv"
`include "src/pipeline/ex_mem_reg.sv"
`include "src/pipeline/mem_wb_reg.sv"
`include "src/pipeline/forwarding.sv"
`include "src/regfile.sv"
`include "src/control.sv"
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
	
	u1 stallpc, stallF, stallD, stallE, stallM;
	u1 flushpc, flushF, flushD, flushE, flushM;

	u64 pc, pc_nxt;

	u1 load_use_hazard;

	fetch_data_t 	dataF, dataF_nxt;
	decode_data_t 	dataD, dataD_nxt;
	exec_data_t 	dataE, dataE_nxt;
	mem_data_t 		dataM, dataM_nxt;

	creg_addr_t ra1, ra2;
	word_t rd1, rd2;

	word_t alusrca, alusrcb;


	pcupdate pcupdate(
		.clk(clk),
		.reset(reset),
		.stall(stallpc),
		.pc_nxt(pc_nxt),
		.pc(pc)
	);

	if_id_reg if_id_reg(
		.clk	(clk),
		.reset  (reset),
		.dataF_nxt(dataF_nxt),
		.flush  (flushF),
		.stall  (stallF),
		.dataF  (dataF)
	);

	id_ex_reg id_ex_reg(
		.clk	(clk),
		.reset  (reset),
		.dataD_nxt(dataD_nxt),
		.flush  (flushD),
		.stall  (stallD),
		.dataD  (dataD)
	);

	ex_mem_reg ex_mem_reg(
		.clk	(clk),
		.reset  (reset),
		.dataE_nxt(dataE_nxt),
		.flush  (flushE),
		.stall  (stallE),
		.dataE  (dataE)
	);

	mem_wb_reg mem_wb_reg(
		.clk	(clk),
		.reset  (reset),
		.dataM_nxt(dataM_nxt),
		.flush  (flushM),
		.stall  (stallM),
		.dataM  (dataM)
	);

	fetch fetch(
		.pc			(pc),
		.iresp 		(iresp),
		.ireq 		(ireq),
		.dataF     	(dataF_nxt)
	);

	pcselect pcselect(
		.pcplus4 	(pc + 4),
		.pcjump     (dataE_nxt.pcjump),
		.jump 		(dataE_nxt.ctl.jump | dataE_nxt.ctl.branch),
		.pc_selected(pc_nxt)
	);

	decode decode(
		.dataF (dataF),
		.dataD (dataD_nxt),
		.ra1   (ra1),
		.ra2   (ra2),
		.rd1   (rd1),
		.rd2   (rd2)
	);

	execute execute(
		.alusrca (alusrca),
		.alusrcb (alusrcb),
		.dataD 	 (dataD),
		.dataE   (dataE_nxt)
	);

	memory memory(
		.clk    (clk),
		.reset  (reset),
		.flush  (!stallM),
		.dataE  (dataE),
		.dresp  (dresp),
		.dreq   (dreq),
		.load_use_hazard (load_use_hazard),
		.dataM  (dataM_nxt)
	);

	regfile regfile(
		.clk    (clk),
		.reset  (reset),
		.ra1    (ra1),
		.ra2    (ra2),
		.rd1    (rd1),
		.rd2    (rd2),
		.wen    (dataM.ctl.reg_write),
		.wa     (dataM.dst),
		.wd     (dataM.writedata)
	);

	control control(
		.invalid(ireq.valid & ~iresp.data_ok),
		.jump(dataE.ctl.jump | dataE.ctl.branch),
		.load_use_hazard(load_use_hazard),
		.stallpc(stallpc),
		.stallF(stallF),
		.stallD(stallD),
		.stallE(stallE),
		.stallM(stallM),
		.flushpc(flushpc),
		.flushF(flushF),
		.flushD(flushD),
		.flushE(flushE),
		.flushM(flushM)
	);

	forwarding forwarding (
		.ex_fwd  	(fwd_data_t'({dataE.dst, dataE.aluout, dataE.ctl.reg_write && !dataE.ctl.mem_to_reg})),
		.mem_fwd  	(fwd_data_t'({dataM.dst, dataM.writedata, dataM.ctl.reg_write})),
		.load_fwd 	(fwd_data_t'({dataM_nxt.dst, dataM_nxt.writedata, dataM_nxt.ctl.reg_write})),
		.decode 	(decode_t'({dataD.rs1, dataD.rs2, dataD.srca, dataD.srcb})),
		.alusrca 	(alusrca),
		.alusrcb 	(alusrcb)
	);


`ifdef VERILATOR
	DifftestInstrCommit DifftestInstrCommit(
		.clock              (clk),
		.coreid             (0),
		.index              (0),
		.valid              (!stallpc && dataM != 0),
		.pc                 (dataM.instr.pc),
		.instr              (dataM.instr.raw_instr),
		.skip               (dataM.ctl.mem_access & dataM.mem_addr[31] == 0),
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
		.sstatus            (0 /* mstatus & SSTATUS_MASK */),
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