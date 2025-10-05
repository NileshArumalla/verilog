

// datapath.v
module datapath (
    input         clk, reset,
    input  [1:0]  ResultSrc,
    input         PCSrc,Jalr, ALUSrc,
    input         RegWrite,Op5,
    input  [1:0]  ImmSrc,Store,
	 input  [2:0]  Load,
    input  [3:0]  ALUControl,
    output        Zero,ALUR0,
    output [31:0] PC,
    input  [31:0] Instr,
    output [31:0] Mem_WrAddr, Mem_WrData,
    input  [31:0] ReadData,
    output [31:0] Result
);

wire [31:0] PCNext,PCNextJalr, PCPlus4, PCTarget;
wire [31:0] ImmExt, SrcA, SrcB, WriteData, ALUResult;
wire [31:0] ReadDataMem, AUIPc, URd;
wire [2:0] func3;


// next PC logic
reset_ff #(32) pcreg(clk, reset, PCNext, PC);
adder          pcadd4(PC, 32'd4, PCPlus4);
adder          pcaddbranch(PC, ImmExt, PCTarget);
mux2 #(32)     pcjalrmux(PCNext, ALUResult, Jalr, PCNextJalr);
mux2 #(32)     pcmux(PCPlus4, PCTarget, PCSrc, PCNext);

// register file logic
reg_file       rf (clk, RegWrite, Instr[19:15], Instr[24:20], Instr[11:7], Result, SrcA, WriteData);
imm_extend     ext (Instr[31:7], ImmSrc, ImmExt);

// ALU logic
mux2 #(32)     srcbmux(WriteData, ImmExt, ALUSrc, SrcB);
alu            alu (SrcA, SrcB, ALUControl, ALUResult, Zero);
//mux3 #(32)     resultmux1(ALUResult, ReadData, PCPlus4, ResultSrc, Result);

// load data
load_extend     ldextd (ReadData, Load, ReadDataMem,Mem_WrAddr);

// lui and auipc
adder       auipcadd  (PC, {Instr[31:12], 12'b0}, AUIPc);
mux2 #(32)  luipcmux  (AUIPc, {Instr[31:12], 12'b0},Op5, URd);
mux4 #(32)  resultmux (ALUResult, ReadDataMem, PCPlus4, URd, ResultSrc, Result);

// store data
store_extend strextd (WriteData, Store, Mem_WrData);

assign Mem_WrAddr = ALUResult;
assign ALUR0 = ALUResult[0];
//assign Mem_WrData = WriteData;
//assign Mem_WrAddr = ALUResult;

endmodule

