module c_mux2_behavioral(
    input a,
    input b,
    input sel,
    output reg y
);

always @(*) begin
    if(sel)
        y = b;
    else
        y = a;
end

endmodule
