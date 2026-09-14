`timescale 1ns / 1ps

// distance_to_pwm_value_controller.v
// ------------------------------------------------------------
// 초음파 거리값을 기존 LED Bar 모듈이 사용할 수 있는
// 8-bit pwm_value 형태로 변환하는 하위 모듈이다.
//
// 핵심 목적:
// Chapter 10에서 완성한 led_pwm_controller.v는 수정하지 않고 재사용한다.
//
// CTRL[7] = 0 -> 기존 UART PWM_VALUE Register를 그대로 사용한다.
// CTRL[7] = 1 -> 초음파 거리값 기반 pwm_value를 사용한다.
//
// CTRL[2] = 초음파 거리계 Enable
// CTRL[0] = LED PWM Enable
// ------------------------------------------------------------

module distance_to_pwm_value_controller (
    // Register Map에서 넘어온 CTRL 값이다.
    input  wire [7:0] ctrl_reg,

    // 기존 UART Register Map의 PWM_VALUE 값이다.
    input  wire [7:0] pwm_value_reg,

    // ultrasonic_distance_meter에서 넘어온 거리값이다.
    input  wire [9:0] distance_cm,

    // 거리값이 유효한지 나타낸다.
    input  wire       distance_valid,

    // 초음파 측정 Timeout 여부이다.
    input  wire       timeout_error,

    // led_pwm_controller.v로 전달할 최종 pwm_value이다.
    output reg  [7:0] led_pwm_value
);

    // CTRL[7]을 거리 기반 LED Bar 모드 선택 bit로 사용한다.
    wire distance_led_mode;

    // CTRL[2]가 1이면 초음파 거리계 기능이 켜진 상태이다.
    wire dist_enable;

    assign distance_led_mode = ctrl_reg[7];
    assign dist_enable       = ctrl_reg[2];

    always @(*) begin
        if (!distance_led_mode) begin
            // 기본 모드에서는 기존 PWM_VALUE Register를 그대로 사용한다.
            led_pwm_value = pwm_value_reg;
        end
        else if (!dist_enable) begin
            // 거리 모드는 켜졌지만 초음파 기능이 꺼져 있으면
            // 기존 PWM_VALUE Register를 그대로 사용한다.
            led_pwm_value = pwm_value_reg;
        end
        else if (!distance_valid || timeout_error) begin
            // 거리값이 유효하지 않거나 Timeout이면 LED Bar를 끈다.
            led_pwm_value = 8'h00;
        end
        else begin
            // 가까울수록 더 큰 pwm_value를 만든다.
            if (distance_cm < 10'd10) begin
                led_pwm_value = 8'hFF;
            end
            else if (distance_cm < 10'd20) begin
                led_pwm_value = 8'hE0;
            end
            else if (distance_cm < 10'd30) begin
                led_pwm_value = 8'hC0;
            end
            else if (distance_cm < 10'd50) begin
                led_pwm_value = 8'h80;
            end
            else if (distance_cm < 10'd80) begin
                led_pwm_value = 8'h40;
            end
            else begin
                led_pwm_value = 8'h10;
            end
        end
    end

endmodule
