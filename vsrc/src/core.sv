`ifndef __CORE_SV
`define __CORE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "src/fetch.sv"
`include "src/decode.sv"
`include "src/execute.sv"
`include "src/memory.sv"
`include "src/pipeline/if_id_reg.sv"
`include "src/pipeline/id_ex_reg.sv"
`include "src/pipeline/ex_mem_reg.sv"
`include "src/pipeline/mem_wb_reg.sv"
`include "src/pcselect.sv"
`include "src/pcupdate.sv"
`include "src/regfile.sv"
`include "src/forwarding.sv"
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
	
	u1 stallpc;
	assign stallpc = (ireq.valid & ~iresp.data_ok) | bubble;

	u1 stall_inst, stall_data;

	u1 stallF, stallD, stallE, stallM, stallW;
	u1 flushF, flushD, flushE, flushM, flushW;

u1 load_use_hazard;
// assign load_use_hazard = dataE.ctl.mem_to_reg && 
//                          ((dataE.dst == dataD.rs1) || (dataE.dst == dataD.rs2));

u1 load_use_hazard_a = dataE.ctl.mem_to_reg && (dataE.dst == dataD.rs1 && dataD.rs1 != 0);
u1 load_use_hazard_b = dataE.ctl.mem_to_reg && (dataE.dst == dataD.rs2 && dataD.rs2 != 0);


assign stallF = load_use_hazard | stallpc;

	// in lab1, this works
	// assign stallF = stallpc;
	assign stallD = stallF;
	assign stallE = stallD;
	assign stallM = stallE;
	assign flushF = 0;
	assign flushD = 0;
	assign flushE = 0;
	assign flushM = 0;

	u64 pc, pc_nxt;

	assign ireq.addr  = pc;
	assign ireq.valid = 1'b1;

	u32 raw_instr;
	assign raw_instr = iresp.data;

	word_t memout;
	assign dreq.addr  = dataE.aluout;
	assign dreq.size = dataE.ctl.op inside {SD, LD} ? MSIZE8 : 
					   dataE.ctl.op inside {SW, LW, LWU} ? MSIZE4 :
					   dataE.ctl.op inside {SH, LH, LHU} ? MSIZE2 : MSIZE1;
	assign dreq.strobe = dataE.ctl.mem_write ? dataE.ctl.op inside {SD, LD} ? 8'hff : 
											   dataE.ctl.op inside {SW, LW, LWU} ? 8'hf << (dataE.aluout[2:0]) :
											   dataE.ctl.op inside {SH, LH, LHU} ? 8'h3 << (dataE.aluout[2:0]) : 8'h1 << (dataE.aluout[2:0]) : 0;
											   	
	assign dreq.data  = dataE.rd << dataE.aluout[2:0] * 8;
	// assign dreq.data  = 0;

	u1 mem_access;
	assign mem_access = dataE.ctl.mem_write | dataE.ctl.mem_read;
	u1 bubble;
	assign dreq.valid = bubble;

	mem_access_state_t mem_access_state;

	word_t writedata;

	always_comb begin
		case (dataE.ctl.op)
			LD:  writedata = memout; // 64-bit load, 直接返回
			LW:  case (dataE.aluout[2:0] & 3'b100) // 计算 32-bit 偏移量
					3'b000: writedata = {{32{memout[31]}}, memout[31:0]}; 
					3'b100: writedata = {{32{memout[63]}}, memout[63:32]};
					default: writedata = 64'b0;
				endcase
			LWU: case (dataE.aluout[2:0] & 3'b100)
					3'b000: writedata = {32'b0, memout[31:0]};
					3'b100: writedata = {32'b0, memout[63:32]};
					default: writedata = 64'b0;
				endcase
			LH:  case (dataE.aluout[2:1]) // 计算 16-bit 偏移量
					2'b00:  writedata = {{48{memout[15]}}, memout[15:0]};
					2'b01:  writedata = {{48{memout[31]}}, memout[31:16]};
					2'b10:  writedata = {{48{memout[47]}}, memout[47:32]};
					2'b11:  writedata = {{48{memout[63]}}, memout[63:48]};
					default: writedata = 64'b0;
				endcase
			LHU: case (dataE.aluout[2:1])
					2'b00:  writedata = {48'b0, memout[15:0]};
					2'b01:  writedata = {48'b0, memout[31:16]};
					2'b10:  writedata = {48'b0, memout[47:32]};
					2'b11:  writedata = {48'b0, memout[63:48]};
					default: writedata = 64'b0;
				endcase
			LB:  case (dataE.aluout[2:0]) // 计算 8-bit 偏移量
					3'b000: writedata = {{56{memout[7]}}, memout[7:0]};
					3'b001: writedata = {{56{memout[15]}}, memout[15:8]};
					3'b010: writedata = {{56{memout[23]}}, memout[23:16]};
					3'b011: writedata = {{56{memout[31]}}, memout[31:24]};
					3'b100: writedata = {{56{memout[39]}}, memout[39:32]};
					3'b101: writedata = {{56{memout[47]}}, memout[47:40]};
					3'b110: writedata = {{56{memout[55]}}, memout[55:48]};
					3'b111: writedata = {{56{memout[63]}}, memout[63:56]};
					default: writedata = 64'b0;
				endcase
			LBU: case (dataE.aluout[2:0])
					3'b000: writedata = {56'b0, memout[7:0]};
					3'b001: writedata = {56'b0, memout[15:8]};
					3'b010: writedata = {56'b0, memout[23:16]};
					3'b011: writedata = {56'b0, memout[31:24]};
					3'b100: writedata = {56'b0, memout[39:32]};
					3'b101: writedata = {56'b0, memout[47:40]};
					3'b110: writedata = {56'b0, memout[55:48]};
					3'b111: writedata = {56'b0, memout[63:56]};
					default: writedata = 64'b0;
				endcase
			default: writedata = 64'b0;
		endcase
	end

	always_ff @(posedge clk ) begin
		if (reset) begin
			mem_access_state <= IDLE;
			bubble <= 0;
			memout <= 0;
		end else begin
			case (mem_access_state)
				IDLE: begin
					bubble <= 0;
					if (mem_access) begin
						mem_access_state <= WAITING;
						bubble <= 1;
					end
					load_use_hazard <= dataE.ctl.mem_to_reg && 
                          			   ((dataE.dst == dataD.rs1) || (dataE.dst == dataD.rs2));
				end
				WAITING: begin
					if (dresp.data_ok) begin
						bubble <= 0;
						mem_access_state <= OVER;
						memout <= dresp.data;
					end
				end
				OVER: begin
					load_use_hazard <= 0;
					if (!stallM) begin
						mem_access_state <= IDLE;
					end
				end
				default: 
					mem_access_state <= IDLE;
			endcase
		end
		
	end

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
		.rd2   (rd2)
	);

	execute execute(
		.alusrca (load_use_hazard_a ? writedata : alusrca),
		.alusrcb (load_use_hazard_b ? writedata : alusrcb),
		.dataD (dataD),
		.dataE (dataE_nxt)
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

	memory memory(
		.dataE  (dataE),
		.memout (writedata),
		.dataM  (dataM_nxt)
	);

	forwarding forwarding (
		.ex_fwd  	(fwd_data_t'({dataE.dst, dataE.aluout, dataE.ctl.reg_write && !dataE.ctl.mem_to_reg})),
		.mem_fwd  	(fwd_data_t'({dataM.dst, dataM.writedata, dataM.ctl.reg_write})),
		.decode 	(decode_t'({dataD.rs1, dataD.rs2, dataD.srca, dataD.srcb})),
		.alusrca 	(alusrca),
		.alusrcb 	(alusrcb)
	);


`ifdef VERILATOR
	DifftestInstrCommit DifftestInstrCommit(
		.clock              (clk),
		.coreid             (0),
		.index              (0),
		.valid              (!stallM),
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