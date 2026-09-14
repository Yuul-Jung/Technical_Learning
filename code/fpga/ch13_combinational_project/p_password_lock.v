module p_password_lock(
    input [3:0] sw,
    output led,
    output reg [6:0] seg,
    output [3:0] an
);

// 비밀번호 상수
parameter PASSWORD = 4'b1010;

// Basys3 오른쪽 1자리 FND만 사용
assign an = 4'b1110;

// 비교 결과
assign led = (sw == PASSWORD);

// Basys3 common-anode 기준 active-low 패턴
always @(*) begin
    if(sw == PASSWORD)
        seg = 7'b1000000; // O 형태
    else
        seg = 7'b0001001; // X 대체 표시: H 형태
end

endmodule
