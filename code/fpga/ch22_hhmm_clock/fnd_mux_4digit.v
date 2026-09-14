module fnd_mux_4digit(
    input [3:0] digit0,        // 1분 자리
    input [3:0] digit1,        // 10분 자리
    input [3:0] digit2,        // 1시간 자리
    input [3:0] digit3,        // 10시간 자리
    input [1:0] digit_sel,     // 현재 선택 Digit
    output reg [3:0] current_digit,
    output reg [3:0] an
);

always @(*) begin
    current_digit = 4'd0;
    an = 4'b1111;

    case (digit_sel)
        2'd0: begin
            current_digit = digit0;
            an = 4'b1110;
        end
        2'd1: begin
            current_digit = digit1;
            an = 4'b1101;
        end
        2'd2: begin
            current_digit = digit2;
            an = 4'b1011;
        end
        2'd3: begin
            current_digit = digit3;
            an = 4'b0111;
        end
    endcase
end

endmodule
