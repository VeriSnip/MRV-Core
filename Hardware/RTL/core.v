`timescale 1ns/1ps

module core #(
    parameter integer DATA_W = 32
) (
    input wire clk_i,
    input wire arst_i,
    output reg test_o
);

  always_comb begin
    pc_next = pc_q + 4;
  end

  `include "reg_myuart_fpga.vs"  /*
  pc_q, 32, 0, arst_i, , pc_next
  */


endmodule
