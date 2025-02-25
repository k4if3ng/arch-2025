`ifndef __CORE_SV
`define __CORE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
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

	u32 raw_instr;

	assign raw_instr = iresp.data;

	fetch_data_t dataF, dataF_nxt;
	decode_data_t dataD, dataD_nxt;
	exec_data_t dataE, dataE_nxt;
	mem_data_t dataM, dataM_nxt;
	write_data_t dataW, dataW_nxt;

	assign dataW = dataW_nxt;

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
		.raw_instr (raw_instr),
		.dataF     (dataF_nxt)
	);

	pcselect pcselect(
		.pcplus4 (pc + 4),
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

	regfile regfile(
		.clk    (clk),
		.reset  (reset),
		.ra1    (ra1),
		.ra2    (ra2),
		.rd1    (rd1),
		.rd2    (rd2),
		.wvalid (dataM.ctl.reg_write),
		.wa     (dataM.dst),
		.wd     (data)
	);

    alu alu(
        .srca(dataD.srca),
        .srcb(dataD.ctl.alusrc ? dataD.imm : dataD.srcb),
        .aluop(dataD.ctl.aluop),
        .aluout(dataE_nxt.aluout)
    );

	

`ifdef VERILATOR
	DifftestInstrCommit DifftestInstrCommit(
		.clock              (clk),
		.coreid             (0),
		.index              (0),
		.valid              (1'b1),
		.pc                 (PCINIT),
		.instr              (0),
		.skip               (0),
		.isRVC              (0),
		.scFailed           (0),
		.wen                (dataM.ctl.reg_write),
		.wdest              ({3'b0, dataM.dst}),
		.wdata              (dataM_nxt.writedata)
	);

	DifftestArchIntRegState DifftestArchIntRegState (
		.clock              (clk),
		.coreid             (0),
		.gpr_0              (0),
		.gpr_1              (0),
		.gpr_2              (0),
		.gpr_3              (0),
		.gpr_4              (0),
		.gpr_5              (0),
		.gpr_6              (0),
		.gpr_7              (0),
		.gpr_8              (0),
		.gpr_9              (0),
		.gpr_10             (0),
		.gpr_11             (0),
		.gpr_12             (0),
		.gpr_13             (0),
		.gpr_14             (0),
		.gpr_15             (0),
		.gpr_16             (0),
		.gpr_17             (0),
		.gpr_18             (0),
		.gpr_19             (0),
		.gpr_20             (0),
		.gpr_21             (0),
		.gpr_22             (0),
		.gpr_23             (0),
		.gpr_24             (0),
		.gpr_25             (0),
		.gpr_26             (0),
		.gpr_27             (0),
		.gpr_28             (0),
		.gpr_29             (0),
		.gpr_30             (0),
		.gpr_31             (0)
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