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
  assign PCNext = PCSrc ? PCTarget[31:2] : (PC + 1);

  assign i_addr_o = {PC, 2'b00};  // Word aligned
  assign Instr = i_data_i;
  assign d_addr_o = ALUResult;
  assign d_data_o = WriteData;
  assign d_we_o = MemWrite;

  assign SrcB = ALUSrc ? ImmExt : WriteData;

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

  // Core Arithmetic Logic Unit
  ALU alu0 (
      .clk_i(clk_i),
      .arst_i(arst_i),
      .SrcA_i(SrcA),
      .SrcB_i(SrcB),
      .control_i(alu_control),
      .result_o(alu_result),
      .zero_o(alu_zero)
  );

  RegisterFile RF (
      .clk_i(clk_i),
      .arst_i(arst_i),
      .read_addr_1_i(Instr[19:15]),
      .read_data_1_o(SrcA),
      .read_addr_2_i(Instr[24:20]),
      .read_data_2_o(WriteData),
      .write_addr_i(Instr[11:7]),
      .write_data_i(Result),
      .write_enable_i(RegWrite)
  );

  // Core Control Unit
  ControlUnit control_unit0 (
      .op_i(Instr[6:0]),
      .func3_i(Instr[11:7]),
      .func7_i(Instr[31:25]),
      .zero_i(Zero),

      .PCSrc_o(PCSrc),
      .ResultSrc_o(ResultSrc),
      .MemWrite_o(MemWrite),
      .ALUSrc_o(ALUSrc),
      .RegWrite_o(RegWrite),
      .ImmSrc_o(ImmSrc),
      .ALUControl_o(ALUControl)
  );

endmodule
