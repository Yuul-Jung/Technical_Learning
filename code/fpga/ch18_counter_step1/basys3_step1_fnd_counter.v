module basys3_step1_fnd_counter(
    input clk,              // Basys3 100MHz Clock
    input btnU,             // Reset 버튼
    input [15:0] sw,        // sw[0]: Counter Enable
    output [15:0] led,      // led[3:0]: Count, led[15]: blink 확인
    output reg [6:0] seg,   // FND Segment 출력
    output reg [3:0] an,    // FND Digit 선택
    output dp               // Decimal Point 출력
);

wire tick_0p5s;
wire tick_1hz;
wire blink_1hz;
wire [3:0] count;

clock_tick_and_blink u_tick(
    .clk(clk),
    .reset(btnU),
    .tick_0p5s(tick_0p5s),
    .tick_1hz(tick_1hz),
    .blink_1hz(blink_1hz)
);

counter_reset_enable u_counter(
    .clk(clk),
    .reset(btnU),
    .enable(sw[0]),
    .tick(tick_1hz),
    .count(count)
);

assign dp = ~blink_1hz;      // Active-Low DP 점멸
assign led[3:0] = count;     // 현재 Count 표시
assign led[14:4] = 11'd0;
assign led[15] = blink_1hz;  // 1Hz Duty 50% 확인

always @(*) begin
    an = 4'b1110;              // 오른쪽 1자리 FND만 선택

    case (count)
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
