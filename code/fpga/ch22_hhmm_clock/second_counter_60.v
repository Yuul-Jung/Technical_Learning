module second_counter_60(
    input clk,                 // 기준 Clock
    input reset,               // 동기 Reset
    input tick_1s,             // 1초 Tick Enable
    output reg tick_1min,      // 60초마다 1 Clock 동안 1
    output reg [5:0] sec_count // 내부 초 Count, 0~59
);

always @(posedge clk) begin
    if (reset) begin
        sec_count <= 6'd0;
        tick_1min <= 1'b0;
    end
    else begin
        tick_1min <= 1'b0;

        if (tick_1s) begin
            if (sec_count == 6'd59) begin
                sec_count <= 6'd0;
                tick_1min <= 1'b1;
            end
            else begin
                sec_count <= sec_count + 1'b1;
            end
        end
    end
end

endmodule
