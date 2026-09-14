module logic_exp1_top(
    input [1:0] sw,
    output led
);

wire na;
wire nb;
wire w1;
wire w2;

// A'
g_not_7404 u_not1(
    .a(sw[0]),
    .y(na)
);

// B'
g_not_7404 u_not2(
    .a(sw[1]),
    .y(nb)
);

// A'B
g_and_7408 u_and1(
    .a(na),
    .b(sw[1]),
    .y(w1)
);

// AB'
g_and_7408 u_and2(
    .a(sw[0]),
    .b(nb),
    .y(w2)
);

// F = A'B + AB'
g_or_7432 u_or1(
    .a(w1),
    .b(w2),
    .y(led)
);

endmodule
