`timescale 1ns/1ps

module mycpu_tb;

    localparam integer ClkP = 10;

    wire clk;
    reg reset;
    wire test;

    assign #(ClkP/2) clk = ~clk;

    initial begin
        $display("Testbench Start");
        reset = 0;
        #100 reset = 1;
        #100 reset = 0;
        #100 $display("Test Output: %x", test);
        $display("Testbench End");
        $finish();
    end

    mycpu #(
        .DATA_W(1)
    ) cpu0 (
        .clk_i(clk),
        .arst_i(reset),
        .test_o(test)
    );

endmodule
