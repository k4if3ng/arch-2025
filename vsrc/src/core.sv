`ifndef __CORE_SV
`define __CORE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "src/fetch.sv"
`include "src/decode.sv"
`include "src/execute.sv"
`include "src/idreg.sv"
`include "src/dereg.sv"
`include "src/emreg.sv"
`include "src/mwreg.sv"
`include "src/pcselect.sv"
`include "src/regfile.sv"
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
	// assign stallpc = 0;

	u64 pc, pc_nxt;

	always_ff @(posedge clk) begin
		if (reset) begin
			pc <= PCINIT;
		end else if (stallpc) begin
			pc <= pc;
		end else begin
			pc <= pc_nxt;
		end
	end

	assign ireq.valid = 1'b1;
	assign ireq.addr  = pc;

	assign dreq.valid = '0;

	u32 raw_instr;

	assign raw_instr = iresp.data;

	fetch_data_t dataF, dataF_nxt;
	decode_data_t dataD, dataD_nxt;
	exec_data_t dataE, dataE_nxt;
	mem_data_t dataM, dataM_nxt;
	wb_data_t dataW;

	

	idreg idreg(
		.clk	(clk),
		.reset  (reset),
		.dataF_new(dataF_nxt),
		.enable (1'b1),
		.flush  (stallpc),
		.dataF  (dataF)
	);

	dereg dereg(
		.clk	(clk),
		.reset  (reset),
		.dataD_new(dataD_nxt),
		.enable (1'b1),
		.flush  (stallpc),
		.dataD  (dataD)
	);

	emreg emreg(
		.clk	(clk),
		.reset  (reset),
		.dataE_new(dataE_nxt),
		.enable (1'b1),
		.flush  (stallpc),
		.dataE  (dataE)
	);

	mwreg mwreg(
		.clk	(clk),
		.reset  (reset),
		.dataM_new(dataM_nxt),
		.enable (1'b1),
		.flush  (stallpc),
		.dataM  (dataM)
	);

	fetch fetch(
		.pc(pc),
		.raw_instr 	(raw_instr),
		.dataF     	(dataF_nxt)
	);

	pcselect pcselect(
		.pcplus4 	(pc + 4),
		.pc_selected(pc_nxt)
	);

	creg_addr_t ra1, ra2;
	word_t rd1, rd2;

	decode decode(
		.dataF (dataF),
		.dataD (dataD_nxt),
		.ra1   (ra1),
		.ra2   (ra2),
		.rd1   (rd1),
		.rd2   (rd2)
	);

	execute execute(
		.dataD (dataD),
		.dataE (dataE_nxt)
	);

	word_t writedata;
	assign writedata = dataM.ctl.mem_to_reg ? dataM.memout : dataM.aluout;
	
	regfile regfile(
		.clk    (clk),
		.reset  (reset),
		.ra1    (ra1),
		.ra2    (ra2),
		.rd1    (rd1),
		.rd2    (rd2),
		.wvalid (dataM.ctl.reg_write),
		.wa     (dataM.dst),
		.wd     (writedata)
	);


`ifdef VERILATOR
	DifftestInstrCommit DifftestInstrCommit(
		.clock              (clk),
		.coreid             (0),
		.index              (0),
		.valid              (1'b1),
		.pc                 (dataM.instr.pc),
		.instr              (0),
		.skip               (0),
		.isRVC              (0),
		.scFailed           (0),
		.wen                (dataM.ctl.reg_write),
		.wdest              ({3'b0, dataM.dst}),
		.wdata              (writedata)
	);

	DifftestArchIntRegState DifftestArchIntRegState (
		.clock              (clk),
		.coreid             (0),
		.gpr_0              (regfile.regs_nxt[0]),  // 寄存器x0（硬编码为0）
		.gpr_1              (regfile.regs_nxt[1]),  // 寄存器x1
		.gpr_2              (regfile.regs_nxt[2]),  // 寄存器x2
		.gpr_3              (regfile.regs_nxt[3]),  // 寄存器x3
		.gpr_4              (regfile.regs_nxt[4]),  // 寄存器x4
		.gpr_5              (regfile.regs_nxt[5]),  // 寄存器x5
		.gpr_6              (regfile.regs_nxt[6]),  // 寄存器x6
		.gpr_7              (regfile.regs_nxt[7]),  // 寄存器x7
		.gpr_8              (regfile.regs_nxt[8]),  // 寄存器x8
		.gpr_9              (regfile.regs_nxt[9]),  // 寄存器x9
		.gpr_10             (regfile.regs_nxt[10]), // 寄存器x10
		.gpr_11             (regfile.regs_nxt[11]), // 寄存器x11
		.gpr_12             (regfile.regs_nxt[12]), // 寄存器x12
		.gpr_13             (regfile.regs_nxt[13]), // 寄存器x13
		.gpr_14             (regfile.regs_nxt[14]), // 寄存器x14
		.gpr_15             (regfile.regs_nxt[15]), // 寄存器x15
		.gpr_16             (regfile.regs_nxt[16]), // 寄存器x16
		.gpr_17             (regfile.regs_nxt[17]), // 寄存器x17
		.gpr_18             (regfile.regs_nxt[18]), // 寄存器x18
		.gpr_19             (regfile.regs_nxt[19]), // 寄存器x19
		.gpr_20             (regfile.regs_nxt[20]), // 寄存器x20
		.gpr_21             (regfile.regs_nxt[21]), // 寄存器x21
		.gpr_22             (regfile.regs_nxt[22]), // 寄存器x22
		.gpr_23             (regfile.regs_nxt[23]), // 寄存器x23
		.gpr_24             (regfile.regs_nxt[24]), // 寄存器x24
		.gpr_25             (regfile.regs_nxt[25]), // 寄存器x25
		.gpr_26             (regfile.regs_nxt[26]), // 寄存器x26
		.gpr_27             (regfile.regs_nxt[27]), // 寄存器x27
		.gpr_28             (regfile.regs_nxt[28]), // 寄存器x28
		.gpr_29             (regfile.regs_nxt[29]), // 寄存器x29
		.gpr_30             (regfile.regs_nxt[30]), // 寄存器x30
		.gpr_31             (regfile.regs_nxt[31])  // 寄存器x31
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