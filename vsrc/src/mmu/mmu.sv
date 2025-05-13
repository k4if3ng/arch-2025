`ifndef __MMU_SV
`define __MMU_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "include/csr.sv"
`endif

module mmu
    import common::*;
    import pipes::*;
    import csr_pkg::*;(
    input  logic        clk, reset,
    input  u1           enable,
    input  priv_t       priv,
    input  satp_t       satp,
    input  word_t       vaddr,
    output word_t       paddr,
    output u1           stall
);

    typedef enum logic[1:0] { 
        IDLE = 2'b00,
        LOOKUP = 2'b01,
        WAIT = 2'b10,
        DONE = 2'b11
    } state_t;


endmodule

`endif