`timescale 1ns / 1ps

// tb_distance_to_pwm_value_controller.v
// ------------------------------------------------------------
// distance_to_pwm_value_controller 하위 모듈 단독 Testbench.
//
// 검증:
// CTRL[7]=0              -> 기존 PWM_VALUE 사용
// CTRL[7]=1, CTRL[2]=0   -> 기존 PWM_VALUE 사용
// CTRL[7]=1, CTRL[2]=1   -> 거리 기반 PWM_VALUE 사용
// distance_valid=0       -> 0x00
// timeout_error=1        -> 0x00
// ------------------------------------------------------------

module tb_distance_to_pwm_value_controller;

    reg  [7:0] ctrl_reg;
    reg  [7:0] pwm_value_reg;
    reg  [9:0] distance_cm;
    reg        distance_valid;
    reg        timeout_error;

    wire [7:0] led_pwm_value;

    integer error_count;

    distance_to_pwm_value_controller dut (
        .ctrl_reg       (ctrl_reg),
        .pwm_value_reg  (pwm_value_reg),
        .distance_cm    (distance_cm),
        .distance_valid (distance_valid),
        .timeout_error  (timeout_error),
        .led_pwm_value  (led_pwm_value)
    );

    task check_value;
        input [7:0] in_ctrl;
        input [7:0] in_pwm;
        input [9:0] in_distance;
        input       in_valid;
        input       in_timeout;
        input [7:0] expected_value;

        begin
            ctrl_reg       = in_ctrl;
            pwm_value_reg  = in_pwm;
            distance_cm    = in_distance;
            distance_valid = in_valid;
            timeout_error  = in_timeout;

            #1;

            if (led_pwm_value !== expected_value) begin
                $display(
                    "FAIL: ctrl=%h pwm=%h distance=%0d valid=%b timeout=%b expected=%h actual=%h",
                    in_ctrl,
                    in_pwm,
                    in_distance,
                    in_valid,
                    in_timeout,
                    expected_value,
                    led_pwm_value
                );

                error_count = error_count + 1;
            end
            else begin
                $display(
                    "PASS: ctrl=%h distance=%0d led_pwm_value=%h",
                    in_ctrl,
                    in_distance,
                    led_pwm_value
                );
            end
        end
    endtask

    initial begin
        error_count = 0;

        // CTRL[7] = 0 -> 기존 PWM_VALUE
        check_value(
            8'h01, 8'h80, 10'd9,
            1'b1, 1'b0, 8'h80
        );

        // CTRL[7] = 1이어도 CTRL[2] = 0 -> 기존 PWM_VALUE
        check_value(
            8'h81, 8'h40, 10'd9,
            1'b1, 1'b0, 8'h40
        );

        // 거리 기반 모드
        check_value(8'h84, 8'h00, 10'd9,   1'b1, 1'b0, 8'hFF);
        check_value(8'h84, 8'h00, 10'd15,  1'b1, 1'b0, 8'hE0);
        check_value(8'h84, 8'h00, 10'd25,  1'b1, 1'b0, 8'hC0);
        check_value(8'h84, 8'h00, 10'd40,  1'b1, 1'b0, 8'h80);
        check_value(8'h84, 8'h00, 10'd60,  1'b1, 1'b0, 8'h40);
        check_value(8'h84, 8'h00, 10'd100, 1'b1, 1'b0, 8'h10);

        // Invalid
        check_value(
            8'h84, 8'hC0, 10'd25,
            1'b0, 1'b0, 8'h00
        );

        // Timeout
        check_value(
            8'h84, 8'hC0, 10'd25,
            1'b1, 1'b1, 8'h00
        );

        if (error_count == 0) begin
            $display(
                "ALL TESTS PASSED: tb_distance_to_pwm_value_controller"
            );
        end
        else begin
            $display(
                "TEST FAILED: error_count=%0d",
                error_count
            );
        end

        $finish;
    end

endmodule
