module c_demux2_behavioral(
    input din,
    input sel,
    output reg y0,
    output reg y1
);

always @(*) begin
    y0 = 0;
    y1 = 0;
    case(sel)
        1'b0: y0 = din;
        1'b1: y1 = din;
    endcase
end

endmodule
