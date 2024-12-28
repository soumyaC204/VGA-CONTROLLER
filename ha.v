module mac_unit (
    input wire clk,
    input wire rst,
    input wire enable,
    input wire [7:0] mem_addr_a,   // Address for first operand
    input wire [7:0] mem_addr_b,   // Address for second operand
    output reg [31:0] result       // MAC result output
);

    // Memory declaration (as an example, using block RAM)
    reg [15:0] memory [0:255];     // 256 locations of 16-bit data
    
    // Internal registers
    reg [15:0] operand_a;
    reg [15:0] operand_b;
    reg [31:0] mult_result;
    reg [31:0] acc_result;
    
    // States for MAC operation
    localparam IDLE = 2'b00;
    localparam FETCH = 2'b01;
    localparam MULTIPLY = 2'b10;
    localparam ACCUMULATE = 2'b11;
    
    reg [1:0] current_state;
    reg [1:0] next_state;
    
    // State machine sequential logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end
    
    // State machine combinational logic
    always @(*) begin
        case (current_state)
            IDLE: begin
                next_state = enable ? FETCH : IDLE;
            end
            FETCH: begin
                next_state = MULTIPLY;
            end
            MULTIPLY: begin
                next_state = ACCUMULATE;
            end
            ACCUMULATE: begin
                next_state = enable ? FETCH : IDLE;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end
    
    // MAC operations
    always @(posedge clk) begin
        case (current_state)
            IDLE: begin
                if (rst) begin
                    result <= 32'h0;
                    acc_result <= 32'h0;
                end
            end
            
            FETCH: begin
                operand_a <= memory[mem_addr_a];
                operand_b <= memory[mem_addr_b];
            end
            
            MULTIPLY: begin
                mult_result <= operand_a * operand_b;
            end
            
            ACCUMULATE: begin
                acc_result <= acc_result + mult_result;
                result <= acc_result + mult_result;
            end
        endcase
    end
    
    // Memory initialization - for simulation purposes
    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            memory[i] = i; // Initialize with some values
        end
    end

endmodule

// Testbench for MAC unit
module mac_unit_tb;
    reg clk;
    reg rst;
    reg enable;
    reg [7:0] mem_addr_a;
    reg [7:0] mem_addr_b;
    wire [31:0] result;
    
    // Instantiate the MAC unit
    mac_unit uut (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .mem_addr_a(mem_addr_a),
        .mem_addr_b(mem_addr_b),
        .result(result)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test stimulus
    initial begin
        // Initialize inputs
        rst = 1;
        enable = 0;
        mem_addr_a = 0;
        mem_addr_b = 0;
        
        // Wait 100 ns for global reset
        #100;
        rst = 0;
        
        // Test case 1
        #10 enable = 1;
        mem_addr_a = 8'h01;
        mem_addr_b = 8'h02;
        
        // Test case 2
        #40;
        mem_addr_a = 8'h03;
        mem_addr_b = 8'h04;
        
        // Test case 3
        #40;
        mem_addr_a = 8'h05;
        mem_addr_b = 8'h06;
        
        // End simulation
        #100;
        enable = 0;
        #50;
        $finish;
    end
    
    // Monitor results
    initial begin
        $monitor("Time=%0t rst=%b enable=%b addr_a=%h addr_b=%h result=%h",
                 $time, rst, enable, mem_addr_a, mem_addr_b, result);
    end
    
endmodule
