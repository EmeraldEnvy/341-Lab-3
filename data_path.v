module data_path #(
    parameter PC_W = 8 , // Program Counter
    parameter INS_W = 32 , // Instruction Width
    parameter RF_ADDRESS = 5 , // Register File Address
    parameter DATA_W = 32 , // Data WriteData
    parameter DM_ADDRESS = 9 , // Data Memory Address
    parameter ALU_CC_W = 4 // ALU Control Code Width
)(
    input               clk , // CLK in Datapath figure
    input               reset , // Reset in Datapath figure
    input               reg_write , // RegWrite in Datapath figure
    input               mem2reg , // MemtoReg in Datapath figure
    input               alu_src , // ALUSrc in Datapath figure
    input               mem_write , // MemWrite in Datapath Figure
    input               mem_read , // MemRead in Datapath Figure
    input [ALU_CC_W -1:0] alu_cc , // ALUCC in Datapath Figure
    output [6:0] opcode , // opcode in Datapath Figure
    output [6:0] funct7 , // Funct7 in Datapath Figure
    output [2:0] funct3 , // Func3 in Datapath Figure
    output [DATA_W -1:0] alu_result // Datapath_Result in Datapath Figure
);

wire [PC_W -1:0]    PC;
wire [PC_W -1:0]    PC_next;
wire [INS_W -1:0]   instruction;
assign PC_next = PC + 4;
FlipFlop pcreg(
    .clk(clk),
    .reset(reset),
    .d(PC_next),
    .q(PC)
);

Instmem intruction_mem(
    .addr(PC),
    .instruction(instruction)
);

assign opcode = instruction[6:0];
assign funct7 = instruction[31:25];
assign funct3 = instruction[14:12];
wire [DATA_W -1:0]  register1;
wire [DATA_W -1:0]  register2;
wire [DATA_W -1:0]  reg_wrt_data1;

RegFile rf(
    .clk(clk),
    .reset(reset), 
    .rg_wrt_en(reg_write),
    .rg_wrt_addr(instruction[11:7]),
    .rg_rd_addr1(instruction[19:15]),
    .rg_rd_addr2(instruction[24:20]),
    .rg_wrt_data(reg_wrt_data1),
    .rg_rd_data1(register1),
    .rg_rd_data2(register2)
);

wire [DATA_W -1:0]  alu_result1;
wire [DATA_W -1:0]  read_data1;
wire [DATA_W -1:0]  exitmem;

assign  reg_wrt_data1 = mem2reg ? read_data1 : alu_result1;

wire [DATA_W -1:0] d2;
ImmGen ext_imm(
    .InstCode(instruction[31:0]),
    .ImmOut(d2)
);

wire [DATA_W -1:0]  B_source;
Mux mux_inst(
    .D1(register2),
    .D2(d2),
    .S(alu_src),
    .Y(B_source)
);

assign  B_source = alu_src ? exitmem : register2;
    
alu_32 alu_module(
    .A_in(register1), 
    .B_in(B_source),
    .ALU_Sel(alu_cc),
    .ALU_Out(alu_result1),
    .Carry_Out(),
    .Zero(),
    .Overflow()
);

assign alu_result = alu_result1;

DataMem data_mem(
    .MemRead(mem_read),
    .MemWrite(mem_write),
    .addr(alu_result1[DM_ADDRESS -1:2]),
    .write_data(register2),
    .read_data(read_data1)
);

Mux2 mux2_inst(
    .D1(alu_result1),
    .D2(read_data1),
    .S(mem2reg),
    .Y(rg_wrt_data1)
);


endmodule // Datapath