module basys3_hhmm_clock_top(
    input clk,              // Basys3 100MHz Clock
    input btnC,             // Reset 버튼
    input [15:0] sw,        // sw[0]: Enable
    output [15:0] led,      // 확인용 LED
    output [6:0] seg,       // Segment 출력, Active-Low
    output [3:0] an,        // Digit 선택, Active-Low
    output dp               // Decimal Point, Active-Low
);

wire tick_1s;
wire tick_1min;
wire [5:0] sec_count;
wire [3:0] min_ones;
wire [3:0] min_tens;
wire [3:0] hour_ones;
wire [3:0] hour_tens;
wire [1:0] digit_sel;
wire [3:0] current_digit;
wire dp_state;

assign led[0] = tick_1s;
assign led[1] = tick_1min;
assign led[7:2] = sec_count;
assign led[15:8] = 8'd0;

assign dp = (digit_sel == 2'd2) ? dp_state : 1'b1;

clock_divider_1s u_divider(
    .clk(clk),
    .reset(btnC),
    .enable(sw[0]),
    .tick_1s(tick_1s)
);

second_counter_60 u_second(
    .clk(clk),
    .reset(btnC),
    .tick_1s(tick_1s),
    .tick_1min(tick_1min),
    .sec_count(sec_count)
);

clock_counter_hhmm u_clock(
    .clk(clk),
    .reset(btnC),
    .tick_1min(tick_1min),
    .min_ones(min_ones),
    .min_tens(min_tens),
    .hour_ones(hour_ones),
    .hour_tens(hour_tens)
);

dp_blink_1hz u_dp_blink(
    .clk(clk),
    .reset(btnC),
    .enable(sw[0]),
    .dp_state(dp_state)
);

fnd_scan_counter u_scan(
    .clk(clk),
    .reset(btnC),
    .digit_sel(digit_sel)
);

fnd_mux_4digit u_mux(
    .digit0(min_ones),
    .digit1(min_tens),
    .digit2(hour_ones),
    .digit3(hour_tens),
    .digit_sel(digit_sel),
    .current_digit(current_digit),
    .an(an)
);

fnd_decoder u_decoder(
    .bcd(current_digit),
    .seg(seg)
);

endmodule
