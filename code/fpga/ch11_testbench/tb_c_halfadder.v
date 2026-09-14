//============================================================
// 파일명: tb_c_halfadder.v
// 목적  : c_halfadder 모듈 검증용 Testbench 작성
// 설명  :
//   - DUT 포트 이름은 in_a, in_b, sum, carry 임
//   - Testbench 내부 신호 이름은 tb_a, tb_b,
//     tb_sum, tb_carry 로 작성함
//   - 포트명과 연결 신호명을 다르게 작성하여
//     연결 구조를 명확히 확인함
//============================================================

module tb_c_halfadder;

reg tb_a;
reg tb_b;

wire tb_sum;
wire tb_carry;

c_halfadder dut(
    .in_a(tb_a),
    .in_b(tb_b),
    .sum(tb_sum),
    .carry(tb_carry)
);

initial begin
    tb_a = 0; tb_b = 0; #10;
    tb_a = 0; tb_b = 1; #10;
    tb_a = 1; tb_b = 0; #10;
    tb_a = 1; tb_b = 1; #10;
    $finish;
end

endmodule
