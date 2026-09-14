module tb_c_halfadder;

reg a;
reg b;
wire sum;
wire carry;

c_halfadder dut(
    .a(a),
    .b(b),
    .sum(sum),
    .carry(carry)
);

initial begin
    a = 0; b = 0; #10;
    a = 0; b = 1; #10;
    a = 1; b = 0; #10;
    a = 1; b = 1; #10;
    $finish;
end

endmodule
