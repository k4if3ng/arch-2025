`ifndef __MMU_SV
`define __MMU_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "include/csr.sv"
`endif

module mmu 
    import common::*;
    import csr_pkg::*;(
    input  logic    clk, reset,
    input  satp_t   satp,
    input  u2       priviledgeMode,
    input  cbus_req_t  ireq,
    input  cbus_resp_t oresp,
    output cbus_req_t  oreq,
    output cbus_resp_t iresp,
    output u1          skip
);

    typedef enum logic [3:0] {
        IDLE, PTW_L2, PTW_L1, PTW_L0, ACCESS, RESP
    } mmu_state_t;

    mmu_state_t state;
    
    // add to statisfy vivado
    logic pte_ready;
    pte_t pte_data;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            oreq <= '0;
            iresp <= '0;
            pte_ready <= 0;
            pte_data <= 0;
        end else begin
            if ((state == PTW_L2 || state == PTW_L1 || state == PTW_L0) && 
                oresp.ready && oresp.last) begin
                pte_data <= oresp.data;
                pte_ready <= 1;
            end else if (state == IDLE) begin
                pte_ready <= 0;
            end
            
            case (state)
                IDLE: begin
                    if (ireq.valid) begin
                        if (priv_t'(priviledgeMode) == PRIV_M || satp.mode != 4'd8) begin
                            state <= ACCESS;
                            oreq.valid <= 1;
                            oreq.is_write <= ireq.is_write;
                            oreq.size <= ireq.size;
                            oreq.addr <= ireq.addr;
                            oreq.strobe <= ireq.strobe;
                            oreq.data <= ireq.data;
                            oreq.len <= ireq.len;
                            oreq.burst <= ireq.burst;
                        end else begin
                            state <= PTW_L2;
                            oreq.valid <= 1;
                            oreq.is_write <= 0;
                            oreq.size <= MSIZE8;
                            oreq.addr <= {8'b0, satp.ppn, 12'b0} + {52'b0, ireq.addr[38:30], 3'b0};
                            oreq.strobe <= 0;
                            oreq.data <= 0;
                            oreq.len <= MLEN1;
                            oreq.burst <= AXI_BURST_FIXED;
                        end
                    end
                end
                
                PTW_L2: begin
                    if (pte_ready) begin
                        pte_ready <= 0;
                        if (pte_data.w || pte_data.r || pte_data.x) begin
                            state <= ACCESS;
                            oreq.valid <= 1;
                            oreq.is_write <= ireq.is_write;
                            oreq.size <= ireq.size;
                            oreq.addr <= {8'b0, pte_data[53:28], ireq.addr[29:0]};
                            oreq.strobe <= ireq.strobe;
                            oreq.data <= ireq.data;
                            oreq.len <= ireq.len;
                            oreq.burst <= ireq.burst;
                        end else begin
                            state <= PTW_L1;
                            oreq.valid <= 1;
                            oreq.is_write <= 0;
                            oreq.size <= MSIZE8;
                            oreq.addr <= {8'b0, pte_data[53:10], 12'b0} + {52'b0, ireq.addr[29:21], 3'b0};
                            oreq.strobe <= 0;
                            oreq.data <= 0;
                            oreq.len <= MLEN1;
                            oreq.burst <= AXI_BURST_FIXED;
                        end
                    end
                end
                
                PTW_L1: begin
                    if (pte_ready) begin
                        pte_ready <= 0;
                        if (pte_data.w || pte_data.r || pte_data.x) begin
                            state <= ACCESS;
                            oreq.valid <= 1;
                            oreq.is_write <= ireq.is_write;
                            oreq.size <= ireq.size;
                            oreq.addr <= {8'b0, pte_data[53:19], ireq.addr[20:0]};
                            oreq.strobe <= ireq.strobe;
                            oreq.data <= ireq.data;
                            oreq.len <= ireq.len;
                            oreq.burst <= ireq.burst;
                        end else begin
                            state <= PTW_L0;
                            oreq.valid <= 1;
                            oreq.is_write <= 0;
                            oreq.size <= MSIZE8;
                            oreq.addr <= {8'b0, pte_data[53:10], 12'b0} + {52'b0, ireq.addr[20:12], 3'b0};
                            oreq.strobe <= 0;
                            oreq.data <= 0;
                            oreq.len <= MLEN1;
                            oreq.burst <= AXI_BURST_FIXED;
                        end
                    end
                end
                
                PTW_L0: begin
                    if (pte_ready) begin
                        pte_ready <= 0;
                        state <= ACCESS;
                        oreq.valid <= 1;
                        oreq.is_write <= ireq.is_write;
                        oreq.size <= ireq.size;
                        oreq.addr <= {8'b0, pte_data[53:10], ireq.addr[11:0]};
                        oreq.strobe <= ireq.strobe;
                        oreq.data <= ireq.data;
                        oreq.len <= ireq.len;
                        oreq.burst <= ireq.burst;
                    end
                end
                
                ACCESS: begin
                    if (oresp.ready && oresp.last) begin
                        state <= RESP;
                        oreq.valid <= 0;
                        iresp.ready <= 1;
                        iresp.last <= 1;
                        iresp.data <= oresp.data;
                    end
                end
                
                RESP: begin
                    if (iresp.ready) begin
                        state <= IDLE;
                        iresp.ready <= 0;
                        iresp.last <= 0;
                        iresp.data <= 0;
                        skip <= oreq.addr[31] == 0;
                    end
                end
                
                default: begin
                    state <= IDLE;
                    oreq.valid <= 0;
                    iresp.ready <= 0;
                    skip <= 0;
                end
            endcase
        end
    end

endmodule

`endif