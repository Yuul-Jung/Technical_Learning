module g_nor_7402(
    input a,
    input b,
    output y
);

// NOR Gate
assign y = ~(a | b);

endmodule
