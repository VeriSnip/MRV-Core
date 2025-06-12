`timescale 1ns/1ps

module core #(
    parameter integer DATA_W = 32,
    parameter integer ADDR_W = 32
) (
    input wire clk_i,
    input wire arst_i,
    output reg [ADDR_W-1:0] i_addr_o
);
  `include "generated_wires_core.vs"

  always_comb begin
    pc_next = pc_q + 4;
  end

  `include "reg_core_list.vs"  /*
  pc_q, 32, 0, , , pc_next
  */


endmodule
