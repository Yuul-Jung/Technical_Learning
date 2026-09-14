module d_ff_reset(
    input clk,      // 기준 Clock
    input rst,      // 동기 Reset
    input d,        // 저장할 데이터
    output reg q    // 저장된 출력
);

always @(posedge clk) begin
    if (rst)
        q <= 1'b0;  // Reset 시 0 저장
    else
        q <= d;     // 상승 Edge에서 d 저장
end

endmodule
