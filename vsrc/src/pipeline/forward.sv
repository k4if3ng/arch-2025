`ifndef __FORWARD_SV
`define __FORWARD_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module forward
    import common::*;
    import pipes::*; (
    input  fwd_data_t   ex_fwd,
    input  fwd_data_t   mem_fwd,
    input  fwd_data_t   load_fwd,
    input  decode_t     decode,
    output word_t       alusrca,
    output word_t       alusrcb
);

    always_comb begin
        if (load_fwd.valid && load_fwd.dst == decode.rs1 && decode.rs1 != 0) begin
            alusrca = load_fwd.data;
        end else if (ex_fwd.valid && ex_fwd.dst == decode.rs1 && decode.rs1 != 0) begin
            alusrca = ex_fwd.data;
        end else if (mem_fwd.valid && mem_fwd.dst == decode.rs1 && decode.rs1 != 0) begin
            alusrca = mem_fwd.data;
        end else begin
            alusrca = decode.srca;
        end
    
        if (load_fwd.valid && load_fwd.dst == decode.rs2 && decode.rs2 != 0) begin
            alusrcb = load_fwd.data;
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