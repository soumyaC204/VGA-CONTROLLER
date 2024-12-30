module mac(
    input logic [7:0] a,
    input logic [7:0] b,
    input logic clk,
    input logic rst,
    output logic [15:0] out
);
    logic [15:0] product;
    logic [15:0] accumulator;

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            accumulator <= 16'b0;
        else
            accumulator <= accumulator + product;
    end

    assign product = a * b;
    assign out = accumulator;
endmodule
module mac_top(
    input logic clk,
    input logic rst,
    output logic [15:0] out
);
    localparam NUM_VALUES = 10;
    logic [7:0] a, b;
    logic [3:0] mem_index;
    logic [7:0] a_mem[NUM_VALUES-1:0];
    logic [7:0] b_mem[NUM_VALUES-1:0];

    mac mac_inst (
        .a(a),
        .b(b),
        .clk(clk),
        .rst(rst),
        .out(out)
    );

    initial begin
        a_mem[0] = 8'd0; b_mem[0] = 8'd0;
        a_mem[1] = 8'd1; b_mem[1] = 8'd1;
        a_mem[2] = 8'd2; b_mem[2] = 8'd2;
        a_mem[3] = 8'd3; b_mem[3] = 8'd3;
        a_mem[4] = 8'd4; b_mem[4] = 8'd4;
        a_mem[5] = 8'd5; b_mem[5] = 8'd5;
        a_mem[6] = 8'd6; b_mem[6] = 8'd6;
        a_mem[7] = 8'd7; b_mem[7] = 8'd7;
        a_mem[8] = 8'd8; b_mem[8] = 8'd8;
        a_mem[9] = 8'd9; b_mem[9] = 8'd9;
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            mem_index <= 4'b0;
        else if (mem_index < NUM_VALUES - 1)
            mem_index <= mem_index + 1;
    end

    assign a = a_mem[mem_index];
    assign b = b_mem[mem_index];
endmodule
