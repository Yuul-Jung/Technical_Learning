module d_ff(
    input clk,      // 기준 Clock
    input d,        // 저장할 데이터
    output reg q    // 저장된 출력
);

always @(posedge clk) begin
    q <= d;         // 상승 Edge 순간의 d 저장
end

endmodule
