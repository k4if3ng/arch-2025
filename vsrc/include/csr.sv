`ifndef CSR_SV
`define CSR_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif

package csr_pkg;
  import common::*;

  parameter u12 CSR_MHARTID = 12'hf14;
  parameter u12 CSR_MIE = 12'h304;
  parameter u12 CSR_MIP = 12'h344;
  parameter u12 CSR_MTVEC = 12'h305;
  parameter u12 CSR_MSTATUS = 12'h300;
  parameter u12 CSR_MSCRATCH = 12'h340;
  parameter u12 CSR_MEPC = 12'h341;
  parameter u12 CSR_SATP = 12'h180;
  parameter u12 CSR_MCAUSE = 12'h342;
  parameter u12 CSR_MCYCLE = 12'hb00;
  parameter u12 CSR_MTVAL = 12'h343;
  parameter u12 CSR_PMPADDR0 = 12'h3b0;
  parameter u12 CSR_PMPCFG0 = 12'h3a0;
  parameter u12 CSR_MEDELEG = 12'h302;
  parameter u12 CSR_MIDELEG = 12'h303;
  parameter u12 CSR_STVEC = 12'h105;
  parameter u12 CSR_SSTATUS = 12'h100;
  parameter u12 CSR_SSCRATCH = 12'h140;
  parameter u12 CSR_SEPC = 12'h141;
  parameter u12 CSR_SCAUSE = 12'h142;
  parameter u12 CSR_STVAL = 12'h143;
  parameter u12 CSR_SIE = 12'h104;
  parameter u12 CSR_SIP = 12'h144;

  parameter u64 MSTATUS_MASK = 64'h7e79bb;
  parameter u64 SSTATUS_MASK = 64'h800000030001e000;
  parameter u64 MIP_MASK = 64'h333;
  parameter u64 MTVEC_MASK = ~(64'h2);
  parameter u64 MEDELEG_MASK = 64'h0;
  parameter u64 MIDELEG_MASK = 64'h0;

  typedef enum logic [1:0] { 
    PRIV_U = 2'b00,
    PRIV_S = 2'b01,
    PRIV_H = 2'b10,
    PRIV_M = 2'b11
  } priv_t;
  
  typedef struct packed {
    u1 sd;
    logic [MXLEN-2-36:0] wpri1;
    u2 sxl;
    u2 uxl;
    u9 wpri2;
    u1 tsr;
    u1 tw;
    u1 tvm;
    u1 mxr;
    u1 sum;
    u1 mprv;
    u2 xs;
    u2 fs;
    priv_t mpp;
    u2 wpri3;
    u1 spp;
    u1 mpie;
    u1 wpri4;
    u1 spie;
    u1 upie;
    u1 mie;
    u1 wpri5;
    u1 sie;
    u1 uie;
  } mstatus_t;

  typedef struct packed {
    u4  mode;
    u16 asid;
    u44 ppn;
  } satp_t;

typedef enum logic [1:0] {
  CSR_OP_NONE = 2'b00,
  CSR_OP_ECALL = 2'b01,
  CSR_OP_MRET = 2'b10,
  CSR_OP_EBREAK = 2'b11
} csr_op_t;

typedef struct packed {
	csr_op_t csrop;
	word_t mcause, mepc, mtval, mtvec;
	mstatus_t mstatus;
} excep_data_t;

typedef struct packed {
  mstatus_t mstatus;
  word_t mtvec;
  word_t mip;
  word_t mie;
  word_t mscratch;
  word_t mepc;
  word_t mcause;
  word_t mtval;
  word_t mcycle;
  word_t mhartid;
  satp_t satp;
} csr_t;

typedef struct packed {
  u10 rsvd2;
  u44 ppn;
  u2  rsvd1;
  u1  d;
  u1  a;
  u1  g;
  u1  u;
  u1  x;
  u1  w;
  u1  r;
  u1  v;
} pte_t;

  // Exception cause codes from mcause register
  // Interrupt bit (MSB) = 1
  parameter word_t EXC_S_SOFTWARE_INTERRUPT = {1'b1, {(MXLEN-1){1'b0}} | 'd1};
  parameter word_t EXC_M_SOFTWARE_INTERRUPT = {1'b1, {(MXLEN-1){1'b0}} | 'd3};
  parameter word_t EXC_S_TIMER_INTERRUPT    = {1'b1, {(MXLEN-1){1'b0}} | 'd5};
  parameter word_t EXC_M_TIMER_INTERRUPT    = {1'b1, {(MXLEN-1){1'b0}} | 'd7};
  parameter word_t EXC_S_EXTERNAL_INTERRUPT = {1'b1, {(MXLEN-1){1'b0}} | 'd9};
  parameter word_t EXC_M_EXTERNAL_INTERRUPT = {1'b1, {(MXLEN-1){1'b0}} | 'd11};
  
  // Exception bit (MSB) = 0
  parameter word_t EXC_INSTRUCTION_ADDR_MISALIGNED = 'd0;
  parameter word_t EXC_INSTRUCTION_ACCESS_FAULT    = 'd1;
  parameter word_t EXC_ILLEGAL_INSTRUCTION         = 'd2;
  parameter word_t EXC_BREAKPOINT                  = 'd3;
  parameter word_t EXC_LOAD_ADDR_MISALIGNED        = 'd4;
  parameter word_t EXC_LOAD_ACCESS_FAULT           = 'd5;
  parameter word_t EXC_STORE_ADDR_MISALIGNED       = 'd6;
  parameter word_t EXC_STORE_ACCESS_FAULT          = 'd7;
  parameter word_t EXC_ECALL_FROM_U                = 'd8;
  parameter word_t EXC_ECALL_FROM_S                = 'd9;
  parameter word_t EXC_ECALL_FROM_M                = 'd11;
  parameter word_t EXC_INSTRUCTION_PAGE_FAULT      = 'd12;
  parameter word_t EXC_LOAD_PAGE_FAULT             = 'd13;
  parameter word_t EXC_STORE_PAGE_FAULT            = 'd15;


endpackage

`endif
