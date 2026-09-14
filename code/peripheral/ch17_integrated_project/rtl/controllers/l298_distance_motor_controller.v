`timescale 1ns / 1ps

// l298_distance_motor_controller.v
//
// CdS 낮/밤 상태와 초음파 거리값을 이용하여
// L298 DC 모터 드라이버를 제어한다.
//
// 낮 / 밝음   : 배기, 역회전
// 밤 / 어두움 : 흡기, 정회전
//
// 10cm 이하         : 안전 정지
// 10cm 초과         : 거리 비례 속도
// DIST_LIMIT_CM 이상: 최고 속도
// 물체 없음         : 최고 속도

module l298_distance_motor_controller #(
    parameter CLK_FREQ_HZ      = 100_000_000,
    parameter PWM_FREQ_HZ      = 1000,
    parameter STOP_DISTANCE_CM = 10'd10,
    parameter DEFAULT_MAX_CM   = 10'd100
)(
    input  wire       clk,
    input  wire       reset,

    // CTRL[3]
    input  wire       motor_en,

    // CTRL[2]
    input  wire       dist_en,

    // CTRL[1]
    input  wire       cds_en,

    // 1: 낮/밝음, 0: 밤/어두움
    input  wire       cds_is_light,

    input  wire [9:0] distance_cm,
    input  wire       distance_valid,
    input  wire       no_object,

    // Register 0x02 DIST_LIMIT_CM
    input  wire [7:0] max_speed_distance_cm,

    // L298
    output wire       motor_ena_pwm,
    output reg        motor_in1,
    output reg        motor_in2,

    output reg  [7:0] motor_duty_debug
);

    localparam integer PWM_PERIOD_COUNT =
        CLK_FREQ_HZ / PWM_FREQ_HZ;

    reg [31:0] pwm_count;
    reg [7:0]  motor_duty;
    reg [9:0]  effective_distance_cm;
    reg [17:0] duty_calc;

    wire motor_base_enable;

    wire [9:0] max_speed_cm_from_reg;
    wire [9:0] max_speed_cm_safe;
    wire [9:0] speed_range_cm;

    assign motor_base_enable =
        motor_en &&
        dist_en &&
        cds_en;

    assign max_speed_cm_from_reg =
        {2'b00, max_speed_distance_cm};

    assign max_speed_cm_safe =
        (max_speed_cm_from_reg <= STOP_DISTANCE_CM) ?
        DEFAULT_MAX_CM :
        max_speed_cm_from_reg;

    assign speed_range_cm =
        max_speed_cm_safe - STOP_DISTANCE_CM;

    // PWM Counter
    always @(posedge clk) begin
        if (reset) begin
            pwm_count <= 32'd0;
        end
        else begin
            if (pwm_count >= PWM_PERIOD_COUNT - 1) begin
                pwm_count <= 32'd0;
            end
            else begin
                pwm_count <= pwm_count + 32'd1;
            end
        end
    end

    // 거리 기반 Duty 계산
    always @(*) begin
        motor_duty           = 8'h00;
        effective_distance_cm = 10'd0;
        duty_calc             = 18'd0;

        if (!motor_base_enable) begin
            motor_duty = 8'h00;
        end
        else if (no_object) begin
            // 물체가 없으면 최고 속도
            motor_duty = 8'hFF;
        end
        else if (!distance_valid) begin
            // 측정 전/측정 중은 안전 정지
            motor_duty = 8'h00;
        end
        else if (distance_cm <= STOP_DISTANCE_CM) begin
            // 10cm 이하는 안전 정지
            motor_duty = 8'h00;
        end
        else if (distance_cm >= max_speed_cm_safe) begin
            // DIST_LIMIT_CM 이상은 최고 속도
            motor_duty = 8'hFF;
        end
        else begin
            effective_distance_cm =
                distance_cm - STOP_DISTANCE_CM;

            duty_calc =
                (effective_distance_cm * 8'd255) /
                speed_range_cm;

            motor_duty = duty_calc[7:0];
        end
    end

    // CdS 낮/밤에 따른 방향 결정
    always @(*) begin
        if (motor_duty == 8'h00) begin
            motor_in1 = 1'b0;
            motor_in2 = 1'b0;
        end
        else if (cds_is_light) begin
            // 낮 / 밝음 -> 배기 -> 역회전
            motor_in1 = 1'b0;
            motor_in2 = 1'b1;
        end
        else begin
            // 밤 / 어두움 -> 흡기 -> 정회전
            motor_in1 = 1'b1;
            motor_in2 = 1'b0;
        end
    end

    always @(*) begin
        motor_duty_debug = motor_duty;
    end

    wire [31:0] pwm_compare;

    assign pwm_compare =
        (PWM_PERIOD_COUNT * motor_duty) >> 8;

    assign motor_ena_pwm =
        (!motor_base_enable)   ? 1'b0 :
        (motor_duty == 8'h00)  ? 1'b0 :
        (motor_duty == 8'hFF)  ? 1'b1 :
        (pwm_count < pwm_compare);

endmodule
