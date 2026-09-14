module start_stop_control(
    input clk,          // 기준 Clock
    input reset,        // 동기 Reset
    input start,        // Start 입력
    input stop,         // Stop 입력
    output reg running  // 실행 상태
);

always @(posedge clk) begin
    if (reset) begin
        running <= 1'b0;
    end
    else begin
        if (start)
            running <= 1'b1;
        else if (stop)
            running <= 1'b0;
    end
end

endmodule
