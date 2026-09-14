module compare_memory(
    input a,        // 조합회로 입력
    input s,        // Set 입력
    input r,        // Reset 입력
    output y,       // 조합회로 출력
    output reg q    // Latch 출력
);

assign y = a;       // 조합회로: 입력을 바로 출력

always @(*) begin
    if (s)
        q = 1'b1;   // Set: 1 저장
    else if (r)
        q = 1'b0;   // Reset: 0 저장
    // s=0, r=0이면 이전 q 유지
end

endmodule
