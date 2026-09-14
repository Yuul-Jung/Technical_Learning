module counter_reset_enable(
    input clk,              // 기준 Clock 입력
    input reset,            // 동기 Reset 입력
    input enable,           // Count 동작 허용 신호
    input tick,             // Count 증가 기준 Tick
    output reg [3:0] count  // 0~9 Counter 값
);

always @(posedge clk) begin
    if (reset) begin
        count <= 4'd0;
    end
    else begin
        if (enable && tick) begin
            if (count == 4'd9)
                count <= 4'd0;
            else
                count <= count + 1'b1;
        end
    end
end

endmodule
