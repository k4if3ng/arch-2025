`ifndef __MEMORY_SV
`define __MEMORY_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module memory
    import common::*;
    import pipes::*;(
    input  exec_data_t  dataE,
    input  word_t       memout,
    output mem_data_t   dataM
);

    always_comb begin
        dataM.ctl = dataE.ctl;
        dataM.dst = dataE.dst;
        dataM.instr = dataE.instr;
        // dataM.writedata = dataE.ctl.mem_to_reg ? memout : dataE.aluout;
        if (dataE.ctl.mem_to_reg) begin
            if (dataE.ctl.op == LW) begin
                dataM.writedata = {{32{memout[31]}}, memout[31:0]};
            end else if (dataE.ctl.op == LWU) begin
                dataM.writedata = {32'b0, memout[31:0]};
            end else if (dataE.ctl.op == LH) begin
                dataM.writedata = {{48{memout[31]}}, memout[15:0]};
            end else if (dataE.ctl.op == LHU) begin
                dataM.writedata = {48'b0, memout[15:0]};
            end else if (dataE.ctl.op == LH) begin
                dataM.writedata = {{48{memout[31]}}, memout[15:0]};
            end else if (dataE.ctl.op == LHU) begin
                dataM.writedata = {48'b0, memout[15:0]};
            end else if (dataE.ctl.op == LB) begin
                dataM.writedata = {{56{memout[31]}}, memout[7:0]};
            end else if (dataE.ctl.op == LBU) begin
                dataM.writedata = {56'b0, memout[7:0]};
            end else begin
                dataM.writedata = memout;
            end
        end else begin
            dataM.writedata = dataE.aluout;
        end
    end

endmodule
`endif