`timescale 1ns / 1ps

// led_pwm_controller.v
// ------------------------------------------------------------
// LED 숨쉬기 모드가 추가된 LED PWM + LED Bar Controller이다.
//
// 기본 동작:
// - pwm_value 값이 커질수록 LED 밝기와 LED 개수가 함께 증가한다.
// - 이 기본 구조는 PWM_VALUE 기반 LED Bar Dimming 과제의 구조를 따른다.
//
// 추가 동작:
// - pwm_value = 8'hFE이면 LED Breathing Mode로 동작한다.
// - Breathing Mode에서는 LED 밝기가 서서히 증가했다가 다시 감소한다.
//
// Top Module 수정 없이 pwm_value 특수값만으로 모드를 선택한다.
// ------------------------------------------------------------

module led_pwm_controller #(
    // 100 MHz Clock 기준 약 1 kHz PWM을 만들기 위한 분주값이다.
    // 100 MHz / (390 x 256) ~= 1001.6 Hz
    parameter PWM_PRESCALE = 390,

    // (추가) 숨쉬기 밝기값을 갱신하는 속도이다.
    // 100 MHz 기준 200_000이면 약 2 ms마다 밝기값이 한 단계 변한다.
    parameter BREATH_PRESCALE = 200_000
)(
    input  wire        clk,
    input  wire        reset,

    // Register Map에서 넘어온 CTRL 값이다.
    input  wire [7:0]  ctrl_reg,

    // Register Map에서 넘어온 LED 밝기값이다.
    // 8'hFE이면 Breathing Mode로 사용한다.
    input  wire [7:0]  pwm_value,

    // Basys3 LED 16개 출력이다.
    output reg  [15:0] led
);

    // 8-bit PWM Counter이다.
    reg [7:0] pwm_counter;

    // PWM Counter 증가 속도를 낮추기 위한 Prescaler Counter이다.
    reg [15:0] prescale_counter;

    // (추가) 숨쉬기 밝기값을 천천히 바꾸기 위한 Prescaler Counter이다.
    reg [31:0] breath_prescale_counter;

    // (추가) 숨쉬기 모드에서 실제로 사용할 밝기값이다.
    reg [7:0] breath_value;

    // (추가) 숨쉬기 밝기 증가/감소 방향이다.
    // 1이면 증가, 0이면 감소이다.
    reg breath_up;

    wire pwm_enable;
    wire breath_mode;
    wire prescale_tick;
    wire breath_tick;

    // (추가) 실제 PWM 비교에 사용할 값이다.
    // 일반 모드에서는 pwm_value를 사용하고,
    // 숨쉬기 모드에서는 breath_value를 사용한다.
    wire [7:0] active_pwm_value;

    wire pwm_active;
    wire [4:0] led_count;
    wire [15:0] led_level_mask;

    assign pwm_enable   = ctrl_reg[0];
    assign breath_mode  = (pwm_value == 8'hFE);

    assign prescale_tick =
        (prescale_counter == (PWM_PRESCALE - 1));

    assign breath_tick =
        (breath_prescale_counter == (BREATH_PRESCALE - 1));

    assign active_pwm_value =
        breath_mode ? breath_value : pwm_value;

    assign pwm_active =
        (pwm_counter < active_pwm_value);

    // active_pwm_value를 LED 개수로 변환한다.
    // active_pwm_value = 0       -> led_count = 0
    // active_pwm_value = 1~16    -> led_count = 1
    // ...
    // active_pwm_value = 241~255 -> led_count = 16
    assign led_count =
        (active_pwm_value == 8'd0) ? 5'd0 :
        (({1'b0, active_pwm_value} + 9'd15) >> 4);

    // LED 개수에 맞는 LED Mask를 생성한다.
    assign led_level_mask =
        (led_count == 5'd0)  ? 16'h0000 :
        (led_count >= 5'd16) ? 16'hFFFF :
        ((16'h0001 << led_count) - 16'h0001);

    // PWM Counter 생성부이다.
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

    // (추가) Breathing Mode 밝기 생성부이다.
    always @(posedge clk) begin
        if (reset) begin
            breath_prescale_counter <= 32'd0;
            breath_value            <= 8'd0;
            breath_up               <= 1'b1;
        end
        else begin
            if (breath_tick) begin
                breath_prescale_counter <= 32'd0;

                if (breath_up) begin
                    if (breath_value == 8'hFF) begin
                        // 최대 밝기에 도달하면 감소 방향으로 바꾼다.
                        breath_up    <= 1'b0;
                        breath_value <= breath_value - 8'd1;
                    end
                    else begin
                        breath_value <= breath_value + 8'd1;
                    end
                end
                else begin
                    if (breath_value == 8'h00) begin
                        // 최소 밝기에 도달하면 증가 방향으로 바꾼다.
                        breath_up    <= 1'b1;
                        breath_value <= breath_value + 8'd1;
                    end
                    else begin
                        breath_value <= breath_value - 8'd1;
                    end
                end
            end
            else begin
                breath_prescale_counter <=
                    breath_prescale_counter + 32'd1;
            end
        end
    end

    always @(*) begin
        if (pwm_enable && pwm_active) begin
            // PWM ON 구간에서는 active_pwm_value에 비례한 개수의 LED만 켠다.
            // 일반 모드: pwm_value 기준
            // 숨쉬기 모드: breath_value 기준
            led = led_level_mask;
        end
        else begin
            led = 16'h0000;
        end
    end

endmodule
