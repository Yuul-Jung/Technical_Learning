module c_mux2_gate(
    input a,
    input b,
    input sel,
    output y
);

wire nsel;
wire w0;
wire w1;

not u0(nsel, sel);
and u1(w0, a, nsel);
and u2(w1, b, sel);
or  u3(y, w0, w1);

endmodule
