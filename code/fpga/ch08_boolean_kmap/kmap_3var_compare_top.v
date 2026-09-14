module kmap_3var_compare_top(
    input [2:0] sw,
    output [1:0] led
);

wire a = sw[0];
wire b = sw[1];
wire c = sw[2];

// Original: F = A'B'C + AB'C + A'BC + ABC
assign led[0] = (~a & ~b & c) |
                ( a & ~b & c) |
                (~a &  b & c) |
                ( a &  b & c);

// Karnaugh Map result: F = C
g_buffer_7407 u_buf1(.a(c), .y(led[1]));

endmodule
