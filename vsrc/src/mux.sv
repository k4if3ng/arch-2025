`ifndef __MUX_SV
`define __MUX_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module mux
    import common::*;
    import pipes::*;(
    input fwd_data_t ex_fwd, mem_fwd,
    input decode_data_t dataD,
    output word_t alusrca,
    output word_t alusrcb
);

    assign alusrcb =                dataD.ctl.alusrc ? dataD.imm : 
        mem_fwd.valid && mem_fwd.dst == dataD.rs2 ? mem_fwd.data :
           ex_fwd.valid && ex_fwd.dst == dataD.rs2 ? ex_fwd.data : dataD.srcb;
    assign alusrca = mem_fwd.valid && mem_fwd.dst == dataD.rs1 ? mem_fwd.data :
                        ex_fwd.valid && ex_fwd.dst == dataD.rs1 ? ex_fwd.data : dataD.srca;



endmodule
`endif