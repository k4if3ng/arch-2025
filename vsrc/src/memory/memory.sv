`ifndef __MEMORY_SV
`define __MEMORY_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module memory
    import common::*;
    import pipes::*;(
    input  logic        clk, reset,
    input  u1           flush,
    input  exec_data_t  dataE,
    input  dbus_resp_t  dresp,
    output dbus_req_t   dreq,
    output u1           load_use_hazard,
    output mem_data_t   dataM
);

    u6 offset_bit;
    u3 offset_byte;
    word_t memout;
	mem_access_state_t mem_access_state;

    assign offset_byte = dataE.aluout[2:0];
    assign offset_bit = {dataE.aluout[2:0], 3'b0};
 
    assign dreq.addr  = dataE.aluout;
    assign dataM.mem_addr = dataE.aluout;
    assign dataM.csr_waddr = dataE.csr_waddr;
    assign dataM.csr_data = dataE.csr_data;

    assign dreq.size = dataE.ctl.op inside {SD, LD}      ? MSIZE8 : 
                       dataE.ctl.op inside {SW, LW, LWU} ? MSIZE4 :
                       dataE.ctl.op inside {SH, LH, LHU} ? MSIZE2 : MSIZE1;

    assign dreq.strobe = dataE.ctl.op inside {SD} ? 8'hff : 
                         dataE.ctl.op inside {SW} ? 8'hf << offset_byte :
                         dataE.ctl.op inside {SH} ? 8'h3 << offset_byte : 
                         dataE.ctl.op inside {SB} ? 8'h1 << offset_byte : 0;
                                                
    assign dreq.data  = dataE.rd << offset_bit;
	assign dreq.valid = load_use_hazard;

    assign load_use_hazard = mem_access_state == WAITING;

    always_comb begin
        dataM.ctl = dataE.ctl;
        dataM.dst = dataE.dst;
        dataM.instr = dataE.instr;

        case(dataE.ctl.op)
            LD: begin
                dataM.writedata = memout;
            end
            LW: begin
                dataM.writedata = {{32{memout[31]}}, memout[31:0]};
            end
            LH: begin
                dataM.writedata = {{48{memout[15]}}, memout[15:0]};
            end
            LB: begin
                dataM.writedata = {{56{memout[7]}}, memout[7:0]};
            end
            LWU: begin
                dataM.writedata = {{32{1'b0}}, memout[31:0]};
            end
            LHU: begin
                dataM.writedata = {{48{1'b0}}, memout[15:0]};
            end
            LBU: begin
                dataM.writedata = {{56{1'b0}}, memout[7:0]};
            end
            default: begin
                dataM.writedata = dataE.aluout;
            end
        endcase
    end

	always_ff @(posedge clk ) begin
		if (reset) begin
			mem_access_state <= IDLE;
			memout <= 0;
		end else begin
			case (mem_access_state)
				IDLE: begin
					if (dataE.ctl.mem_access) begin
						mem_access_state <= WAITING;
					end
				end
				WAITING: begin
					if (dresp.data_ok) begin
						mem_access_state <= OVER;
						memout <= dresp.data >> offset_bit;
					end
				end
				OVER: begin
					if (flush || !dataE.ctl.mem_access) begin
						mem_access_state <= IDLE;
					end
				end
				default: 
					mem_access_state <= IDLE;
			endcase
		end
		
	end


endmodule
`endif