`ifndef __CSRFILE_SV
`define __CSRFILE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "include/csr.sv"
`endif

module csrfile 
    import common::*;
    import pipes::*;
    import csr_pkg::*;(
    input  logic        clk, reset,
    input  csr_addr_t   raddr,
    input  csr_addr_t   waddr,
    input  u1           wen,        // CSR 写使能
    input  word_t       wdata,      // 写数据
    input  u1           ren,
    output word_t       rdata       // 读数据
);

    mstatus_t mstatus;
    word_t mtvec, mip, mie, mscratch, mhartid;
    word_t mcause, mtval, mepc, mcycle;
    satp_t satp;

    priv_t priv;

    always_comb begin
        unique case (raddr)
            CSR_MSTATUS: rdata = mstatus;
            CSR_MTVEC:   rdata = mtvec;
            CSR_MIP:     rdata = mip;
            CSR_MIE:     rdata = mie;
            CSR_MSCRATCH: rdata = mscratch;
            CSR_MEPC:    rdata = mepc;
            CSR_MCAUSE:  rdata = mcause;
            CSR_MTVAL:   rdata = mtval;
            CSR_MCYCLE:  rdata = mcycle;
            CSR_SATP:    rdata = satp;
            CSR_MHARTID: rdata = mhartid;
            default:     rdata = 0;
        endcase        
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            mstatus <= 0;
            mtvec <= 0;
            mip <= 0;
            mie <= 0;
            mscratch <= 0;
            mepc <= 0;
            mcause <= 0;
            mtval <= 0;
            mcycle <= 0;
            mhartid <= 0;
            satp <= 0;
            priv <= PRIV_M;
        end else begin
            if (wen) begin
                unique case (waddr)
                    CSR_MSTATUS: mstatus <= wdata & MSTATUS_MASK;
                    CSR_MTVEC:   mtvec <= wdata & MTVEC_MASK;
                    CSR_MIP:     mip <= wdata & MIP_MASK;
                    CSR_MIE:     mie <= wdata;
                    CSR_MSCRATCH: mscratch <= wdata;
                    CSR_MEPC:    mepc <= wdata;
                    CSR_MCAUSE:  mcause <= wdata;
                    CSR_MTVAL:   mtval <= wdata;
                    CSR_MCYCLE:  mcycle <= wdata;
                    CSR_SATP:    satp <= wdata;
                    default:     ;
                endcase
            end
            if (!wen || (wen && raddr != CSR_MCYCLE)) begin
                mcycle <= mcycle + 1; // Increment cycle count
            end
        end
    end

endmodule

`endif
