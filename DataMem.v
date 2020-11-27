`timescale 1ns / 1ps
module DataMem(
    input MemRead,
    input MemWrite,
    input wire [8:0] addr,
    input [31:0] write_data,
    output reg [31:0] read_data
    );
    
    reg [31:0] memory [0:127];
    integer i;

initial
        begin
        read_data = 0;
        for (i = 0; i < 128; i = i + 1) begin
            memory[i] = i; end
        end
always @(*)
    begin
    if (MemWrite)
        memory[addr] = write_data;
    if (MemRead)
        read_data = memory[addr];
    end
endmodule
