`timescale 1ns / 1ps

// basys3_uart_led_pwm_cds_ultra_fnd_top.v
//
// Chapter 16:
// UART Register Map + LED PWM/Bar + CdS + HC-SR04 + XADC Volume + FND + L298 Motor
//
// Top Module은 보드 Pin과 하위 모듈 연결만 담당한다.
//
// 누적 사이트 기준:
// CTRL[0] : LED PWM Enable
// CTRL[1] : CdS Enable
// CTRL[2] : Ultrasonic Enable
// CTRL[3] : L298 Motor Enable
// CTRL[6] : XADC Volume 표시 Enable
// CTRL[7] : 거리 기반 LED Bar Mode (Chapter 13에서 이미 사용)
//
// XADC Volume 표시 우선순위:
// CdS > Volume > 거리 상태(n/-/F)

module basys3_uart_led_pwm_cds_ultra_fnd_top #(
    parameter CLK_FREQ  = 100_000_000,
    parameter BAUD_RATE = 9600
)(
    input  wire        clk,
    input  wire        btnU,
    input  wire        RsRx,

    input  wire        cds_in,
    input  wire        us_echo,
    output wire        us_trig,

    // L298 Motor Driver
    output wire        motor_ena_pwm,
    output wire        motor_in1,
    output wire        motor_in2,

    // XADC VAUX6
    input  wire        vauxp6,
    input  wire        vauxn6,

    // XADC Wizard 기본 VP/VN 포트
    input  wire        vp_in,
    input  wire        vn_in,

    output wire        RsTx,
    output wire [15:0] led,
    output wire [6:0]  seg,
    output wire [3:0]  an,
    output wire        dp
);

    wire reset;
    assign reset = btnU;

    // ------------------------------------------------------------
    // UART RX Stream
    // ------------------------------------------------------------
    wire [7:0] rx_stream_data;
    wire       rx_stream_valid;
    wire       rx_stream_ready;

    wire       rx_empty;
    wire       rx_full;
    wire       frame_error;
    wire       overrun_error;

    wire       tx_full;
    wire       tx_empty;
    wire [4:0] tx_count;
    wire       tx_busy;
    wire       tx_done;

    // ------------------------------------------------------------
    // Register Write
    // ------------------------------------------------------------
    wire       reg_wr_en;
    wire [7:0] reg_wr_addr;
    wire [7:0] reg_wr_data;

    wire [7:0] ctrl_reg;
    wire [7:0] pwm_value_reg;
    wire [7:0] dist_limit_cm_reg;
    wire [7:0] spi0_ctrl_reg;
    wire [7:0] i2c0_ctrl_reg;
    wire       reg_error;

    wire [1:0] byte_index;
    wire [7:0] last_cmd;
    wire       cmd_error;

    // ------------------------------------------------------------
    // Control Bit
    // ------------------------------------------------------------
    wire cds_en;
    wire dist_en;
    wire motor_en;
    wire volume_mode_en;

    assign cds_en         = ctrl_reg[1];
    assign dist_en        = ctrl_reg[2];
    assign motor_en       = ctrl_reg[3];
    assign volume_mode_en = ctrl_reg[6];

    // ------------------------------------------------------------
    // CdS
    // ------------------------------------------------------------
    wire cds_sw_sync;
    wire cds_is_light;

    // ------------------------------------------------------------
    // Ultrasonic
    // ------------------------------------------------------------
    wire [9:0]  distance_cm;
    wire [11:0] distance_bcd;
    wire        distance_valid;
    wire        no_object;
    wire        distance_busy;
    wire        distance_timeout;

    // L298 Motor Debug
    wire [7:0]  motor_duty_debug;

    // Chapter 13 거리 기반 LED Bar 선택 결과
    wire [7:0] led_pwm_value_selected;

    // ------------------------------------------------------------
    // XADC
    // ------------------------------------------------------------
    wire [11:0] xadc_raw;
    wire        xadc_valid;
    wire [3:0]  volume_digit;
    wire        volume_effective;

    // ------------------------------------------------------------
    // FND
    // ------------------------------------------------------------
    wire        fnd_status_valid;
    wire [3:0]  fnd_status_code;
    wire [11:0] fnd_value_bcd;
    wire        fnd_value_valid;

    // ------------------------------------------------------------
    // UART Core
    // ------------------------------------------------------------
    uart_core #(
        .CLK_FREQ  (CLK_FREQ),
        .BAUD_RATE (BAUD_RATE)
    ) u_uart_core (
        .clk            (clk),
        .reset          (reset),

        .rx_serial      (RsRx),
        .tx_serial      (RsTx),

        .rx_data        (rx_stream_data),
        .rx_valid       (rx_stream_valid),
        .rx_ready       (rx_stream_ready),

        .rx_empty       (rx_empty),
        .rx_full        (rx_full),
        .rx_fifo_clear  (1'b0),

        .frame_error    (frame_error),
        .overrun_error  (overrun_error),

        .tx_wr_en       (1'b0),
        .tx_wr_data     (8'h00),

        .tx_full        (tx_full),
        .tx_empty       (tx_empty),
        .tx_count       (tx_count),
        .tx_busy        (tx_busy),
        .tx_done        (tx_done)
    );

    // ------------------------------------------------------------
    // UART 3Byte Packet -> Register Write
    // ------------------------------------------------------------
    uart_reg_write_controller u_uart_reg_write_controller (
        .clk         (clk),
        .reset       (reset),

        .in_data     (rx_stream_data),
        .in_valid    (rx_stream_valid),
        .in_ready    (rx_stream_ready),

        .reg_wr_en   (reg_wr_en),
        .reg_wr_addr (reg_wr_addr),
        .reg_wr_data (reg_wr_data),

        .byte_index  (byte_index),
        .last_cmd    (last_cmd),
        .cmd_error   (cmd_error)
    );

    // ------------------------------------------------------------
    // Register Map
    // ------------------------------------------------------------
    simple_register_map u_simple_register_map (
        .clk               (clk),
        .reset             (reset),

        .reg_wr_en         (reg_wr_en),
        .reg_wr_addr       (reg_wr_addr),
        .reg_wr_data       (reg_wr_data),

        .ctrl_reg          (ctrl_reg),
        .pwm_value_reg     (pwm_value_reg),
        .dist_limit_cm_reg (dist_limit_cm_reg),
        .spi0_ctrl_reg     (spi0_ctrl_reg),
        .i2c0_ctrl_reg     (i2c0_ctrl_reg),

        .reg_error         (reg_error)
    );

    // ------------------------------------------------------------
    // 거리 기반 / UART 직접 기반 LED Bar 값 선택
    // Chapter 13 재사용
    // ------------------------------------------------------------
    distance_to_pwm_value_controller
    u_distance_to_pwm_value_controller (
        .ctrl_reg        (ctrl_reg),
        .pwm_value_reg   (pwm_value_reg),

        .distance_cm     (distance_cm),
        .distance_valid  (distance_valid),
        .timeout_error   (distance_timeout),

        .led_pwm_value   (led_pwm_value_selected)
    );

    // ------------------------------------------------------------
    // LED PWM + LED Bar + Breathing
    // Chapter 14 led_pwm_controller 재사용
    // ------------------------------------------------------------
    led_pwm_controller #(
        .PWM_PRESCALE    (390),
        .BREATH_PRESCALE (200_000)
    ) u_led_pwm_controller (
        .clk       (clk),
        .reset     (reset),

        .ctrl_reg  (ctrl_reg),
        .pwm_value (led_pwm_value_selected),

        .led       (led)
    );

    // ------------------------------------------------------------
    // CdS
    // ------------------------------------------------------------
    cds_input_filter u_cds_input_filter (
        .clk          (clk),
        .reset        (reset),

        .cds_sw_raw   (cds_in),
        .cds_sw_sync  (cds_sw_sync),
        .cds_is_light (cds_is_light)
    );

    // ------------------------------------------------------------
    // HC-SR04
    // ------------------------------------------------------------
    ultrasonic_distance_meter #(
        .CLK_FREQ_HZ(CLK_FREQ)
    ) u_ultrasonic_distance_meter (
        .clk            (clk),
        .reset          (reset),

        .enable         (dist_en),

        .echo           (us_echo),
        .trig           (us_trig),

        .distance_cm    (distance_cm),
        .distance_bcd   (distance_bcd),
        .distance_valid (distance_valid),
        .no_object      (no_object),

        .busy           (distance_busy),
        .timeout_error  (distance_timeout)
    );

    // ------------------------------------------------------------
    // L298 Motor Controller
    // CTRL[1] CdS + CTRL[2] Ultrasonic + CTRL[3] Motor
    // ------------------------------------------------------------
    l298_distance_motor_controller #(
        .CLK_FREQ_HZ      (CLK_FREQ),
        .PWM_FREQ_HZ      (1000),
        .STOP_DISTANCE_CM (10'd10),
        .DEFAULT_MAX_CM   (10'd100)
    ) u_l298_distance_motor_controller (
        .clk                   (clk),
        .reset                 (reset),

        .motor_en              (motor_en),
        .dist_en               (dist_en),
        .cds_en                (cds_en),
        .cds_is_light          (cds_is_light),

        .distance_cm           (distance_cm),
        .distance_valid        (distance_valid),
        .no_object             (no_object),

        .max_speed_distance_cm (dist_limit_cm_reg),

        .motor_ena_pwm         (motor_ena_pwm),
        .motor_in1             (motor_in1),
        .motor_in2             (motor_in2),

        .motor_duty_debug      (motor_duty_debug)
    );

    // ------------------------------------------------------------
    // XADC VAUX6 Reader
    // ------------------------------------------------------------
    xadc_analog_reader u_xadc_analog_reader (
        .clk        (clk),
        .reset      (reset),

        .vauxp6     (vauxp6),
        .vauxn6     (vauxn6),
        .vp_in      (vp_in),
        .vn_in      (vn_in),

        .xadc_raw   (xadc_raw),
        .xadc_valid (xadc_valid)
    );

    // ------------------------------------------------------------
    // XADC Raw -> 0~9
    // ------------------------------------------------------------
    xadc_volume_level_controller
    u_xadc_volume_level_controller (
        .xadc_raw     (xadc_raw),
        .volume_digit (volume_digit)
    );

    // ------------------------------------------------------------
    // FND 최상위 자리 표시 소스 선택
    // CdS > XADC Volume > 거리 상태
    // ------------------------------------------------------------
    fnd_status_volume_selector
    u_fnd_status_volume_selector (
        .cds_en           (cds_en),
        .dist_en          (dist_en),
        .volume_mode_en   (volume_mode_en),

        .cds_is_light     (cds_is_light),
        .volume_digit     (volume_digit),

        .distance_bcd     (distance_bcd),
        .distance_valid   (distance_valid),

        .volume_effective (volume_effective),
        .status_valid     (fnd_status_valid),
        .status_code      (fnd_status_code),
        .value_bcd        (fnd_value_bcd),
        .value_valid      (fnd_value_valid)
    );

    // ------------------------------------------------------------
    // FND Driver
    // Chapter 12의 n/-/F 거리 상태 표시 기능 유지
    // ------------------------------------------------------------
    fnd_status_3digit_display #(
        .CLK_FREQ_HZ (CLK_FREQ),
        .SCAN_HZ     (1000)
    ) u_fnd_status_3digit_display (
        .clk          (clk),
        .reset        (reset),

        .status_valid (fnd_status_valid),
        .status_code  (fnd_status_code),

        .value_bcd    (fnd_value_bcd),
        .value_valid  (fnd_value_valid),

        .seg          (seg),
        .an           (an),
        .dp           (dp)
    );

endmodule
