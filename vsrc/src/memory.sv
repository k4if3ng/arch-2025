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

    assign dreq.addr  = dataE.aluout;
    assign dreq.size = dataE.ctl.op inside {SD, LD} ? MSIZE8 : 
                    dataE.ctl.op inside {SW, LW, LWU} ? MSIZE4 :
                    dataE.ctl.op inside {SH, LH, LHU} ? MSIZE2 : MSIZE1;
    assign dreq.strobe = dataE.ctl.mem_write ? dataE.ctl.op inside {SD, LD} ? 8'hff : 
                                            dataE.ctl.op inside {SW, LW, LWU} ? 8'hf << (dataE.aluout[2:0]) :
                                            dataE.ctl.op inside {SH, LH, LHU} ? 8'h3 << (dataE.aluout[2:0]) : 8'h1 << (dataE.aluout[2:0]) : 0;
                                                
    assign dreq.data  = dataE.rd << {{dataE.aluout[2:0], 3'b0}};
	assign dreq.valid = load_use_hazard;

    word_t memout;
    u6 offset;

    always_comb begin
        dataM.ctl = dataE.ctl;
        dataM.dst = dataE.dst;
        dataM.instr = dataE.instr;
        
        offset = {dataE.aluout[2:0], 3'b0};

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

	u1 mem_access;
	assign mem_access = dataE.ctl.mem_write | dataE.ctl.mem_read;
    assign load_use_hazard = mem_access_state == WAITING;
	mem_access_state_t mem_access_state;

	always_ff @(posedge clk ) begin
		if (reset) begin
			mem_access_state <= IDLE;
			memout <= 0;
		end else begin
			case (mem_access_state)
				IDLE: begin
					if (mem_access) begin
						mem_access_state <= WAITING;
					end
				end
				WAITING: begin
					if (dresp.data_ok) begin
						mem_access_state <= OVER;
						memout <= dresp.data >> offset;
					end
				end
				OVER: begin
					if (flush) begin
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