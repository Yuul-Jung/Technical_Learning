module counter_1digit(
    input clk,              // 기준 Clock 입력
    input reset,            // 동기 Reset 입력
    input tick,             // Count 증가 Enable
    output reg [3:0] count  // 0~9 Counter 값
);

always @(posedge clk) begin
    if (reset) begin
        count <= 4'd0;
    end
    else begin
        if (tick) begin
            if (count == 4'd9)
                count <= 4'd0;
            else
                count <= count + 1'b1;
        end
    end
end

endmodule
