module clock_divider_10ms(
    input clk,              // 100MHz 기준 Clock
    input reset,            // 동기 Reset
    input enable,           // Tick 생성 허용
    output reg tick         // 0.01초마다 1 Clock 동안 1
);

reg [19:0] count_div;       // 1,000,000 Clock Counter

// 0.01초 Tick 생성 블록
always @(posedge clk) begin
    if (reset) begin
        count_div <= 20'd0; // Counter 초기화
        tick <= 1'b0;       // Tick 초기화
    end
    else begin
        tick <= 1'b0;       // Tick 기본값은 0

        if (enable) begin   // Enable 상태에서만 Count
            if (count_div == 20'd999_999) begin
                count_div <= 20'd0; // 1,000,000 Clock 도달 후 초기화
                tick <= 1'b1;       // 1 Clock 폭 Tick 발생
            end
            else begin
                count_div <= count_div + 1'b1; // Clock Count 증가
            end
        end
        else begin
            count_div <= 20'd0;     // 정지 시 기준 Count 초기화
        end
    end
end

endmodule
