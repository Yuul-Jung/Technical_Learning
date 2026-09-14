module compare_latch_ff(
    input en,       // Latch Enable
    input clk,      // Flip-Flop Clock
    input d,        // 데이터 입력
    output reg q_latch,
    output reg q_ff
);

always @(*) begin
    if (en)
        q_latch = d; // en=1 동안 d를 즉시 반영
    // en=0이면 q_latch 유지
end

always @(posedge clk) begin
    q_ff <= d;       // 상승 Edge에서만 d 저장
end

endmodule
