`timescale 1ps / 1ps

module ControlUnit (
    input wire [6:0] op_i,
    input wire [2:0] func3_i,
    input wire [6:0] func7_i,

    output reg PCSrc_o,
    output reg ResultSrc_o,
    output reg MemWrite_o,
    output reg ALUSrc_o,
    output reg RegWrite_o,
    output reg [1:0] ImmSrc_o,
    output reg [2:0] ALUControl_o
);
  // Control signals
  // PCSrc: 0 = PC + 4, 1 = Branch target
  // ResultSrc: 0 = ALU result, 1 = Memory data
  // MemWrite: 0 = No write, 1 = Write to memory
  // ALUSrc: 0 = Register, 1 = Immediate
  // RegWrite: 0 = No write, 1 = Write to register
  // ImmSrc: 00 = I-type, 01 = S-type, 10 = B-type, 11 = U-type
  // ALUControl: 000 = ADD, 001 = SLL, 010 = SLT, 011 = SLTU, 100 = XOR,
  //             101 = SRL, 110 = OR, 111 = AND

  always_comb begin : CU
    // Default values
    PCSrc_o = 1'b0;
    ResultSrc_o = 1'b0;
    MemWrite_o = 1'b0;
    ALUSrc_o = 1'b0;
    RegWrite_o = 1'b0;
    ImmSrc_o = 2'b00;
    ALUControl_o = 3'b000;

    case (op_i)
      7'b0110011: begin  // R-type
        RegWrite_o = 1'b1;
        ALUSrc_o   = 1'b0;
        ImmSrc_o   = 2'b00;
        case (func3_i)
          3'b000: begin
            if (func7_i[5]) ALUControl_o = 3'b001;  // SUB
            else ALUControl_o = 3'b000;  // ADD
          end
          3'b001:  ALUControl_o = 3'b010;  // SLL
          3'b010:  ALUControl_o = 3'b011;  // SLT
          3'b011:  ALUControl_o = 3'b100;  // SLTU
          3'b100:  ALUControl_o = 3'b101;  // XOR
          3'b101: begin
            if (func7_i[5]) ALUControl_o = 3'b110;  // SRA
            else ALUControl_o = 3'b111;  // SRL
          end
          3'b110:  ALUControl_o = 3'b001;  // OR
          3'b111:  ALUControl_o = 3'b010;  // AND
          default: ALUControl_o = 3'b000;  // ADD
        endcase
      end
      7'b0010011: begin  // I-type ALU
        RegWrite_o = 1'b1;
        ALUSrc_o   = 1'b1;
        ImmSrc_o   = 2'b00;
        case (func3_i)
          3'b000:  ALUControl_o = 3'b000;  // ADDI
          3'b001:  ALUControl_o = 3'b010;  // SLLI
          3'b010:  ALUControl_o = 3'b011;  // SLTI
          3'b011:  ALUControl_o = 3'b100;  // SLTIU
          3'b100:  ALUControl_o = 3'b101;  // XORI
          3'b101: begin
            if (func7_i[5]) ALUControl_o = 3'b110;  // SRAI
            else ALUControl_o = 3'b111;  // SRLI
          end
          3'b110:  ALUControl_o = 3'b001;  // ORI
          3'b111:  ALUControl_o = 3'b010;  // ANDI
          default: ALUControl_o = 3'b000;  // ADDI
        endcase
      end
      7'b0000011: begin  // Load
        RegWrite_o = 1'b1;
        ALUSrc_o = 1'b1;
        ImmSrc_o = 2'b00;
        ResultSrc_o = 1'b1;
        ALUControl_o = 3'b000;  // ADD for address calculation
      end
      7'b0100011: begin  // Store
        MemWrite_o = 1'b1;
        ALUSrc_o = 1'b1;
        ImmSrc_o = 2'b01;
        ALUControl_o = 3'b000;  // ADD for address calculation
      end
      7'b1100011: begin  // Branch
        ALUSrc_o = 1'b0;
        ImmSrc_o = 2'b10;
        ALUControl_o = 3'b001;  // SUB for comparison
        PCSrc_o = 1'b1;  // Assume branch taken for simplicity
      end
      7'b1101111: begin  // JAL
        RegWrite_o = 1'b1;
        ALUSrc_o = 1'b1;
        ImmSrc_o = 2'b11;
        ALUControl_o = 3'b000;  // ADD for address calculation
        PCSrc_o = 1'b1;
      end
      7'b1100111: begin  // JALR
        RegWrite_o = 1'b1;
        ALUSrc_o = 1'b1;
        ImmSrc_o = 2'b00;
        ALUControl_o = 3'b000;  // ADD for address calculation
        PCSrc_o = 1'b1;
      end
      7'b0110111: begin  // LUI
        RegWrite_o = 1'b1;
        ALUSrc_o = 1'b1;
        ImmSrc_o = 2'b11;
        ALUControl_o = 3'b000;  // ADD for loading immediate
      end
      7'b0010111: begin  // AUIPC
        RegWrite_o = 1'b1;
        ALUSrc_o = 1'b1;
        ImmSrc_o = 2'b11;
        ALUControl_o = 3'b000;  // ADD for PC + immediate
      end
      default: begin
        // NOP or unsupported instruction
        PCSrc_o = 1'b0;
        ResultSrc_o = 1'b0;
        MemWrite_o = 1'b0;
        ALUSrc_o = 1'b0;
        RegWrite_o = 1'b0;
        ImmSrc_o = 2'b00;
        ALUControl_o = 3'b000;
      end
    endcase
  end
endmodule
