`timescale 1ns / 1ps

// led_pwm_controller.v
//
// 8-bit PWM으로 Basys3 LED 16개의 밝기와 개수를 함께 제어한다.
//
// CTRL[0] = 0 -> LED OFF
// CTRL[0] = 1 -> LED PWM ON
//
// pwm_value 값이 커질수록
// 1. LED 밝기가 증가하고
// 2. 켜지는 LED 개수도 증가한다.
//
// pwm_value = 8'h00 -> LED 0개
// pwm_value = 8'h40 -> LED 약 4개
// pwm_value = 8'h80 -> LED 약 8개
// pwm_value = 8'hC0 -> LED 약 12개
// pwm_value = 8'hFF -> LED 16개

module led_pwm_controller #(
    parameter PWM_PRESCALE = 390
)(
    input  wire        clk,
    input  wire        reset,

    // Register Map에서 넘어온 CTRL 값이다.
    input  wire [7:0]  ctrl_reg,

    // Register Map에서 넘어온 LED 밝기값이다.
    input  wire [7:0]  pwm_value,

    // Basys3 LED 16개 출력이다.
    output reg  [15:0] led
);

    reg [7:0] pwm_counter;
    reg [15:0] prescale_counter;

    wire pwm_enable;
    wire pwm_active;
    wire prescale_tick;
    wire [4:0] led_count;
    wire [15:0] led_level_mask;

    assign pwm_enable = ctrl_reg[0];
    assign pwm_active = (pwm_counter < pwm_value);
    assign prescale_tick =
        (prescale_counter == (PWM_PRESCALE - 1));

    // pwm_value = 0       -> led_count = 0
    // pwm_value = 1~16    -> led_count = 1
    // pwm_value = 17~32   -> led_count = 2
    // ...
    // pwm_value = 241~255 -> led_count = 16
    //
    // 9-bit로 확장한 뒤 +15 하여 8-bit overflow를 방지한다.
    assign led_count =
        (pwm_value == 8'd0) ? 5'd0 :
        (({1'b0, pwm_value} + 9'd15) >> 4);

    // LED Bar Mask
    // 0  -> 0000
    // 1  -> 0001
    // 2  -> 0003
    // 8  -> 00FF
    // 16 -> FFFF
    assign led_level_mask =
        (led_count == 5'd0)  ? 16'h0000 :
        (led_count >= 5'd16) ? 16'hFFFF :
        ((16'h0001 << led_count) - 16'h0001);

    always @(posedge clk) begin
        if (reset) begin
            prescale_counter <= 16'd0;
            pwm_counter      <= 8'd0;
        end
        else begin
            if (prescale_tick) begin
                prescale_counter <= 16'd0;
                pwm_counter      <= pwm_counter + 8'd1;
            end
            else begin
                prescale_counter <= prescale_counter + 16'd1;
            end
        end
    end

    always @(*) begin
        if (pwm_enable && pwm_active) begin
            led = led_level_mask;
        end
        else begin
            led = 16'h0000;
        end
    end

endmodule
