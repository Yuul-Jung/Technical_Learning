`timescale 1ns / 1ps

// led_pwm_controller.v
//
// Chapter 08과 같은 8-bit PWM 구조를 사용한다.
//
// (변경) CTRL Register를 bit field로 확장하므로
//        전체 ctrl_reg == 8'h01 비교가 아니라 CTRL[0]만 사용한다.
//
// CTRL[0] = 0 -> LED PWM OFF
// CTRL[0] = 1 -> LED PWM ON
//
// 100 MHz / (390 * 256) ~= 1001.6 Hz

module led_pwm_controller #(
    parameter PWM_PRESCALE = 390
)(
    input  wire        clk,
    input  wire        reset,
    input  wire [7:0]  ctrl_reg,
    input  wire [7:0]  pwm_value,
    output reg  [15:0] led
);

    reg [7:0]  pwm_counter;
    reg [15:0] prescale_counter;

    wire pwm_enable;
    wire pwm_active;
    wire prescale_tick;

    // (변경) CTRL 전체값이 아니라 bit 0만 LED PWM Enable로 사용한다.
    assign pwm_enable = ctrl_reg[0];

    assign pwm_active = (pwm_counter < pwm_value);
    assign prescale_tick =
        (prescale_counter == (PWM_PRESCALE - 1));

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
        if (pwm_enable) begin
            led = {16{pwm_active}};
        end
        else begin
            led = 16'h0000;
        end
    end

endmodule
