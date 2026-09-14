`timescale 1ns / 1ps
module led_pwm_controller #(
    parameter PWM_PRESCALE = 390
)(
    input wire clk, input wire reset,
    input wire [7:0] ctrl_reg, input wire [7:0] pwm_value,
    output reg [15:0] led
);
    reg [7:0] pwm_counter;
    reg [15:0] prescale_counter;
    wire pwm_enable = (ctrl_reg == 8'h01);
    wire pwm_active = (pwm_counter < pwm_value);
    wire prescale_tick = (prescale_counter == (PWM_PRESCALE - 1));

    always @(posedge clk) begin
        if (reset) begin
            prescale_counter <= 16'd0;
            pwm_counter <= 8'd0;
        end else if (prescale_tick) begin
            prescale_counter <= 16'd0;
            pwm_counter <= pwm_counter + 8'd1;
        end else begin
            prescale_counter <= prescale_counter + 16'd1;
        end
    end

    always @(*) begin
        if (pwm_enable) led = {16{pwm_active}};
        else led = 16'h0000;
    end
endmodule
