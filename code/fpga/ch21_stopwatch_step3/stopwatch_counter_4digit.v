module stopwatch_counter_4digit(
    input clk,                 // 기준 Clock
    input reset,               // 동기 Reset
    input enable,              // Count 증가 Enable
    output reg [3:0] digit0,   // 0.01초 자리
    output reg [3:0] digit1,   // 0.1초 자리
    output reg [3:0] digit2,   // 1초 자리
    output reg [3:0] digit3    // 10초 자리
);

wire carry0;                   // digit0 자리 올림 조건
wire carry1;                   // digit1 자리 올림 조건
wire carry2;                   // digit2 자리 올림 조건

assign carry0 = (digit0 == 4'd9);
assign carry1 = (digit0 == 4'd9) && (digit1 == 4'd9);
assign carry2 = (digit0 == 4'd9) && (digit1 == 4'd9) &&
                (digit2 == 4'd9);

always @(posedge clk) begin
    if (reset) begin
        digit0 <= 4'd0;
        digit1 <= 4'd0;
        digit2 <= 4'd0;
        digit3 <= 4'd0;
    end
    else begin
        if (enable) begin
            digit0 <= carry0 ? 4'd0 : digit0 + 1'b1;

            if (carry0)
                digit1 <= (digit1 == 4'd9) ? 4'd0 :
                          digit1 + 1'b1;

            if (carry1)
                digit2 <= (digit2 == 4'd9) ? 4'd0 :
                          digit2 + 1'b1;

            if (carry2)
                digit3 <= (digit3 == 4'd9) ? 4'd0 :
                          digit3 + 1'b1;
        end
    end
end

endmodule
