`timescale 1ns/1ps

module RV_fpga #(
    parameter integer DATA_W = 32
) (
    input wire clk_i,
    input wire arst_i,
    output reg [5:0] led_o
);
  `include "generated_wires_RV_fpga.vs"

  `include "instantiate_core.vs"
  `include "instantiate_myuart_test.vs"

endmodule
