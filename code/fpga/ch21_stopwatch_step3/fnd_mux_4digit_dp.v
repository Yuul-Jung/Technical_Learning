module fnd_mux_4digit_dp(
    input [3:0] digit0,         // 0.01초 자리
    input [3:0] digit1,         // 0.1초 자리
    input [3:0] digit2,         // 1초 자리
    input [3:0] digit3,         // 10초 자리
    input [1:0] digit_sel,      // 현재 선택 Digit
    output reg [3:0] current_digit, // Decoder로 보낼 현재 Digit
    output reg [3:0] an,        // FND Digit 선택, Active-Low
    output reg dp               // Decimal Point, Active-Low
);

always @(*) begin
    current_digit = 4'd0;
    an = 4'b1111;
    dp = 1'b1;

    case (digit_sel)
        2'd0: begin
            current_digit = digit0;
            an = 4'b1110;
            dp = 1'b1;
        end
        2'd1: begin
            current_digit = digit1;
            an = 4'b1101;
            dp = 1'b1;
        end
        2'd2: begin
            current_digit = digit2;
            an = 4'b1011;
            dp = 1'b0;
        end
        2'd3: begin
            current_digit = digit3;
            an = 4'b0111;
            dp = 1'b1;
        end
    endcase
end

endmodule
