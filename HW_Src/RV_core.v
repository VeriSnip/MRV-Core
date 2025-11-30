`timescale 1ns / 1ps

module RV_core #(
    parameter integer DATA_W = 32,
    parameter integer ADDR_W = 32
) (
    input wire clk_i,
    input wire arst_i,

    output wire [ADDR_W-1:0] i_addr_o,
    input wire [DATA_W-1:0] i_data_i,
    output wire [ADDR_W-1:0] d_addr_o,
    input wire [DATA_W-1:0] d_data_i,
    output wire [DATA_W-1:0] d_data_o,
    output wire d_we_o
);
  // SIGNALS
  `include "RV_core_generated_signals.vs"  // VS_NO_GENERATE

  wire [29:0] PCNext;
  wire [29:0] PCTarget;
  wire [29:0] PC;
  wire [31:0] Instr;

  // Control Unit signals
  wire [6:0] op;
  wire [2:0] func3;
  wire [6:0] func7;
  wire Zero;
  wire PCSrc;
  wire ResultSrc;
  wire MemWrite;
  wire ALUSrc;
  wire RegWrite;
  wire [1:0] ImmSrc;
  wire [2:0] ALUControl;

  // Arithmetic Logic Unit (ALU) signals
  wire [31:0] SrcA;
  wire [31:0] SrcB;
  wire [31:0] ALUResult;

  wire [31:0] ImmExt;
  wire [31:0] Result;
  wire [31:0] ReadData;
  wire [31:0] WriteData;


  // LOGIC
  

  always @(*) begin
    // Immediate generation based on instruction type
    case (ImmSrc)
      2'b00: ImmExt = {{20{Instr[31]}}, Instr[31:20]};  // I-type
      2'b01: ImmExt = {{20{Instr[31]}}, Instr[31:25], Instr[11:7]};  // S-type
      2'b10:
      ImmExt = {{19{Instr[31]}}, Instr[31], Instr[7], Instr[30:25], Instr[11:8], 1'b0};  // B-type
      2'b11: ImmExt = {Instr[31:12], 12'b0};  // U-type
      default: ImmExt = 32'b0;
    endcase
  end

  `include "reg_core_list.vs"  /*
  PC, 30, 0, , , PCNext
  */

  `include "FSM_mainControlUnit.vs"  /*
  Fetch:
    --> Decode
    AdrSrc = 1'b0
    IRWrite = 1'b1
    ALUSrcA = 2'b00
    ALUSrcB = 2'b10
    ALUOp = 2'b00
    ResultSrc = 2'b10
    PCUpdate = 1'b1
  Decode:
    (op == 3) | (op == 35) --> MemAdr
    op == 51 --> ExecuteR
    op == 19 --> ExecuteI
    op == 111 --> JAL
    op == 99 --> BEQ
    ALUSrcA = 2'b01
    ALUSrcB = 2'b01
    ALUOp = 2'b00
  MemAdr:
    op == 3 --> MemRead
    op == 35 --> MemWrite
    ALUSrcA = 2'b10
    ALUSrcB = 2'b01
    ALUOp = 2'b00
  MemRead:
    --> MemWB
    ResultSrc = 2'b10
    AdrSrc = 1b'1
  MemWB:
    --> Fetch
    ResultSrc = 2'b01
    RegWrite = 1b'1
  MemWrite:
    --> Fetch
    ResultSrc = 2'b00
    AdrSrc = 1b'1
    RegWrite = 1b'1
  ExecuteR:
    --> ALUWB
    ALUSrcA = 2'b10
    ALUSrcB = 2'b00
    ALUOp = 2'b10
  ALUWB:
    --> Fetch
    ResultSrc = 2'b00
    RegWrite = 1b'1
  ExecuteI:
    --> ALUWB
    ALUSrcA = 2'b10
    ALUSrcB = 2'b01
    ALUOp = 2'b10
  JAL:
    --> ALUWB
    ALUSrcA = 2'b01
    ALUSrcB = 2'b10
    ALUOp = 2'b00
    ResultSrc = 2'b00
    PCUpdate = 1'b1
  BEQ:
    --> Fetch
    ALUSrcA = 2'b10
    ALUSrcB = 2'b00
    ALUOp = 2'b01
    ResultSrc = 2'b00
    Branch = 1'b1
  */

  // Core Arithmetic Logic Unit
  ALU alu0 (
      .clk_i(clk_i),
      .arst_i(arst_i),
      .SrcA_i(ALUSrcA),
      .SrcB_i(ALUSrcB),
      .control_i(ALUControl),
      .result_o(ALUResult),
      .zero_o(Zero)
  );

  RegisterFile RF (
      .clk_i(clk_i),
      .arst_i(arst_i),
      .read_addr_1_i(Instr[19:15]),
      .read_data_1_o(RD1),
      .read_addr_2_i(Instr[24:20]),
      .read_data_2_o(RD2),
      .write_addr_i(Instr[11:7]),
      .write_data_i(Result),
      .write_enable_i(RegWrite)
  );

endmodule
