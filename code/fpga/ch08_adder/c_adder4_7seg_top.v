module c_adder4_7seg_top(
    input [3:0] a,
    input [3:0] b,
    input cin,
    output [6:0] seg,
    output [3:0] an,
    output cout
);

wire [3:0] sum;

c_adder4_74283 u_adder(
    .a(a),
    .b(b),
    .cin(cin),
    .sum(sum),
    .cout(cout)
);

c_sevenseg_7447 u_seg(
    .bcd(sum),
    .seg(seg)
);

// Basys3의 4개 FND 중 오른쪽 1자리만 사용
assign an = 4'b1110;

endmodule
