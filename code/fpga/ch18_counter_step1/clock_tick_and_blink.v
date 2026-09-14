module clock_tick_and_blink(
    input clk,              // Basys3 100MHz Clock
    input reset,            // 동기 Reset
    output reg tick_0p5s,   // 0.5초마다 1 Clock 동안 1
    output reg tick_1hz,    // 1초마다 1 Clock 동안 1
    output reg blink_1hz    // 1Hz Duty 50% 점멸 신호
);

reg [25:0] div_count;       // 0.5초 생성을 위한 26비트 Counter
reg half_count;             // 0.5초 Tick 발생 횟수 저장

always @(posedge clk) begin
    if (reset) begin
        div_count <= 26'd0;
        half_count <= 1'b0;
        tick_0p5s <= 1'b0;
        tick_1hz <= 1'b0;
        blink_1hz <= 1'b0;
    end
    else begin
        tick_0p5s <= 1'b0;
        tick_1hz <= 1'b0;

        if (div_count == 26'd49_999_999) begin
            div_count <= 26'd0;
            tick_0p5s <= 1'b1;
            blink_1hz <= ~blink_1hz;

            if (half_count == 1'b1) begin
                half_count <= 1'b0;
                tick_1hz <= 1'b1;
            end
            else begin
                half_count <= 1'b1;
            end
        end
        else begin
            div_count <= div_count + 1'b1;
        end
    end
end

endmodule
