module clock_divider_tick(
    input clk,          // 기준 Clock 입력
    input reset,        // 동기 Reset 입력
    output reg tick     // 5 Clock마다 1 Clock 동안 1
);

reg [2:0] div_count;    // 0~4까지 세는 Tick 생성 Counter

always @(posedge clk) begin
    if (reset) begin
        div_count <= 3'd0;    // Counter 초기화
        tick <= 1'b0;         // Tick 출력 초기화
    end
    else begin
        if (div_count == 3'd4) begin
            div_count <= 3'd0; // 5번째 Clock에서 다시 0으로 복귀
            tick <= 1'b1;      // 1 Clock 동안 Tick 발생
        end
        else begin
            div_count <= div_count + 1'b1; // Clock 개수 증가
            tick <= 1'b0;                  // 목표 Count 전에는 Tick 없음
        end
    end
end

endmodule
