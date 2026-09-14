module clock_divider_1s(
    input clk,              // 100MHz 기준 Clock
    input reset,            // 동기 Reset
    input enable,           // Tick 생성 허용
    output reg tick_1s      // 1초마다 1 Clock 동안 1
);

reg [26:0] count_div;       // 100,000,000 Clock Count용

// 1초 Tick 생성 블록
always @(posedge clk) begin
    if (reset) begin
        count_div <= 27'd0; // Counter 초기화
        tick_1s <= 1'b0;    // Tick 초기화
    end
    else begin
        tick_1s <= 1'b0;    // Tick 기본값은 0

        if (enable) begin
            if (count_div == 27'd99_999_999) begin
                count_div <= 27'd0;
                tick_1s <= 1'b1;
            end
            else begin
                count_div <= count_div + 1'b1;
            end
        end
        else begin
            count_div <= 27'd0;
        end
    end
end

endmodule
