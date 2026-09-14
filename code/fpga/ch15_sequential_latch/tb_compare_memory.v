`timescale 1ns / 1ps

module tb_compare_memory;

reg a;
reg s;
reg r;
wire y;
wire q;

compare_memory dut(
    .a(a),
    .s(s),
    .r(r),
    .y(y),
    .q(q)
);

initial begin
    a = 1'b0;
    s = 1'b0;
    r = 1'b0;
    #10;

    a = 1'b1; #10;  // 조합회로 출력 변화
    a = 1'b0; #10;

    s = 1'b1;
    r = 1'b0;
    #10;            // q = 1 저장

    s = 1'b0;
    r = 1'b0;
    #10;            // q = 1 유지

    s = 1'b0;
    r = 1'b1;
    #10;            // q = 0 저장

    s = 1'b0;
    r = 1'b0;
    #10;            // q = 0 유지

    $finish;
end

endmodule
