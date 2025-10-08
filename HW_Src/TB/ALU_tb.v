`timescale 1ps / 1ps

module ALU_tb;

  // Parameters for readability
  parameter CLK_PERIOD = 10;  // 10ps for 100GHz clock

  // Inputs to the ALU module
  reg clk_i;
  reg arst_i;
  reg [31:0] a_i;
  reg [31:0] b_i;
  reg [2:0] func3_i;
  reg func7_bit0_i;
  reg func7_bit5_i;
  reg enable_i;

  // Outputs from the ALU module
  wire [31:0] result_o;
  wire valid_o;

  // Testbench internal signals
  integer error_count;
  integer test_case_count;

  // Instantiate the Device Under Test (DUT)
  ALU dut (
      .clk_i(clk_i),
      .arst_i(arst_i),
      .a_i(a_i),
      .b_i(b_i),
      .func3_i(func3_i),
      .func7_bit0_i(func7_bit0_i),
      .func7_bit5_i(func7_bit5_i),
      .enable_i(enable_i),
      .result_o(result_o),
      .valid_o(valid_o)
  );

  always begin
    #(CLK_PERIOD / 2) clk_i = ~clk_i;  // Clock period of CLK_PERIOD
  end

  // Test sequence
  initial begin
    clk_i = 0;  // Initialize clock to 0

    error_count = 0;
    test_case_count = 0;

    // Initialize inputs
    arst_i = 1;
    a_i = 32'd0;
    b_i = 32'd0;
    func3_i = 3'b000;
    func7_bit0_i = 0;
    func7_bit5_i = 0;
    enable_i = 0;  // Keep ALU disabled initially

    #(CLK_PERIOD * 2 + 2);  // Wait a bit for reset to settle

    arst_i = 0;  // Release reset
    @(posedge clk_i) #1;  // Wait for the next positive clock edge and a small delay

    $display("---------------------------------------");
    $display("Starting ALU Testbench Simulation");
    $display("---------------------------------------");

    // --- I-type operations (func7_bit0_i = 0) ---

    // Addition (func3_i = 3'b000, func7_bit5_i = 0)
    test_alu_op(10, 5, 3'b000, 0, 0, 15, "ADD");
    test_alu_op(0, 0, 3'b000, 0, 0, 0, "ADD Zero");
    test_alu_op(32'hFFFFFFFF, 1, 3'b000, 0, 0, 32'd0, "ADD Overflow");
    test_alu_op(32'd100, 32'd200, 3'b000, 0, 0, 32'd300, "ADD Large");

    // Subtraction (func3_i = 3'b000, func7_bit5_i = 1)
    test_alu_op(10, 5, 3'b000, 0, 1, 5, "SUB");
    test_alu_op(5, 10, 3'b000, 0, 1, -5, "SUB Negative");  // -5 in 2's complement
    test_alu_op(0, 0, 3'b000, 0, 1, 0, "SUB Zero");

    // SLL (Shift Left Logical) (func3_i = 3'b001)
    test_alu_op(4, 2, 3'b001, 0, 0, 16, "SLL");
    test_alu_op(1, 31, 3'b001, 0, 0, 32'h80000000, "SLL Max Shift");
    test_alu_op(32'h80000000, 1, 3'b001, 0, 0, 0, "SLL into zero");

    // SLT (Set Less Than) (func3_i = 3'b010)
    test_alu_op(5, 10, 3'b010, 0, 0, 1, "SLT True");
    test_alu_op(10, 5, 3'b010, 0, 0, 0, "SLT False");
    test_alu_op(10, 10, 3'b010, 0, 0, 0, "SLT Equal");

    // SLTU (Set Less Than Unsigned) (func3_i = 3'b011)
    test_alu_op(5, 10, 3'b011, 0, 0, 1, "SLTU True");
    test_alu_op(10, 5, 3'b011, 0, 0, 0, "SLTU False");
    test_alu_op(32'hFFFFFFFF, 1, 3'b011, 0, 0, 0,
                "SLTU Unsigned (Max > 1)");  // Max unsigned is not less than 1
    test_alu_op(1, 32'hFFFFFFFF, 3'b011, 0, 0, 1, "SLTU Unsigned (1 < Max)");

    // XOR (func3_i = 3'b100)
    test_alu_op(32'hF0F0F0F0, 32'h0F0F0F0F, 3'b100, 0, 0, 32'hFFFFFFFF, "XOR");
    test_alu_op(32'hAAAAAAAA, 32'hAAAAAAAA, 3'b100, 0, 0, 32'd0, "XOR Self");

    // SRL (Shift Right Logical) (func3_i = 3'b101, func7_bit5_i = 0)
    test_alu_op(16, 2, 3'b101, 0, 0, 4, "SRL");
    test_alu_op(32'h80000000, 1, 3'b101, 0, 0, 32'h40000000, "SRL MSB");
    test_alu_op(32'hFFFFFFFF, 1, 3'b101, 0, 0, 32'h7FFFFFFF, "SRL All Fs");

    // SRA (Shift Right Arithmetic) (func3_i = 3'b101, func7_bit5_i = 1)
    test_alu_op(32'hFFFFFFFC, 1, 3'b101, 0, 1, 32'hFFFFFFFE, "SRA Negative");  // -4 >> 1 = -2
    test_alu_op(32'h0000000C, 1, 3'b101, 0, 1, 32'h00000006, "SRA Positive");  // 12 >> 1 = 6

    // OR (func3_i = 3'b110)
    test_alu_op(32'hF0F0F0F0, 32'h0F0F0F0F, 3'b110, 0, 0, 32'hFFFFFFFF, "OR");
    test_alu_op(32'hAAAAAAAA, 32'h55555555, 3'b110, 0, 0, 32'hFFFFFFFF, "OR Complement");

    // AND (func3_i = 3'b111)
    test_alu_op(32'hF0F0F0F0, 32'h0F0F0F0F, 3'b111, 0, 0, 32'd0, "AND No Overlap");
    test_alu_op(32'hAAAAAAAA, 32'hFFFFFFFF, 3'b111, 0, 0, 32'hAAAAAAAA, "AND Mask");

    // --- M-type operations (func7_bit0_i = 1) ---

    // Multiplication (func3_i = 3'b000, func7_bit5_i = 0)
    test_alu_op(5, 3, 3'b000, 1, 0, 15, "MUL");
    test_alu_op(0, 100, 3'b000, 1, 0, 0, "MUL Zero");
    test_alu_op(100, 0, 3'b000, 1, 0, 0, "MUL Zero 2");
    test_alu_op(32'd10000, 32'd20000, 3'b000, 1, 0, 32'd200000000, "MUL Large");  // 200,000,000

    // Multiply-Add (func3_i = 3'b000, func7_bit5_i = 1)
    // First test with a zero initial result_o
    test_alu_op(0, 0, 3'b000, 0, 0, 0, "SET_RESULT_O_TO_0");  // Start with zero result_o
    test_alu_op(5, 3, 3'b000, 1, 1, 15, "FMA (result_o was 0)");  // 5 * 3 + 0 = 15
    // Test with a non-zero initial result_o for FMA
    $display("--- Setting up for FMA with non-zero initial result_o ---");
    test_alu_op(10, 0, 3'b000, 0, 0, 10, "SET_RESULT_O_TO_10");
    test_alu_op(5, 3, 3'b000, 1, 1, 25, "FMA (result_o was 10)");  // 5 * 3 + 10 = 25


    $display("---------------------------------------");
    $display("Simulation Finished.");
    if (error_count == 0) begin
      $display("All %0d tests PASSED!", test_case_count);
    end else begin
      $display("Simulation FAILED: %0d errors found out of %0d tests.", error_count,
               test_case_count);
    end
    $display("---------------------------------------");

    $finish;  // End simulation
  end

  // Helper task for testing operations
  task static test_alu_op;
    input [31:0] test_a;
    input [31:0] test_b;
    input [2:0] test_func3;
    input test_func7_bit0;
    input test_func7_bit5;
    input [31:0] expected_result;
    input string op_name;
    begin
      test_case_count = test_case_count + 1;
      a_i = test_a;
      b_i = test_b;
      func3_i = test_func3;
      func7_bit0_i = test_func7_bit0;
      func7_bit5_i = test_func7_bit5;
      enable_i = 1;  // Assert enable_i to trigger computation

      @(posedge clk_i) #1;
      // Wait for one clock cycle for the result to propagate and be registered
      while (valid_o == 1'b0) begin
        @(posedge clk_i) #1;  // Wait for valid_o to be asserted
      end

      if (result_o == expected_result) begin
        $display("Test Case %0d (%s): PASSED. A=%0d, B=%0d, Result=%0d, Expected=%0d",
                 test_case_count, op_name, test_a, test_b, result_o, expected_result);
      end else begin
        $display(
            "Test Case %0d (%s): \033[38;5;208mFAILED\033[0m. A=%0d, B=%0d, Result=%0d, Expected=%0d, Valid=%b",
            test_case_count, op_name, test_a, test_b, result_o, expected_result, valid_o);
        error_count = error_count + 1;
      end
      enable_i = 0;  // De-assert enable_i
    end
  endtask

  // Monitor signals (optional, for debugging waveforms)
  initial begin
    $dumpfile("ALU_tb.vcd");
    $dumpvars(0, ALU_tb);
  end

endmodule