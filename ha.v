module top_tone (
    input wire clk,
    input wire reset,
    output wire AUD_PWM,
    output wire AUD_SD
);

    assign AUD_SD = 1'b1;

    tone_generator tone_gen (
        .clk(clk),
        .reset(reset),
        .AUD_PWM(AUD_PWM)
    );

endmodule
module tone_generator (
    input wire clk,
    input wire reset,
    output reg AUD_PWM
);

    reg [15:0] counter = 0;
    reg toggle = 0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            toggle <= 0;
        end else if (counter == 24999) begin
            counter <= 0;
            toggle <= ~toggle;
        end else begin
            counter <= counter + 1;
        end
    end

    always @(posedge clk) begin
        AUD_PWM <= toggle;
    end

endmodule
