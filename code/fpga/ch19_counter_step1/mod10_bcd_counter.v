module mod10_bcd_counter(
    input clk,              // 기준 Clock 입력
    input reset,            // 동기 Reset 입력
    input enable,           // Count 동작 허용 신호
    input tick,             // Count 증가 기준 Tick
    output reg [3:0] bcd,   // 0~9 BCD 값
    output reg carry        // 9에서 0으로 갈 때 1
);

always @(posedge clk) begin
    if (reset) begin
        bcd <= 4'd0;
        carry <= 1'b0;
    end
    else begin
        carry <= 1'b0;

        if (enable && tick) begin
            if (bcd == 4'd9) begin
                bcd <= 4'd0;
                carry <= 1'b1;
            end
            else begin
                bcd <= bcd + 1'b1;
            end
        end
    end
end

endmodule
