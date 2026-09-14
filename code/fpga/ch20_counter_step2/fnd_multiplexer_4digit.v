module fnd_multiplexer_4digit(
    input [3:0] digit0,
    input [3:0] digit1,
    input [3:0] digit2,
    input [3:0] digit3,
    input [1:0] digit_sel,
    output reg [3:0] an,
    output reg [6:0] seg
);

reg [3:0] current_digit;

always @(*) begin
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
        default: begin
            current_digit = 4'd0;
            an = 4'b1111;
        end
    endcase
end

always @(*) begin
    case (current_digit)
        4'd0: seg = 7'b1000000;
        4'd1: seg = 7'b1111001;
        4'd2: seg = 7'b0100100;
        4'd3: seg = 7'b0110000;
        4'd4: seg = 7'b0011001;
        4'd5: seg = 7'b0010010;
        4'd6: seg = 7'b0000010;
        4'd7: seg = 7'b1111000;
        4'd8: seg = 7'b0000000;
        4'd9: seg = 7'b0010000;
        default: seg = 7'b1111111;
    endcase
end

endmodule
