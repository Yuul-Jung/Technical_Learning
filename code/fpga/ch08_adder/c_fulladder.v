module c_fulladder(
    input a,
    input b,
    input cin,
    output sum,
    output cout
);

wire s1;
wire c1;
wire c2;

c_halfadder u_ha0(
    .a(a),
    .b(b),
    .sum(s1),
    .carry(c1)
);

c_halfadder u_ha1(
    .a(s1),
    .b(cin),
    .sum(sum),
    .carry(c2)
);

assign cout = c1 | c2;

endmodule
