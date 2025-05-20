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
    input  logic clk, reset,
    input  satp_t satp,
    input  priv_t priviledgeMode,
    // 虚拟地址
    input  cbus_req_t  ireq,
    input cbus_resp_t oresp,
    // 物理地址
    output cbus_req_t  oreq,
    output  cbus_resp_t iresp
);
    typedef enum logic [3:0] {
        IDLE, PTW_L2, PTW_L1, PTW_L0, ACCESS, RESP
    } mmu_state_t;

    mmu_state_t state;
    pte_t current_pte;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            oreq <= '0;
            iresp <= '0;
        end else begin    
            case (state)
                IDLE: begin
                    if (ireq.valid) begin
                        // 外设访问处理：当地址在 0x0000_0000~0x7FFF_FFFF 范围时
                        if (ireq.addr[31] == 0) begin
                            state <= ACCESS;
                            oreq.valid <= 1;
                            oreq.is_write <= ireq.is_write;
                            oreq.size <= ireq.size;
                            oreq.addr <= ireq.addr;
                            oreq.strobe <= ireq.strobe;
                            oreq.data <= ireq.data;
                            oreq.len <= ireq.len;
                            oreq.burst <= ireq.burst;
                        end
                        // 机器模式下不进行地址转换
                        else if (priviledgeMode == PRIV_M || satp.mode == 0) begin
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
                            // 开始页表遍历 - 先取第二级页表
                            state <= PTW_L2;
                            oreq.valid <= 1;
                            oreq.is_write <= 0;
                            oreq.size <= MSIZE8;
                            // satp.ppn字段是基址, 加上VPN[2]索引得到L2页表项地址
                            oreq.addr <= {8'b0, satp.ppn, 12'b0} + {52'b0, ireq.addr[38:30], 3'b0};
                            oreq.strobe <= 0;
                            oreq.data <= 0;
                            oreq.len <= MLEN1;
                            oreq.burst <= AXI_BURST_FIXED;
                        end
                    end
                end
                
                PTW_L2: begin
                    if (oresp.ready && oresp.last) begin
                        current_pte <= pte_t'(oresp.data);
                        
                        // 如果是叶节点 (R或W或X位设置)
                        if (oresp.data[1] || oresp.data[2] || oresp.data[3]) begin
                            state <= ACCESS;
                            oreq.valid <= 1;
                            oreq.is_write <= ireq.is_write;
                            oreq.size <= ireq.size;
                            // 组合物理地址: PPN[2] + VPN[1:0] + offset
                            oreq.addr <= {
                                8'b0, 
                                oresp.data[53:28], // PPN[2]
                                ireq.addr[29:0]    // VPN[1:0] + 12位offset
                            };
                            oreq.strobe <= ireq.strobe;
                            oreq.data <= ireq.data;
                            oreq.len <= ireq.len;
                            oreq.burst <= ireq.burst;
                        end else begin
                            // 继续页表遍历 - 取第一级页表
                            state <= PTW_L1;
                            oreq.valid <= 1;
                            oreq.is_write <= 0;
                            oreq.size <= MSIZE8;
                            // 使用PPN作为下级页表基址
                            oreq.addr <= {8'b0, oresp.data[53:10], 12'b0} + {52'b0, ireq.addr[29:21], 3'b0};
                            oreq.strobe <= 0;
                            oreq.data <= 0;
                            oreq.len <= MLEN1;
                            oreq.burst <= AXI_BURST_FIXED;
                        end
                    end
                end
                
                PTW_L1: begin
                    if (oresp.ready && oresp.last) begin
                        current_pte <= pte_t'(oresp.data);
                        
                        // 如果是叶节点
                        if (oresp.data[1] || oresp.data[2] || oresp.data[3]) begin
                            state <= ACCESS;
                            oreq.valid <= 1;
                            oreq.is_write <= ireq.is_write;
                            oreq.size <= ireq.size;
                            // 组合物理地址: PPN[2:1] + VPN[0] + offset
                            oreq.addr <= {
                                8'b0, 
                                oresp.data[53:19], // PPN[2:1]
                                ireq.addr[20:0]    // VPN[0] + 12位offset
                            };
                            oreq.strobe <= ireq.strobe;
                            oreq.data <= ireq.data;
                            oreq.len <= ireq.len;
                            oreq.burst <= ireq.burst;
                        end else begin
                            // 继续页表遍历 - 取第零级页表
                            state <= PTW_L0;
                            oreq.valid <= 1;
                            oreq.is_write <= 0;
                            oreq.size <= MSIZE8;
                            oreq.addr <= {8'b0, oresp.data[53:10], 12'b0} + {52'b0, ireq.addr[20:12], 3'b0};
                            oreq.strobe <= 0;
                            oreq.data <= 0;
                            oreq.len <= MLEN1;
                            oreq.burst <= AXI_BURST_FIXED;
                        end
                    end
                end
                
                PTW_L0: begin
                    if (oresp.ready && oresp.last) begin
                        current_pte <= pte_t'(oresp.data);
                        
                        // 假设所有L0页表项都是有效的叶节点
                        state <= ACCESS;
                        oreq.valid <= 1;
                        oreq.is_write <= ireq.is_write;
                        oreq.size <= ireq.size;
                        // 组合物理地址: PPN + offset
                        oreq.addr <= {8'b0, oresp.data[53:10], ireq.addr[11:0]};
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
                    end
                end
                
                default: begin
                    state <= IDLE;
                    oreq.valid <= 0;
                    iresp.ready <= 0;
                end
            endcase
        end
    end

endmodule

`endif