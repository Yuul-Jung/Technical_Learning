module bad_latch(
    input en,       // Enable 입력
    input d,        // 데이터 입력
    output reg q    // Latch 출력
);

always @(*) begin
    if (en)
        q = d;      // en=1 동안 d를 계속 반영
    // else가 없으므로 en=0일 때 q 유지
    // 교육용 나쁜 예제: 실제 FPGA RTL에서는 피해야 함
end

endmodule
