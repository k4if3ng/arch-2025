// Contents of ./fetch.sv
`ifndef __FETCH_SV
`define __FETHC_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif 

module fetch 
    import common::*;
    import pipes::*;(

    output fetch_data_t dataF,
    input u32 raw_instr
);

    assign dataF.raw_instr = raw_instr;

endmodule

`endif
// Contents of ./dreg.sv
`ifndef __DREG_SV
`define __DREG_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module dreg
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
// Contents of ./core.sv
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

	always_ff @( posedge clk ) begin
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

	u1 flushF;

	assign flushF = ireq.valid & ~iresp.data_ok;

	always_ff @(posedge clk) begin
		if (flushF) begin
			dataF <= '0;
		end else begin
			dataF <= dataF_nxt;
		end
	end

	fetch fetch(
		.dataF     (dataF),
		.raw_instr (raw_instr)
	);

	pcselect pcselect(
		.pcplus4 (pc + 4),
		.pc_selected(pc_nxt)
	);

	creg_addr_t ra1, ra2;
	word_t rd1, rd2;

	decode decode(
		.dataF (dataF),
		.dataD (dataD),
		.ra1   (ra1),
		.ra2   (ra2),
		.rd1   (rd1),
		.rd2   (rd2)
	)

	

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
		.wen                (dataW_nxt.ctl.regwrite),
		.wdest              ({3'b0, dataM.dst}),
		.wdata              (dataW_nxt.writedata)
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

    reg [31:0] regs [0:31];

    always_ff @( posedge clk ) begin
        if (reset) begin
            for (int i = 0; i < 32; i++) begin
                regs[i] <= 32'h0;
            end
        end else if (wvalid && wa != 5'd0) begin
            regs[wa] <= wd[31:0];
        end
    end

    assign rd1 = (ra1 == 5'd0) ? 64'b0 : {32'b0, regs[ra1]};
    assign rd2 = (ra2 == 5'd0) ? 64'b0 : {32'b0, regs[ra2]};

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
        .ctl(ctl)
    );

    assign dataD.ctl = ctl;
    assign dataD.dst = dataF.raw_instr[11:7];

    assign dataD.srca = rd1;
    assign dataD.srcb = rd2;

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
    input alu_ctl_t   ctl,
    output word_t     result,
);

    shamt_t shamt;
    assign shamt = srca[4:0];
    // arith_t temp;

    always_comb begin
        exception = 1'b0;
        result = '0;

        unique case (ctl.aluop)
            ALU_ADD: begin
                result = srca + srcb;
            end
            ALU_SUB: begin
                result = srca - srcb;
            end
            ALU_SLL: begin
                result = srca << shamt;
            end
            ALU_SRL: begin
                result = srca >> shamt;
            end
            ALU_SRA: begin
                result = signed'(srca) >>> shamt;
            end
            ALU_SLT: begin
                result = (signed'(srca) < signed'(srcb)) ? 32'b1 : 32'b0;
            end
            ALU_AND: begin
                result = srca & srcb;
            end
            ALU_OR: begin
                result = srca | srcb;
            end
            ALU_XOR: begin
                result = srca ^ srcb;
            end
            ALU_SLTU: begin
                result = (srca < srcb) ? 32'b1 : 32'b0;
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
    output control_t ctl
);

    wire [6:0] f7 = raw_instr[6:0];
    wire [2:0] f3 = raw_instr[14:12];

    always_comb begin
        ctl = '0;
        unique case (f7)
            F3_ADDI: begin
                ctl.op = ADDI;
                ctl.aluop = ALU_ADD;
                ctl.reg_write = 1'b1;
            end
            default: begin
                
            end
        endcase
    end

endmodule

`endif
