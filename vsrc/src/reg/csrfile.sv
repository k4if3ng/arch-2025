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
    input  u1           wen,
    input  word_t       wdata,
    output word_t       rdata,
    input  excep_data_t excep_wdata,
    output excep_data_t excep_rdata,
    input  priv_t       priv,
    output priv_t       priv_nxt,
    input  word_t       pc,
    input  csr_op_t     csrop
);

    csr_t csrs;
    csr_t csrs_nxt;

    always_comb begin
        unique case (raddr)
            CSR_MSTATUS: rdata = csrs.mstatus;
            CSR_MTVEC:   rdata = csrs.mtvec;
            CSR_MIP:     rdata = csrs.mip;
            CSR_MIE:     rdata = csrs.mie;
            CSR_MSCRATCH: rdata = csrs.mscratch;
            CSR_MEPC:    rdata = csrs.mepc;
            CSR_MCAUSE:  rdata = csrs.mcause;
            CSR_MTVAL:   rdata = csrs.mtval;
            CSR_MCYCLE:  rdata = csrs.mcycle;
            CSR_SATP:    rdata = csrs.satp;
            CSR_MHARTID: rdata = csrs.mhartid;
            default:     rdata = '0;
        endcase
        
        excep_rdata = '0;
        excep_rdata.mstatus = csrs.mstatus;
        excep_rdata.mepc = csrs.mepc;
        excep_rdata.mcause = csrs.mcause;
        excep_rdata.mtvec = csrs.mtvec;
        excep_rdata.mtval = csrs.mtval;
    end

    always_comb begin
        csrs_nxt = csrs;
        csrs_nxt.mcycle = csrs.mcycle + 1; // Increment cycle count
        priv_nxt = priv;

        // // change priv in memory stage
        // unique case (csrop)
        //     CSR_OP_MRET:    priv_nxt = PRIV_U;
        //     CSR_OP_ECALL: begin 
        //         priv_nxt = PRIV_M;
        //     end
        //     default:        priv_nxt = priv;
        // endcase

        // update mstatus in write back stage
        unique case (excep_wdata.csrop)
            CSR_OP_MRET: begin
                csrs_nxt.mstatus.mie  = csrs.mstatus.mpie;
                csrs_nxt.mstatus.mpie = 1'b1;
                csrs_nxt.mstatus.mpp  = PRIV_U;
                priv_nxt = csrs.mstatus.mpp;
            end
            CSR_OP_ECALL: begin
                csrs_nxt.mepc              = pc;
                csrs_nxt.mstatus.mpie      = csrs.mstatus.mie;
                csrs_nxt.mstatus.mpie      = 1'b1;
                csrs_nxt.mstatus.mie       = 1'b0;
                csrs_nxt.mstatus.mpp       = priv;
                priv_nxt                   = PRIV_M;
                unique case (priv)
                    PRIV_U: csrs_nxt.mcause = 64'h8;
                    PRIV_S: csrs_nxt.mcause = 64'h9;
                    PRIV_H: csrs_nxt.mcause = 64'hA;
                    PRIV_M: csrs_nxt.mcause = 64'hB;
                    default: csrs_nxt.mcause = 64'hFFFFFFFFFFFFFFFF;
                endcase
            end
            default: ;
        endcase

        if (wen) begin
            unique case (waddr)
                CSR_MSTATUS: csrs_nxt.mstatus = wdata & MSTATUS_MASK;
                CSR_MTVEC:   csrs_nxt.mtvec = wdata & MTVEC_MASK;
                CSR_MIP:     csrs_nxt.mip = wdata & MIP_MASK;
                CSR_MIE:     csrs_nxt.mie = wdata;
                CSR_MSCRATCH: csrs_nxt.mscratch = wdata;
                CSR_MEPC:    csrs_nxt.mepc = wdata;
                CSR_MCAUSE:  csrs_nxt.mcause = wdata;
                CSR_MTVAL:   csrs_nxt.mtval = wdata;
                CSR_MCYCLE:  csrs_nxt.mcycle = wdata;
                CSR_SATP:    csrs_nxt.satp = wdata;
                default:     ;
            endcase
        end
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            csrs <= '0;
        end else begin
            csrs <= csrs_nxt;
        end
    end

endmodule

`endif
