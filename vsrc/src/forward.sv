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
    // input  logic        clk, reset,
    // input  word_t       aluout,
    // input  creg_addr_t  dst,
    // input  u1           dst_valid,
    // input  creg_addr_t  srca, srcb,
    // output word_t       fwd_data,
    // output u1           fwd_valid_a, fwd_valid_b
    input word_t ex_fwd_data,
    input u1 ex_fwd_valid,
    input creg_addr_t ex_dst,
    input word_t mem_fwd_data,
    input u1 mem_fwd_valid,
    input creg_addr_t mem_dst,
    input  creg_addr_t srca,
    input  creg_addr_t srcb,
    output word_t fwd_data_a,
    output word_t fwd_data_b,
    output u1 fwd_valid_a,
    output u1 fwd_valid_b
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

    // assign fwd_valid_a = dst_valid && (dst == srca) && (dst != 0);
    // assign fwd_valid_b = dst_valid && (dst == srcb) && (dst != 0);
    // assign fwd_data = aluout;

    always_comb begin
        fwd_valid_a = 0;
        fwd_valid_b = 0;
        fwd_data_a = 0;
        fwd_data_b = 0;

        if (mem_fwd_valid && mem_dst == srca && mem_dst != 0) begin
            fwd_valid_a = 1;
            fwd_data_a = mem_fwd_data;
        end
        if (mem_fwd_valid && mem_dst == srcb && mem_dst != 0) begin
            fwd_valid_b = 1;
            fwd_data_b = mem_fwd_data;
        end
        if (ex_fwd_valid && ex_dst == srca && ex_dst != 0) begin
            fwd_valid_a = 1;
            fwd_data_a = ex_fwd_data;
        end
        if (ex_fwd_valid && ex_dst == srcb && ex_dst != 0) begin
            fwd_valid_b = 1;
            fwd_data_b = ex_fwd_data;
        end
    end

endmodule
`endif