module simplify_compare_top(
    input [1:0] sw,
    output [1:0] led
);

wire ny;
wire w1;
wire w2;

g_not_7404 u_not1(.a(sw[1]), .y(ny));
g_and_7408 u_and1(.a(sw[0]), .b(sw[1]), .y(w1));
g_and_7408 u_and2(.a(sw[0]), .b(ny), .y(w2));
g_or_7432  u_or1 (.a(w1), .b(w2), .y(led[0]));

// Simplified F = X
g_buffer_7407 u_buf1(.a(sw[0]), .y(led[1]));

endmodule
