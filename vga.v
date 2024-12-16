module vga_controller (
    input wire clk,
    input wire reset,
    output reg hsync,
    output reg vsync,
    output reg video_active,
    output reg [9:0] pixel_x,
    output reg [9:0] pixel_y
);

    localparam H_SYNC_PULSE = 96;
    localparam H_BACK_PORCH = 48;
    localparam H_ACTIVE_VIDEO = 640;
    localparam H_FRONT_PORCH = 16;
    localparam H_TOTAL = 800;

    localparam V_SYNC_PULSE = 2;
    localparam V_BACK_PORCH = 33;
    localparam V_ACTIVE_VIDEO = 480;
    localparam V_FRONT_PORCH = 10;
    localparam V_TOTAL = 525;

    reg [9:0] h_counter = 0;
    reg [9:0] v_counter = 0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            h_counter <= 0;
            v_counter <= 0;
        end else begin
            if (h_counter == H_TOTAL - 1) begin
                h_counter <= 0;
                if (v_counter == V_TOTAL - 1)
                    v_counter <= 0;
                else
                    v_counter <= v_counter + 1;
            end else begin
                h_counter <= h_counter + 1;
            end
        end
    end

    always @(*) begin
        hsync = (h_counter >= H_ACTIVE_VIDEO + H_FRONT_PORCH) &&
                (h_counter < H_ACTIVE_VIDEO + H_FRONT_PORCH + H_SYNC_PULSE);
        vsync = (v_counter >= V_ACTIVE_VIDEO + V_FRONT_PORCH) &&
                (v_counter < V_ACTIVE_VIDEO + V_FRONT_PORCH + V_SYNC_PULSE);
        video_active = (h_counter < H_ACTIVE_VIDEO) && (v_counter < V_ACTIVE_VIDEO);

        if (video_active) begin
            pixel_x = h_counter;
            pixel_y = v_counter;
        end else begin
            pixel_x = 0;
            pixel_y = 0;
        end
    end
endmodule
module char_rom (
    input wire [7:0] ascii_code,
    input wire [3:0] row,
    output reg [7:0] bitmap
);
    always @(*) begin
        case (ascii_code)
            8'h41: // 'A'
                case (row)
                    4'd0: bitmap = 8'b00011000;
                    4'd1: bitmap = 8'b00100100;
                    4'd2: bitmap = 8'b01000010;
                    4'd3: bitmap = 8'b01111110;
                    4'd4: bitmap = 8'b01000010;
                    4'd5: bitmap = 8'b01000010;
                    4'd6: bitmap = 8'b01000010;
                    4'd7: bitmap = 8'b00000000;
                    default: bitmap = 8'b00000000;
                endcase
            // Add more characters here
            default: bitmap = 8'b00000000;
        endcase
    end
endmodule
module vga_keyboard_display (
    input wire clk,
    input wire reset,
    input wire ps2_clk,
    input wire ps2_data,
    output wire hsync,
    output wire vsync,
    output reg [2:0] red,
    output reg [2:0] green,
    output reg [1:0] blue
);

    wire video_active;
    wire [9:0] pixel_x, pixel_y;
    wire [7:0] ascii_code;
    wire [7:0] bitmap;
    wire new_key;

    reg [7:0] displayed_char = 8'h41;

    vga_controller vga_inst (
        .clk(clk),
        .reset(reset),
        .hsync(hsync),
        .vsync(vsync),
        .video_active(video_active),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y)
    );

    keyboard_interface keyboard_inst (
        .clk(clk),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .ascii_code(ascii_code),
        .new_key(new_key)
    );

    char_rom char_rom_inst (
        .ascii_code(displayed_char),
        .row(pixel_y[3:0]),
        .bitmap(bitmap)
    );

    always @(posedge clk or posedge reset) begin
        if (reset)
            displayed_char <= 8'h41; // Default to 'A'
        else if (new_key)
            displayed_char <= ascii_code;
    end

    always @(*) begin
        if (video_active && bitmap[pixel_x[2:0]]) begin
            red = 3'b111;
            green = 3'b111;
            blue = 2'b11;
        end else begin
            red = 3'b000;
            green = 3'b000;
            blue = 2'b00;
        end
    end
endmodule

