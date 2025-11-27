`timescale 1ps / 1ps

module ALU (
    input wire clk_i,
    input wire arst_i,

    // ALU inputs
    input wire [31:0] SrcA_i,
    input wire [31:0] SrcB_i,
    input wire [ 2:0] control_i,

    // ALU output
    output reg [31:0] result_o,
    output reg zero_o
);
  // M and I ALU operations currespond to different sets of operations, equivilent to
  // M and I instructions subsets in RISC-V.
  // M operations are multiplication/division, while I operations are addition, subtraction, etc.
  wire func7_bit5_i = control_i[1];

  always_comb begin : ALU_I
    case (func3_i)
      3'b000: begin
        if (func7_bit5_i) I_result = SrcA_i - SrcB_i;
        else I_result = SrcA_i + SrcB_i;
      end
      3'b001:  I_result = SrcA_i << SrcB_i;
      3'b010:  I_result = {31'd0, (SrcA_i < SrcB_i)};
      3'b011:  I_result = {31'd0, (SrcA_i < SrcB_i)};
      3'b100:  I_result = SrcA_i ^ SrcB_i;
      3'b101: begin
        if (func7_bit5_i) I_result = $signed(SrcA_i) >>> SrcB_i;
        else I_result = SrcA_i >> SrcB_i;
      end
      3'b110:  I_result = SrcA_i | SrcB_i;
      3'b111:  I_result = SrcA_i & SrcB_i;
      default: I_result = 32'd0;
    endcase
  end


  `include "reg_result.vs"  /*
    result_o, 32, 0, ,      , I_result
    valid_o, 1, 0, ,      , enable_i
    */

endmodule
