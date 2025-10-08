`timescale 1ps / 1ps

module ALU (
    input wire clk_i,
    input wire arst_i,

    // ALU inputs
    input wire [31:0] a_i,
    input wire [31:0] b_i,
    input wire [2:0] control_i,
    input wire enable_i,

    // ALU output
    output reg [31:0] result_o,
    output reg zero_o
);
  // M and I ALU operations currespond to different sets of operations, equivilent to
  // M and I instructions subsets in RISC-V.
  // M operations are multiplication/division, while I operations are addition, subtraction, etc.
  reg [31:0] result;
  reg [31:0] M_result;
  reg [31:0] I_result;
  reg [31:0] M_a;
  reg [31:0] M_b;
  reg [ 2:0] M_func;
  reg [31:0] I_a;
  reg [31:0] I_b;
  reg [ 2:0] I_func;


  always_comb begin : ALU
    M_a = 32'd0;
    M_b = 32'd0;
    M_func = 3'b111;
    I_a = 32'd0;
    I_b = 32'd0;
    I_func = 3'b111;
    result = result_o;
    if (enable_i) begin
      if (func7_bit0_i) begin
        M_a = a_i;
        M_b = b_i;
        M_func = func3_i;
        result = M_result;
      end else begin
        I_a = a_i;
        I_b = b_i;
        I_func = func3_i;
        result = I_result;
      end
    end
  end

  // Extended the M ISA to include FMA (Fused Multiply-Add) operation
  always_comb begin : ALU_M
    case (M_func)
      3'b000: begin
        if (func7_bit5_i) M_result = M_a * M_b + result_o;
        else M_result = M_a * M_b;
      end
      default: M_result = 32'd0;
    endcase
  end

  always_comb begin : ALU_I
    case (I_func)
      3'b000: begin
        if (func7_bit5_i) I_result = I_a - I_b;
        else I_result = I_a + I_b;
      end
      3'b001:  I_result = I_a << I_b;
      3'b010:  I_result = {31'd0, (I_a < I_b)};
      3'b011:  I_result = {31'd0, (I_a < I_b)};
      3'b100:  I_result = I_a ^ I_b;
      3'b101: begin
        if (func7_bit5_i) I_result = $signed(I_a) >>> I_b;
        else I_result = I_a >> I_b;
      end
      3'b110:  I_result = I_a | I_b;
      3'b111:  I_result = I_a & I_b;
      default: I_result = 32'd0;
    endcase
  end


  `include "reg_result.vs"  /*
    result_o, 32, 0, ,      , result
    valid_o, 1, 0, ,      , enable_i
    */

endmodule