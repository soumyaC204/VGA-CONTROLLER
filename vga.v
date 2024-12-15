module vga_controller (
    input clk,
    input [7:0] char_data,
    output reg h_sync,
    output reg v_sync,
    output reg [3:0] red,
    output reg [3:0] green,
    output reg [3:0] blue
);
    localparam H_DISPLAY = 640;
    localparam H_FRONT_PORCH = 16;
    localparam H_SYNC_PULSE = 96;
    localparam H_BACK_PORCH = 48;
    localparam H_TOTAL = 800;
    localparam V_DISPLAY = 480;
    localparam V_FRONT_PORCH = 10;
    localparam V_SYNC_PULSE = 2;
    localparam V_BACK_PORCH = 33;
    localparam V_TOTAL = 525;

    reg [9:0] h_counter = 0;
    reg [9:0] v_counter = 0;
    wire h_active = (h_counter < H_DISPLAY);
    wire v_active = (v_counter < V_DISPLAY);

    always @(posedge clk) begin
        if (h_counter == H_TOTAL - 1) begin
            h_counter <= 0;
            if (v_counter == V_TOTAL - 1)
                v_counter <= 0;
            else
                v_counter <= v_counter + 1;
        end else
            h_counter <= h_counter + 1;
    end

    always @(posedge clk) begin
        h_sync <= (h_counter >= H_DISPLAY + H_FRONT_PORCH) &&
                  (h_counter < H_DISPLAY + H_FRONT_PORCH + H_SYNC_PULSE);
        v_sync <= (v_counter >= V_DISPLAY + V_FRONT_PORCH) &&
                  (v_counter < V_DISPLAY + V_FRONT_PORCH + V_SYNC_PULSE);
    end

    always @(posedge clk) begin
        if (h_active && v_active) begin
            red <= char_data[7:4];
            green <= char_data[3:0];
            blue <= 4'b0000;
        end else begin
            red <= 0;
            green <= 0;
            blue <= 0;
        end
    end
endmodule
