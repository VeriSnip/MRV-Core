`timescale 1ns/1ps

module RV_core_tb;

    localparam integer ClkPeriod = 10;

    wire clk;
    reg reset;
    wire test;

    assign #(ClkPeriod/2) clk = ~clk;

    initial begin
        $display("Testbench Start");
        reset = 0;
        #10 reset = 1;
        #10 reset = 0;
        #10 $display("Test Output: %x", test);
        $display("Testbench End");
        $finish();
    end

    `include "mem_test_program.vs" // ROM, test.bin

    RV_core #(
        .DATA_W(1)
    ) cpu0 (
        .clk_i(clk),
        .arst_i(reset),
        .i_addr_o(),
        .i_data_i(rom_data),
        .d_addr_o(),
        .d_data_i(32'd0),
        .d_data_o(),
        .d_we_o()
    );

endmodule
