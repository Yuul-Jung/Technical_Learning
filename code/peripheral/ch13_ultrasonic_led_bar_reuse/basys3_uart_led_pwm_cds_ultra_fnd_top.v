`timescale 1ns / 1ps

// basys3_uart_led_pwm_cds_ultra_fnd_top.v
//
// UART Register Map 기반
// LED PWM + CdS + HC-SR04 초음파 거리계 통합 Top.
//
// Top은 보드 핀과 모듈 연결만 담당한다.

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

    output wire        RsTx,
    output wire [15:0] led,
    output wire [6:0]  seg,
    output wire [3:0]  an,
    output wire        dp
);

    wire reset;
    assign reset = btnU;

    // UART RX Stream
    wire [7:0] rx_stream_data;
    wire       rx_stream_valid;
    wire       rx_stream_ready;

    wire       rx_empty;
    wire       rx_full;
    wire       frame_error;
    wire       overrun_error;

    // UART TX 상태
    wire       tx_full;
    wire       tx_empty;
    wire [4:0] tx_count;
    wire       tx_busy;
    wire       tx_done;

    // Register Write
    wire       reg_wr_en;
    wire [7:0] reg_wr_addr;
    wire [7:0] reg_wr_data;

    // Register Map
    wire [7:0] ctrl_reg;
    wire [7:0] pwm_value_reg;
    wire [7:0] dist_limit_cm_reg;
    wire [7:0] spi0_ctrl_reg;
    wire [7:0] i2c0_ctrl_reg;
    wire       reg_error;

    // Parser Debug
    wire [1:0] byte_index;
    wire [7:0] last_cmd;
    wire       cmd_error;

    // CdS
    wire cds_sw_sync;
    wire cds_is_light;

    // Control Bit
    wire cds_en;
    wire dist_en;

    assign cds_en  = ctrl_reg[1];
    assign dist_en = ctrl_reg[2];

    // Ultrasonic
    wire [9:0]  distance_cm;
    wire [11:0] distance_bcd;
    wire        distance_valid;
    wire        distance_busy;
    wire        distance_timeout;

    // (추가) 최종 LED Bar PWM 값
    wire [7:0]  led_pwm_value_selected;

    // FND
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

        // 이번 과제에서는 UART TX Data를 사용하지 않음
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
    // (추가) 거리값 -> 기존 LED Bar용 PWM_VALUE 변환
    // CTRL[7] = 0 : 기존 pwm_value_reg 사용
    // CTRL[7] = 1 : 초음파 거리 기반 값 사용
    // ------------------------------------------------------------
    distance_to_pwm_value_controller u_distance_to_pwm_value_controller (
        .ctrl_reg        (ctrl_reg),
        .pwm_value_reg   (pwm_value_reg),

        .distance_cm     (distance_cm),
        .distance_valid  (distance_valid),
        .timeout_error   (distance_timeout),

        .led_pwm_value   (led_pwm_value_selected)
    );

    // ------------------------------------------------------------
    // LED Bar PWM - Chapter 10 모듈 수정 없이 재사용
    // ------------------------------------------------------------
    led_pwm_controller #(
        .PWM_PRESCALE(390)
    ) u_led_pwm_controller (
        .clk       (clk),
        .reset     (reset),

        .ctrl_reg  (ctrl_reg),
        .pwm_value (led_pwm_value_selected),

        .led       (led)
    );

    // ------------------------------------------------------------
    // CdS - Chapter 09 재사용
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

        .busy           (distance_busy),
        .timeout_error  (distance_timeout)
    );

    // ------------------------------------------------------------
    // FND 표시 정책
    // ------------------------------------------------------------
    fnd_sensor_status_controller u_fnd_sensor_status_controller (
        .cds_en         (cds_en),
        .dist_en        (dist_en),
        .cds_is_light   (cds_is_light),

        .distance_bcd   (distance_bcd),
        .distance_valid (distance_valid),

        .status_valid   (fnd_status_valid),
        .status_code    (fnd_status_code),
        .value_bcd      (fnd_value_bcd),
        .value_valid    (fnd_value_valid)
    );

    // ------------------------------------------------------------
    // FND Driver
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
