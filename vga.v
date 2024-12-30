module mac_tb;

    reg [7:0] a;        // Input A
    reg [7:0] b;        // Input B
    reg clk;             // Clock signal
    reg rst;             // Reset signal
    wire [15:0] out;     // Output (result of multiplication and accumulation)

    // Instantiate the MAC module
    mac mac_inst (
        .a(a),
        .b(b),
        .clk(clk),
        .rst(rst),
        .out(out)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;  // Toggle every 5 time units, 100 MHz clock
    end

    // Test procedure
    initial begin
        // Initialize signals
        clk = 0;
        rst = 0;
        a = 8'd0;
        b = 8'd0;

        // Print header for simulation
        $display("Time\t\ta\tb\tout");

        // Monitor the output
        $monitor("%g\t%h\t%h\t%h", $time, a, b, out);

        // Test 1: Apply reset and check output
        rst = 1;  // Assert reset
        #10;
        rst = 0;  // Deassert reset
        #10;

        // Test 2: Apply values to inputs and check multiplication result
        a = 8'd2; b = 8'd3;  // 2 * 3 = 6
        #10;
        
        a = 8'd5; b = 8'd4;  // 5 * 4 = 20
        #10;

        a = 8'd6; b = 8'd7;  // 6 * 7 = 42
        #10;

        // Test 3: Check accumulation, previous results should accumulate
        a = 8'd1; b = 8'd2;  // 1 * 2 = 2, adding previous results (6 + 20 + 42 + 2 = 70)
        #10;

        // Test 4: Reset and check output should go to zero
        rst = 1;  // Assert reset again
        #10;
        rst = 0;  // Deassert reset

        // End simulation
        $finish;
    end

endmodule
