`timescale 1ps / 1ps

module RegisterFile (
    input wire clk_i,
    input wire arst_i,
    input wire [4:0] rs1_i,
    input wire [4:0] rs2_i,
    input wire [4:0] rd_i,
    input wire [31:0] rd_data_i,
    input wire we_i,
    output reg [31:0] rs1_data_o,
    output reg [31:0] rs2_data_o
);
  // 32 registers of 32 bits each
  reg [31:0] registers [1:31];

  // Asynchronous read
  assign rs1_data_o = (rs1_i != 5'd0) ? registers[rs1_i] : 32'd0; // x0 is always 0
  assign rs2_data_o = (rs2_i != 5'd0) ? registers[rs2_i] : 32'd0; // x0 is always 0

  // Synchronous write
  always @(posedge clk_i) begin
    if (we_i) begin
        registers[rd_i] <= rd_data_i;
    end
  end
endmodule
