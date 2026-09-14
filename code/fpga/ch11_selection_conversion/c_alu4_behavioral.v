module c_alu4_behavioral(
    input [3:0] a,
    input [3:0] b,
    input [1:0] op,
    output reg [3:0] y,
    output reg cout
);

reg [4:0] temp;

always @(*) begin
    y = 4'b0000;
    cout = 1'b0;
    temp = 5'b00000;

    case(op)
        2'b00: begin
            temp = a + b;
            y = temp[3:0];
            cout = temp[4];
        end
        2'b01: begin
            y = a - b;
            cout = 1'b0;
        end
        2'b10: begin
            y = a & b;
            cout = 1'b0;
        end
        2'b11: begin
            y = a | b;
            cout = 1'b0;
        end
    endcase
end

endmodule
