`timescale 1ns / 1ps

module RegFile(
    input clk,
    input reset,
    input rg_wrt_en,
    input [4:0] rg_wrt_addr,
    input [4:0] rg_rd_addr1,
    input [4:0] rg_rd_addr2,
    input [31:0] rg_wrt_data,
    output [31:0] rg_rd_data1,
    output [31:0] rg_rd_data2
    );
    
    reg[31:0]   regfile[0:31];
    
    assign rg_rd_data1 = regfile[rg_rd_addr1];
    assign rg_rd_data2 = regfile[rg_rd_addr2];
    
    integer i;
    always @(posedge clk or reset) 
        begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                regfile[i] <= 32'h00000000;
        end
        else begin
            if (rg_wrt_en) 
                regfile[rg_wrt_addr] <= rg_wrt_data;
        end
     end
    
endmodule