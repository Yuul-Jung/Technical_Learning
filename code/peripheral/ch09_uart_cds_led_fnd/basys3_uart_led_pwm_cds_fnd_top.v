`timescale 1ns / 1ps

// basys3_uart_led_pwm_cds_fnd_top.v
//
// Top은 보드 Pin과 재사용 모듈 연결만 담당한다.
//
// Reuse:
//   uart_core
//   uart_reg_write_controller
//   simple_register_map
//
// Added/Changed:
//   led_pwm_controller
//   cds_input_filter
//   cds_status_encoder
//   fnd_status_3digit_display

module basys3_uart_led_pwm_cds_fnd_top #(
    parameter CLK_FREQ      = 100_000_000,
    parameter BAUD_RATE     = 9600,
    parameter PWM_PRESCALE  = 390
)(
    input  wire        clk,
    input  wire        btnU,
    input  wire        RsRx,
    input  wire [0:0]  JA,

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

    // Unused TX status in this exercise
    wire       tx_full;
    wire       tx_empty;
    wire [4:0] tx_count;
    wire       tx_busy;
    wire       tx_done;

    // Register Write Interface
    wire       reg_wr_en;
    wire [7:0] reg_wr_addr;
    wire [7:0] reg_wr_data;

    // Register Map
    wire [7:0] ctrl_reg;
    wire [7:0] pwm_value_reg;
    wire       reg_error;

    // Parser debug
    wire [1:0] byte_index;
    wire [7:0] last_cmd;
    wire       cmd_error;

    // CdS
    wire       cds_sw_raw;
    wire       cds_sw_sync;
    wire       cds_is_light;
    wire [3:0] fnd_status_code;

    assign cds_sw_raw = JA[0];

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

        // 이번 과제에서는 TX 기능을 사용하지 않는다.
        .tx_wr_en       (1'b0),
        .tx_wr_data     (8'h00),

        .tx_full        (tx_full),
        .tx_empty       (tx_empty),
        .tx_count       (tx_count),
        .tx_busy        (tx_busy),
        .tx_done        (tx_done)
    );

    // ------------------------------------------------------------
    // UART 3Byte Packet → Register Write
    // ------------------------------------------------------------
    uart_reg_write_controller #(
        .CMD_WRITE(8'h01)
    ) u_uart_reg_write_controller (
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
        .clk           (clk),
        .reset         (reset),

        .reg_wr_en     (reg_wr_en),
        .reg_wr_addr   (reg_wr_addr),
        .reg_wr_data   (reg_wr_data),

        .ctrl_reg      (ctrl_reg),
        .pwm_value_reg (pwm_value_reg),
        .reg_error     (reg_error)
    );

    // ------------------------------------------------------------
    // LED PWM
    // CTRL[0] = LED PWM Enable
    // ------------------------------------------------------------
    led_pwm_controller #(
        .PWM_PRESCALE(PWM_PRESCALE)
    ) u_led_pwm_controller (
        .clk       (clk),
        .reset     (reset),

        .ctrl_reg  (ctrl_reg),
        .pwm_value (pwm_value_reg),

        .led       (led)
    );

    // ------------------------------------------------------------
    // CdS input synchronization
    // ------------------------------------------------------------
    cds_input_filter u_cds_input_filter (
        .clk          (clk),
        .reset        (reset),

        .cds_sw_raw   (cds_sw_raw),
        .cds_sw_sync  (cds_sw_sync),
        .cds_is_light (cds_is_light)
    );

    // ------------------------------------------------------------
    // CdS state → FND character code
    // ------------------------------------------------------------
    cds_status_encoder u_cds_status_encoder (
        .cds_is_light (cds_is_light),
        .status_code  (fnd_status_code)
    );

    // ------------------------------------------------------------
    // FND
    // CTRL[1] = CdS status display Enable
    // ------------------------------------------------------------
    fnd_status_3digit_display #(
        .CLK_FREQ_HZ (CLK_FREQ),
        .SCAN_HZ     (1000)
    ) u_fnd_status_3digit_display (
        .clk          (clk),
        .reset        (reset),

        .status_valid (ctrl_reg[1]),
        .status_code  (fnd_status_code),

        .value_bcd    (12'h000),
        .value_valid  (1'b0),

        .seg          (seg),
        .an           (an),
        .dp           (dp)
    );

endmodule
