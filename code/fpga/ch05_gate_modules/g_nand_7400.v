module g_nand_7400(
    input a,
    input b,
    output y
);

// NAND Gate
assign y = ~(a & b);

endmodule
