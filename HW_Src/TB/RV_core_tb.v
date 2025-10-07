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

    RV_core #(
        .DATA_W(1)
    ) cpu0 (
        .clk_i(clk),
        .arst_i(reset),
        .test_o(test)
    );

endmodule
