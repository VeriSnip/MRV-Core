`timescale 1ns/1ps

module mycpu #(
    parameter integer DATA_W = 32
) (
    input wire clk_i,
    input wire arst_i,
    output reg test_o
);

    always @(posedge clk_i or posedge arst_i) begin
        if (arst_i) test_o <= 1'b0;
        else test_o <= 1'b1;
    end

endmodule
