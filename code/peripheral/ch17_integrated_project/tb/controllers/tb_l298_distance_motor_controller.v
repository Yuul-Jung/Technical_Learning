`timescale 1ns / 1ps

// tb_l298_distance_motor_controller.v
//
// l298_distance_motor_controller 단위 테스트벤치이다.
//
// 실제 L298 모터 드라이버와 DC 모터는 사용하지 않는다.
// motor_ena_pwm, motor_in1, motor_in2 출력만 검증한다.
//
// 시뮬레이션 시간을 줄이기 위해 1MHz Clock을 사용한다.
// PWM은 1kHz로 설정한다.

module tb_l298_distance_motor_controller;

    parameter CLK_FREQ_HZ  = 1_000_000;
    parameter PWM_FREQ_HZ  = 1_000;
    parameter CLK_PERIOD_NS = 1000;

    reg clk;
    reg reset;

    reg        motor_en;
    reg        dist_en;
    reg        cds_en;
    reg        cds_is_light;
    reg [9:0]  distance_cm;
    reg        distance_valid;
    reg        no_object;
    reg [7:0]  max_speed_distance_cm;

    wire       motor_ena_pwm;
    wire       motor_in1;
    wire       motor_in2;
    wire [7:0] motor_duty_debug;

    integer pwm_high_count;

    l298_distance_motor_controller #(
        .CLK_FREQ_HZ      (CLK_FREQ_HZ),
        .PWM_FREQ_HZ      (PWM_FREQ_HZ),
        .STOP_DISTANCE_CM (10),
        .DEFAULT_MAX_CM   (100)
    ) dut (
        .clk                   (clk),
        .reset                 (reset),

        .motor_en              (motor_en),
        .dist_en               (dist_en),
        .cds_en                (cds_en),
        .cds_is_light          (cds_is_light),

        .distance_cm           (distance_cm),
        .distance_valid        (distance_valid),
        .no_object             (no_object),

        .max_speed_distance_cm (max_speed_distance_cm),

        .motor_ena_pwm         (motor_ena_pwm),
        .motor_in1             (motor_in1),
        .motor_in2             (motor_in2),

        .motor_duty_debug      (motor_duty_debug)
    );

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD_NS / 2) clk = ~clk;
    end

    task wait_clocks;
        input integer count;
        integer i;
        begin
            for (i = 0; i < count; i = i + 1) begin
                @(posedge clk);
            end
        end
    endtask

    task count_pwm_high;
        input integer sample_count;
        output integer high_count;
        integer i;
        begin
            high_count = 0;

            for (i = 0; i < sample_count; i = i + 1) begin
                @(posedge clk);

                if (motor_ena_pwm) begin
                    high_count = high_count + 1;
                end
            end
        end
    endtask

    task check_stop;
        input [255:0] test_name;
        begin
            wait_clocks(10);

            if (motor_ena_pwm !== 1'b0) begin
                $display(
                    "ERROR: %0s - motor_ena_pwm should be 0",
                    test_name
                );
                $finish;
            end

            if (motor_in1 !== 1'b0 ||
                motor_in2 !== 1'b0) begin

                $display(
                    "ERROR: %0s - motor direction should be stop",
                    test_name
                );
                $finish;
            end

            if (motor_duty_debug !== 8'h00) begin
                $display(
                    "ERROR: %0s - motor_duty_debug should be 0",
                    test_name
                );
                $finish;
            end
        end
    endtask

    task check_direction;
        input [255:0] test_name;
        input expected_in1;
        input expected_in2;
        begin
            wait_clocks(10);

            if (motor_in1 !== expected_in1 ||
                motor_in2 !== expected_in2) begin

                $display(
                    "ERROR: %0s - direction mismatch. IN1=%b IN2=%b",
                    test_name,
                    motor_in1,
                    motor_in2
                );
                $finish;
            end
        end
    endtask

    task check_pwm_range;
        input [255:0] test_name;
        input integer min_high_count;
        input integer max_high_count;
        begin
            count_pwm_high(
                1000,
                pwm_high_count
            );

            if (pwm_high_count < min_high_count ||
                pwm_high_count > max_high_count) begin

                $display(
                    "ERROR: %0s - PWM high count out of range. count=%0d",
                    test_name,
                    pwm_high_count
                );
                $finish;
            end
        end
    endtask

    initial begin
        reset                 = 1'b1;
        motor_en              = 1'b0;
        dist_en               = 1'b0;
        cds_en                = 1'b0;
        cds_is_light          = 1'b0;
        distance_cm           = 10'd0;
        distance_valid        = 1'b0;
        no_object             = 1'b0;
        max_speed_distance_cm = 8'd100;

        wait_clocks(20);

        reset = 1'b0;
        wait_clocks(20);

        // Reset 이후 기본 정지
        check_stop("Reset default stop");

        // motor_en OFF -> 정지
        motor_en       = 1'b0;
        dist_en        = 1'b1;
        cds_en         = 1'b1;
        cds_is_light   = 1'b1;
        distance_cm    = 10'd50;
        distance_valid = 1'b1;
        no_object      = 1'b0;

        check_stop("motor_en off stop");

        // dist_en OFF -> 정지
        motor_en       = 1'b1;
        dist_en        = 1'b0;
        cds_en         = 1'b1;
        cds_is_light   = 1'b1;
        distance_cm    = 10'd50;
        distance_valid = 1'b1;
        no_object      = 1'b0;

        check_stop("dist_en off stop");

        // cds_en OFF -> 정지
        motor_en       = 1'b1;
        dist_en        = 1'b1;
        cds_en         = 1'b0;
        cds_is_light   = 1'b1;
        distance_cm    = 10'd50;
        distance_valid = 1'b1;
        no_object      = 1'b0;

        check_stop("cds_en off stop");

        // 거리 측정 전 -> 정지
        motor_en       = 1'b1;
        dist_en        = 1'b1;
        cds_en         = 1'b1;
        cds_is_light   = 1'b1;
        distance_cm    = 10'd50;
        distance_valid = 1'b0;
        no_object      = 1'b0;

        check_stop("distance not valid stop");

        // 5cm -> 안전 정지
        distance_cm    = 10'd5;
        distance_valid = 1'b1;
        no_object      = 1'b0;

        check_stop("5cm safety stop");

        // 10cm -> 안전 정지
        distance_cm = 10'd10;

        check_stop("10cm safety stop");

        // 낮, 20cm -> 배기 역회전 + 저속 PWM
        cds_is_light   = 1'b1;
        distance_cm    = 10'd20;
        distance_valid = 1'b1;
        no_object      = 1'b0;

        check_direction(
            "day 20cm reverse exhaust",
            1'b0,
            1'b1
        );

        check_pwm_range(
            "day 20cm low pwm",
            50,
            200
        );

        // 밤, 50cm -> 흡기 정회전 + 중속 PWM
        cds_is_light   = 1'b0;
        distance_cm    = 10'd50;
        distance_valid = 1'b1;
        no_object      = 1'b0;

        check_direction(
            "night 50cm forward intake",
            1'b1,
            1'b0
        );

        check_pwm_range(
            "night 50cm mid pwm",
            350,
            550
        );

        // 낮, 100cm -> 배기 역회전 + 최고 속도
        cds_is_light   = 1'b1;
        distance_cm    = 10'd100;
        distance_valid = 1'b1;
        no_object      = 1'b0;

        check_direction(
            "day 100cm reverse exhaust",
            1'b0,
            1'b1
        );

        check_pwm_range(
            "day 100cm max pwm",
            1000,
            1000
        );

        // 밤, 물체 없음 -> 흡기 정회전 + 최고 속도
        cds_is_light   = 1'b0;
        distance_cm    = 10'd0;
        distance_valid = 1'b0;
        no_object      = 1'b1;

        check_direction(
            "night no object forward intake",
            1'b1,
            1'b0
        );

        check_pwm_range(
            "night no object max pwm",
            1000,
            1000
        );

        // 낮, 물체 없음 -> 배기 역회전 + 최고 속도
        cds_is_light   = 1'b1;
        distance_cm    = 10'd0;
        distance_valid = 1'b0;
        no_object      = 1'b1;

        check_direction(
            "day no object reverse exhaust",
            1'b0,
            1'b1
        );

        check_pwm_range(
            "day no object max pwm",
            1000,
            1000
        );

        $display(
            "PASS: l298_distance_motor_controller test completed."
        );

        $finish;
    end

endmodule
