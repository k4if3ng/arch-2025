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

    always_ff @(posedge clk) begin
        if (reset) begin
            for (int i = 0; i < 32; i++) begin
                regs[i] <= 64'h0;
            end
        end else if (wvalid && wa != 5'd0) begin
            regs[wa] <= wd;
        end
    end

    assign rd1 = (ra1 == 5'd0) ? 64'b0 : regs[ra1];
    assign rd2 = (ra2 == 5'd0) ? 64'b0 : regs[ra2];

endmodule
`endif
