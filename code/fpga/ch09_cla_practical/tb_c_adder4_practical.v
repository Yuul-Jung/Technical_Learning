module tb_c_adder4_practical;

reg [3:0] a;
reg [3:0] b;
reg cin;

wire [3:0] sum;
wire cout;

c_adder4_practical dut(
    .a(a),
    .b(b),
    .cin(cin),
    .sum(sum),
    .cout(cout)
);

initial begin
    a = 4'd0;  b = 4'd0;  cin = 1'b0; #10;
    a = 4'd3;  b = 4'd2;  cin = 1'b0; #10;
    a = 4'd7;  b = 4'd1;  cin = 1'b0; #10;
    a = 4'd8;  b = 4'd7;  cin = 1'b0; #10;
    a = 4'd15; b = 4'd1;  cin = 1'b0; #10;
    a = 4'd15; b = 4'd15; cin = 1'b0; #10;
    a = 4'd15; b = 4'd15; cin = 1'b1; #10;

    $finish;
end

endmodule
