`ifndef __FORWARD_SV
`define __FORWARD_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

// only aluout now
// ex_to_ex

module forward
    import common::*;
    import pipes::*;(
    input  logic        clk, reset,
    input  word_t       aluout,
    input  creg_addr_t  dst,
    input  u1           dst_valid,
    input  creg_addr_t  srca, srcb,
    input  u1           alusrc,
    output word_t       fwd_aluout,
    output u1           fwd_valid_a, fwd_valid_b
);

    // always_ff @(posedge clk or posedge reset) begin
    //     if (reset) begin
    //         fwd_valid_a <= 0;
    //         fwd_valid_b <= 0;
    //     end else begin
    //         fwd_valid_a <= dst_valid && (dst == srca);
    //         fwd_valid_b <= dst_valid && (dst == srcb) && ~alusrc;
    //     end
    // end

    assign fwd_valid_a = dst_valid && (dst == srca);
    assign fwd_valid_b = dst_valid && (dst == srcb) && ~alusrc;
    assign fwd_aluout = aluout;

endmodule
`endif