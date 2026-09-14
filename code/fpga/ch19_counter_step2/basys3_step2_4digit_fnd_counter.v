module basys3_step2_4digit_fnd_counter(
    input clk,              // Basys3 100MHz Clock
    input btnU,             // Reset 버튼
    input [15:0] sw,        // sw[0]: Counter Enable
    output [15:0] led,      // 상태 확인 LED
    output reg [6:0] seg,   // Segment 출력, Active-Low
    output reg [3:0] an,    // Digit 선택 출력, Active-Low
    output dp               // Decimal Point, Active-Low
);

reg [22:0] div_count;       // 0.05초 Tick 생성 Counter
reg half_count;             // 0.05초 Tick 2회 확인용 Register
reg tick_0p05s;             // 0.05초마다 1 Clock 동안 1
reg tick_0p1s;              // 0.1초마다 1 Clock 동안 1

reg [15:0] scan_div;        // FND Scan 속도 생성 Counter
reg [1:0] digit_sel;        // 현재 선택 Digit

reg [3:0] digit0;
reg [3:0] digit1;
reg [3:0] digit2;
reg [3:0] digit3;
reg [3:0] current_digit;

assign dp = 1'b1;
assign led[3:0] = digit0;
assign led[7:4] = digit1;
assign led[8] = tick_0p05s;
assign led[9] = tick_0p1s;
assign led[15:10] = 6'd0;

always @(posedge clk) begin
    if (btnU) begin
        div_count <= 23'd0;
        half_count <= 1'b0;
        tick_0p05s <= 1'b0;
        tick_0p1s <= 1'b0;
    end
    else begin
        tick_0p05s <= 1'b0;
        tick_0p1s <= 1'b0;

        if (div_count == 23'd4_999_999) begin
            div_count <= 23'd0;
            tick_0p05s <= 1'b1;

            if (half_count == 1'b1) begin
                half_count <= 1'b0;
                tick_0p1s <= 1'b1;
            end
            else begin
                half_count <= 1'b1;
            end
        end
        else begin
            div_count <= div_count + 1'b1;
        end
    end
end

always @(posedge clk) begin
    if (btnU) begin
        digit0 <= 4'd0;
        digit1 <= 4'd0;
        digit2 <= 4'd0;
        digit3 <= 4'd0;
    end
    else begin
        if (sw[0] && tick_0p1s) begin
            if (digit0 == 4'd9) begin
                digit0 <= 4'd0;

                if (digit1 == 4'd9) begin
                    digit1 <= 4'd0;

                    if (digit2 == 4'd9) begin
                        digit2 <= 4'd0;

                        if (digit3 == 4'd9)
                            digit3 <= 4'd0;
                        else
                            digit3 <= digit3 + 1'b1;
                    end
                    else begin
                        digit2 <= digit2 + 1'b1;
                    end
                end
                else begin
                    digit1 <= digit1 + 1'b1;
                end
            end
            else begin
                digit0 <= digit0 + 1'b1;
            end
        end
    end
end

always @(posedge clk) begin
    if (btnU) begin
        scan_div <= 16'd0;
        digit_sel <= 2'd0;
    end
    else begin
        scan_div <= scan_div + 1'b1;
        digit_sel <= scan_div[15:14];
    end
end

always @(*) begin
    case (digit_sel)
        2'd0: begin current_digit = digit0; an = 4'b1110; end
        2'd1: begin current_digit = digit1; an = 4'b1101; end
        2'd2: begin current_digit = digit2; an = 4'b1011; end
        2'd3: begin current_digit = digit3; an = 4'b0111; end
        default: begin current_digit = 4'd0; an = 4'b1111; end
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
