module c_adder4_practical(
    input  [3:0] a,
    input  [3:0] b,
    input        cin,
    output [3:0] sum,
    output       cout
);

assign {cout, sum} = {1'b0, a} + {1'b0, b} + cin;

endmodule
