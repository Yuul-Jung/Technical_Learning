module basys3_step3_struct_stopwatch(
    input clk,              // Basys3 100MHz Clock
    input btnC,             // Start 버튼
    input btnU,             // Stop 버튼
    input btnD,             // Reset 버튼
    input [15:0] sw,        // sw[0]: 전체 Enable
    output [15:0] led,      // 상태 확인 LED
    output [6:0] seg,       // Segment 출력, Active-Low
    output [3:0] an,        // Digit 선택 출력, Active-Low
    output dp               // Decimal Point, Active-Low
);

wire tick_0p01s;
wire running;
wire count_enable;
wire [3:0] digit0;
wire [3:0] digit1;
wire [3:0] digit2;
wire [3:0] digit3;
wire [1:0] digit_sel;
wire [3:0] current_digit;

assign count_enable = sw[0] && running && tick_0p01s;

assign led[0] = running;
assign led[4:1] = digit0;
assign led[15:5] = 11'd0;

clock_divider_10ms u_tick(
    .clk(clk),
    .reset(btnD),
    .enable(sw[0] && running),
    .tick(tick_0p01s)
);

start_stop_control u_control(
    .clk(clk),
    .reset(btnD),
    .start(btnC),
    .stop(btnU),
    .running(running)
);

stopwatch_counter_4digit u_counter(
    .clk(clk),
    .reset(btnD),
    .enable(count_enable),
    .digit0(digit0),
    .digit1(digit1),
    .digit2(digit2),
    .digit3(digit3)
);

fnd_scan_counter u_scan(
    .clk(clk),
    .reset(btnD),
    .digit_sel(digit_sel)
);

fnd_mux_4digit_dp u_mux(
    .digit0(digit0),
    .digit1(digit1),
    .digit2(digit2),
    .digit3(digit3),
    .digit_sel(digit_sel),
    .current_digit(current_digit),
    .an(an),
    .dp(dp)
);

fnd_decoder u_decoder(
    .bcd(current_digit),
    .seg(seg)
);

endmodule
