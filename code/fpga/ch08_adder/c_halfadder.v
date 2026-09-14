module c_halfadder(
    input a,
    input b,
    output sum,
    output carry
);

// SUM 출력
assign sum = a ^ b;

// CARRY 출력
assign carry = a & b;

endmodule
