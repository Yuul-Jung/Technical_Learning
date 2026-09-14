module dp_blink_1hz(
    input clk,              // 100MHz 기준 Clock
    input reset,            // 동기 Reset
    input enable,           // Blink 동작 허용
    output dp_state         // dp 출력, Active-Low
);

reg [25:0] count_blink;     // 0.5초 Count용
reg blink;                  // 0.5초마다 반전되는 내부 상태

always @(posedge clk) begin
    if (reset) begin
        count_blink <= 26'd0;
        blink <= 1'b0;
    end
    else begin
        if (enable) begin
            if (count_blink == 26'd49_999_999) begin
                count_blink <= 26'd0;
                blink <= ~blink;
            end
            else begin
                count_blink <= count_blink + 1'b1;
            end
        end
        else begin
            count_blink <= 26'd0;
            blink <= 1'b0;
        end
    end
end

assign dp_state = ~blink;

endmodule
