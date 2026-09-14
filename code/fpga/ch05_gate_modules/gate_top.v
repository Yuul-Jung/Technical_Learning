module gate_top(
    input [1:0] sw,
    output [6:0] led
);

// NOT Gate
g_not_7404 u_not_7404(
    .a(sw[0]),
    .y(led[0])
);

// BUFFER
g_buffer_7407 u_buffer_7407(
    .a(sw[0]),
    .y(led[1])
);

// AND Gate
g_and_7408 u_and_7408(
    .a(sw[0]),
    .b(sw[1]),
    .y(led[2])
);

// OR Gate
g_or_7432 u_or_7432(
    .a(sw[0]),
    .b(sw[1]),
    .y(led[3])
);

// NAND Gate
g_nand_7400 u_nand_7400(
    .a(sw[0]),
    .b(sw[1]),
    .y(led[4])
);

// NOR Gate
g_nor_7402 u_nor_7402(
    .a(sw[0]),
    .b(sw[1]),
    .y(led[5])
);

// XOR Gate
g_xor_7486 u_xor_7486(
    .a(sw[0]),
    .b(sw[1]),
    .y(led[6])
);

endmodule
