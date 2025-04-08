`ifndef __VTOP_SV
`define __VTOP_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "src/core.sv"
`include "util/IBusToCBus.sv"
`include "util/DBusToCBus.sv"
`include "util/CBusArbiter.sv"

`endif
module VTop
  import common::*;
  import csr_pkg::*;
(
    input logic clk,
    reset,
    output cbus_req_t oreq,
    input cbus_resp_t oresp,
    input logic trint,
    swint,
    exint
);

  cbus_req_t oreq_raw;
  cbus_resp_page_t oresp_page;

  ibus_req_t ireq;
  ibus_resp_page_t iresp;
  dbus_req_t dreq;
  dbus_resp_page_t dresp;
  cbus_req_t icreq, dcreq;
  cbus_resp_page_t icresp, dcresp;

  mode_t mode;
  satp_t satp;

  core core (.*);

  IBusToCBus icvt (.*);
  DBusToCBus dcvt (.*);

  CBusArbiter mux (
      .ireqs ({icreq, dcreq}),
      .iresps({icresp, dcresp}),
      .*
  );

  // always_ff @(posedge clk) begin
    // if (~reset) begin
      // $display("icreq %x, %x", icreq.valid, icreq.addr);
      // if (oreq.valid || dcreq.addr == 64'h40600004) $display("dcreq %x, %x, oreq %x, %x, dcresp %x", dcreq.addr, dcreq.valid, oreq.valid, oreq.addr, dcresp.ready);
    // end
  // end


endmodule



`endif
