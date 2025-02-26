// Contents of ./fetch.sv
`ifndef __FETCH_SV
`define __FETCH_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif 

module fetch 
    import common::*;
    import pipes::*;(
    input word_t pc,
    input u32 raw_instr,
    output fetch_data_t dataF
);

    assign dataF.instr.pc = pc;
    assign dataF.instr.raw_instr = raw_instr;
    assign dataF.raw_instr = raw_instr;

endmodule

`endif
// Contents of ./core.sv
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
// Contents of ./regfile.sv
`ifndef __REGFILE_SV
`define __REGFILE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module regfile
    import common::*;
    import pipes::*;(
    input  logic        clk, reset,
    input  creg_addr_t  ra1, ra2,
    output word_t       rd1, rd2,
    input  logic        wvalid,
    input  creg_addr_t  wa,
    input  word_t       wd
);

    word_t regs [31:0];
    word_t regs_nxt [31:0];

    always_comb begin
        for (int i = 0; i < 32; i++) begin
            if (wvalid && (i[4:0] == wa)) begin
                regs_nxt[i[4:0]] = wd; // 用组合逻辑向next_reg写入
            end else begin
                regs_nxt[i[4:0]] = regs[i[4:0]]; // 复制其他没有写入的寄存器
            end
        end
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            for (int i = 0; i < 32; i++) begin
                regs[i[4:0]] <= 64'h0;
            end
        end else begin
            for (int i = 0; i < 32; i++) begin
                regs[i[4:0]] <= regs_nxt[i[4:0]];
            end
        end
    end

    assign rd1 = (ra1 == 5'd0) ? 64'b0 : regs[ra1];
    assign rd2 = (ra2 == 5'd0) ? 64'b0 : regs[ra2];

endmodule
`endif

// Contents of ./pcselect.sv
`ifndef __PCSELECT_SV
`define __PCSELECT_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif 

module pcselect 
    import common::*;
    import pipes::*;(

    input u64 pcplus4,
    output u64 pc_selected
    
);


assign pc_selected = pcplus4;


endmodule


`endif


// Contents of ./decode.sv
`ifndef __DECODE_SV
`define __DECODE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "src/decoder.sv"
`else

`endif

module decode
    import common::*;
    import pipes::*;(
    input  fetch_data_t  dataF,
    output decode_data_t dataD,

    output creg_addr_t  ra1, ra2,
    input  word_t       rd1, rd2
);

    control_t ctl;

    decoder decoder(
        .raw_instr(dataF.raw_instr),
        .imm(dataD.imm),
        .ctl(ctl)
    );

    assign dataD.ctl = ctl;
    assign dataD.dst = dataF.raw_instr[11:7];
    assign dataD.instr = dataF.instr;
    assign dataD.srca = rd1;
    assign dataD.srcb = rd2;

endmodule

`endif
// Contents of ./mwreg.sv
`ifndef __MWBREG_SV
`define __MWBREG_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module mwreg
    import common::*;
    import pipes::*;(
    input  logic        clk, reset,
    input  mem_data_t dataM_new,
    input  logic        enable, flush,
    output mem_data_t dataM
);

    always_ff @(posedge clk) begin
        if (reset | flush) begin
            dataM <= '0;
        end else if (enable) begin
            dataM <= dataM_new;
        end
    end

endmodule

`endif

// Contents of ./alu.sv
`ifndef __ALU_SV
`define __ALU_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module alu
    import common::*;
    import pipes::*;(
    input word_t      srca, srcb,
    input alu_op_t    aluop,
    output word_t     aluout
);

    shamt_t shamt;
    assign shamt = srca[4:0];
    // arith_t temp;

    always_comb begin
        aluout = '0;

        unique case (aluop)
            ALU_ADD: begin
                aluout = srca + srcb;
            end
            ALU_SUB: begin
                aluout = srca - srcb;
            end
            ALU_AND: begin
                aluout = srca & srcb;
            end
            ALU_OR: begin
                aluout = srca | srcb;
            end
            ALU_XOR: begin
                aluout = srca ^ srcb;
            end
            default: begin
                aluout = '0;
            end
        endcase
    end



endmodule
`endif
// Contents of ./decoder.sv
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

    wire [6:0] opcode = raw_instr[6:0];
    wire [6:0] f7 = raw_instr[31:25];
    wire [2:0] f3 = raw_instr[14:12];

    always_comb begin
        ctl = '0;
        case (opcode)
            OPCODE_RTYPE: begin
                case (f3)
                    FUNC3_ADD: begin
                        if (f7 == FUNC7_SUB) begin
                            ctl.aluop = ALU_SUB;
                        end else begin
                            ctl.aluop = ALU_ADD;
                        end
                        ctl.reg_write = 1;
                    end
                    FUNC3_XOR: begin
                        ctl.aluop = ALU_XOR;
                        ctl.reg_write = 1;
                    end
                    FUNC3_OR: begin
                        ctl.aluop = ALU_OR;
                        ctl.reg_write = 1;
                    end
                    FUNC3_AND: begin
                        ctl.aluop = ALU_AND;
                        ctl.reg_write = 1;
                    end
                    default: begin
                        ctl.aluop = NOP;
                    end
                endcase
            end

            OPCODE_ITYPE: begin
                imm = {{52{raw_instr[31]}}, raw_instr[31:20]};  // I-type 指令的立即数
                case (f3)
                    FUNC3_ADDI: begin
                        ctl.aluop = ALU_ADD;
                        ctl.reg_write = 1;
                        ctl.alusrc = 1;
                    end
                    FUNC3_XORI: begin
                        ctl.aluop = ALU_XOR;
                        ctl.reg_write = 1;
                        ctl.alusrc = 1;
                    end
                    FUNC3_ORI: begin
                        ctl.aluop = ALU_OR;
                        ctl.reg_write = 1;
                        ctl.alusrc = 1;
                    end
                    FUNC3_ANDI: begin
                        ctl.aluop = ALU_AND;
                        ctl.reg_write = 1;
                        ctl.alusrc = 1;
                    end
                    default: begin
                        ctl.aluop = NOP;
                    end
                endcase
            end

            OPCODE_OPIMM: begin
                case (f3)
                    FUNC3_ADD: begin
                        if (f7 == FUNC7_SUB) begin
                            ctl.aluop = ALU_SUB;
                        end else begin
                            ctl.aluop = ALU_ADD;
                        end
                        ctl.reg_write = 1;
                    end
                    FUNC3_ANDI: begin
                        imm = {{52{raw_instr[31]}}, raw_instr[31:20]}; 
                        ctl.aluop = ALU_AND;
                        ctl.reg_write = 1;
                        ctl.alusrc = 1;
                    end
                    default: begin
                        ctl.aluop = NOP;
                    end
                endcase
            end
            
            default: begin
                ctl.aluop = NOP;
            end
        endcase
    end

endmodule

`endif
// Contents of ./emreg.sv
`ifndef __EMMREG_SV
`define __EMMREG_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module emreg
    import common::*;
    import pipes::*;(
    input  logic        clk, reset,
    input  exec_data_t dataE_new,
    input  logic        enable, flush,
    output exec_data_t dataE
);

    always_ff @(posedge clk) begin
        if (reset | flush) begin
            dataE <= '0;
        end else if (enable) begin
            dataE <= dataE_new;
        end
    end

endmodule

`endif

// Contents of ./idreg.sv
`ifndef __IDREG_SV
`define __IDREG_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module idreg
    import common::*;
    import pipes::*;(
    input  logic        clk, reset,
    input  fetch_data_t dataF_new,
    input  logic        enable, flush,
    output fetch_data_t dataF
);

    always_ff @( posedge clk ) begin
        if (reset | flush) begin
            dataF <= '0;
        end else if (enable) begin
            dataF <= dataF_new;
        end
    end

endmodule

`endif
// Contents of ./execute.sv
`ifndef __EXECUTE_SV
`define __EXECUTE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "src/alu.sv"
`endif

module execute
    import common::*;
    import pipes::*;(
    input  decode_data_t    dataD,
    output exec_data_t      dataE
);

    alu alu(
        .srca(dataD.srca),
        .srcb(dataD.ctl.alusrc ? dataD.imm : dataD.srcb),
        .aluop(dataD.ctl.aluop),
        .aluout(dataE.aluout)
    );

    assign dataE.dst = dataD.dst;
    assign dataE.ctl = dataD.ctl;
    assign dataE.instr = dataD.instr;


endmodule

`endif
// Contents of ./dereg.sv
`ifndef __DEREG_SV
`define __DEREG_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module dereg
    import common::*;
    import pipes::*;(
    input  logic        clk, reset,
    input  decode_data_t dataD_new,
    input  logic        enable, flush,
    output decode_data_t dataD
);

    always_ff @(posedge clk) begin
        if (reset | flush) begin
            dataD <= '0;
        end else if (enable) begin
            dataD <= dataD_new;
        end
    end

endmodule

`endif

