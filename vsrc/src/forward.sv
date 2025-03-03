`ifndef __FORWARD_SV
`define __FORWARD_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module forward
    import common::*;
    import pipes::*; (
    input  fwd_data_t  ex_fwd,    // EX 阶段前递数据
    input  fwd_data_t  mem_fwd,   // MEM 阶段前递数据
    input  decode_t  decode,    // ID 阶段译码数据
    output word_t    alusrca,   // ALU 源操作数 A
    output word_t    alusrcb    // ALU 源操作数 B
);

    always_comb begin
        if (ex_fwd.valid && ex_fwd.dst == decode.rs1 && decode.rs1 != 0) begin
            alusrca = ex_fwd.data;
        end else if (mem_fwd.valid && mem_fwd.dst == decode.rs1 && decode.rs1 != 0) begin
            alusrca = mem_fwd.data;
        end else begin
            alusrca = decode.srca;
        end

        if (decode.is_imm) begin
            alusrcb = decode.imm;
        end else if (ex_fwd.valid && ex_fwd.dst == decode.rs2 && decode.rs2 != 0) begin
            alusrcb = ex_fwd.data;
        end else if (mem_fwd.valid && mem_fwd.dst == decode.rs2 && decode.rs2 != 0) begin
            alusrcb = mem_fwd.data;
        end else begin
            alusrcb = decode.srcb;
        end
    end

endmodule


`endif