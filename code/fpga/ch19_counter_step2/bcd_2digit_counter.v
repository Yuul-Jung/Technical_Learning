module bcd_2digit_counter(
    input clk,                 // 기준 Clock 입력
    input reset,               // 동기 Reset 입력
    input enable,              // Count 동작 허용 신호
    input tick,                // Count 증가 기준 Tick
    output reg [3:0] digit0,   // 1의 자리 BCD 값
    output reg [3:0] digit1    // 10의 자리 BCD 값
);

always @(posedge clk) begin
    if (reset) begin
        digit0 <= 4'd0;
        digit1 <= 4'd0;
    end
    else begin
        if (enable && tick) begin
            if (digit0 == 4'd9) begin
                digit0 <= 4'd0;

                if (digit1 == 4'd9)
                    digit1 <= 4'd0;
                else
                    digit1 <= digit1 + 1'b1;
            end
            else begin
                digit0 <= digit0 + 1'b1;
            end
        end
    end
end

endmodule
