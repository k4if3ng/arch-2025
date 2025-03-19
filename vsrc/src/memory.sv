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
        case (dataE.ctl.op)
            LD:  dataM.writedata = memout; // 64-bit load, 直接返回
            LW:  case (dataE.aluout[2:0] & 3'b100) // 计算 32-bit 偏移量
                    3'b000: dataM.writedata = {{32{memout[31]}}, memout[31:0]}; 
                    3'b100: dataM.writedata = {{32{memout[63]}}, memout[63:32]};
                    default: dataM.writedata = 64'b0;
                endcase
            LWU: case (dataE.aluout[2:0] & 3'b100)
                    3'b000: dataM.writedata = {32'b0, memout[31:0]};
                    3'b100: dataM.writedata = {32'b0, memout[63:32]};
                    default: dataM.writedata = 64'b0;
                endcase
            LH:  case (dataE.aluout[2:1]) // 计算 16-bit 偏移量
                    2'b00:  dataM.writedata = {{48{memout[15]}}, memout[15:0]};
                    2'b01:  dataM.writedata = {{48{memout[31]}}, memout[31:16]};
                    2'b10:  dataM.writedata = {{48{memout[47]}}, memout[47:32]};
                    2'b11:  dataM.writedata = {{48{memout[63]}}, memout[63:48]};
                    default: dataM.writedata = 64'b0;
                endcase
            LHU: case (dataE.aluout[2:1])
                    2'b00:  dataM.writedata = {48'b0, memout[15:0]};
                    2'b01:  dataM.writedata = {48'b0, memout[31:16]};
                    2'b10:  dataM.writedata = {48'b0, memout[47:32]};
                    2'b11:  dataM.writedata = {48'b0, memout[63:48]};
                    default: dataM.writedata = 64'b0;
                endcase
            LB:  case (dataE.aluout[2:0]) // 计算 8-bit 偏移量
                    3'b000: dataM.writedata = {{56{memout[7]}}, memout[7:0]};
                    3'b001: dataM.writedata = {{56{memout[15]}}, memout[15:8]};
                    3'b010: dataM.writedata = {{56{memout[23]}}, memout[23:16]};
                    3'b011: dataM.writedata = {{56{memout[31]}}, memout[31:24]};
                    3'b100: dataM.writedata = {{56{memout[39]}}, memout[39:32]};
                    3'b101: dataM.writedata = {{56{memout[47]}}, memout[47:40]};
                    3'b110: dataM.writedata = {{56{memout[55]}}, memout[55:48]};
                    3'b111: dataM.writedata = {{56{memout[63]}}, memout[63:56]};
                    default: dataM.writedata = 64'b0;
                endcase
            LBU: case (dataE.aluout[2:0])
                    3'b000: dataM.writedata = {56'b0, memout[7:0]};
                    3'b001: dataM.writedata = {56'b0, memout[15:8]};
                    3'b010: dataM.writedata = {56'b0, memout[23:16]};
                    3'b011: dataM.writedata = {56'b0, memout[31:24]};
                    3'b100: dataM.writedata = {56'b0, memout[39:32]};
                    3'b101: dataM.writedata = {56'b0, memout[47:40]};
                    3'b110: dataM.writedata = {56'b0, memout[55:48]};
                    3'b111: dataM.writedata = {56'b0, memout[63:56]};
                    default: dataM.writedata = 64'b0;
                endcase
            default: dataM.writedata = dataE.aluout;
        endcase
    end

endmodule
`endif