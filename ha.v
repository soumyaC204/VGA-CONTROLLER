module mac (
    input [7:0] a,  // Input A
    input [7:0] b,  // Input B
    input clk,       // Clock
    input rst,       // Reset
    output reg [15:0] out  // Output (accumulated result)
);
    reg [15:0] acc;  // Accumulator for the MAC operation

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            acc <= 16'b0;  // Reset the accumulator
        else
            acc <= acc + a * b;  // Accumulate the product
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            out <= 16'b0;  // Reset the output on reset
        else
            out <= acc;  // Output the accumulated result
    end
endmodule
