module c_adder32(
    input  [31:0] a,
    input  [31:0] b,
    input         cin,
    output [31:0] sum,
    output        cout
);

assign {cout, sum} = {1'b0, a} + {1'b0, b} + cin;

endmodule
