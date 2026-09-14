`timescale 1ns / 1ps

// basys3_uart_command_top.v
// Basys3 UART Command/Response Top.
//
// Top은 보드 핀 연결과 Core/Controller 연결만 담당함.
// 명령 해석, LF 감지, 응답 문자열 생성은 Controller 내부 모듈이 담당함.

module basys3_uart_command_top #(
    parameter CLK_FREQ  = 100_000_000,
    parameter BAUD_RATE = 9600
)(
    input  wire        clk,
    input  wire        btnU,
    input  wire        RsRx,
    output wire        RsTx,
    output wire [15:0] led
);

    wire reset;

    wire [7:0] rx_data;
    wire       rx_valid;
    wire       rx_ready;
    wire       rx_empty;
    wire       rx_full;
    wire       frame_error;
    wire       overrun_error;

    wire [7:0] tx_wr_data;
    wire       tx_wr_en;
    wire       tx_full;
    wire       tx_empty;
    wire [4:0] tx_count;
    wire       tx_busy;
    wire       tx_done;

    wire       led0_state;
    wire       response_busy;
    wire       frame_valid;
    wire [7:0] frame_len;
    wire       line_overflow;

    assign reset = btnU;

    uart_core #(
        .CLK_FREQ  (CLK_FREQ),
        .BAUD_RATE (BAUD_RATE)
    ) u_uart_core (
        .clk            (clk),
        .reset          (reset),

        .rx_serial      (RsRx),
        .tx_serial      (RsTx),

        .rx_data        (rx_data),
        .rx_valid       (rx_valid),
        .rx_ready       (rx_ready),
        .rx_empty       (rx_empty),
        .rx_full        (rx_full),
        .rx_fifo_clear  (1'b0),
        .frame_error    (frame_error),
        .overrun_error  (overrun_error),

        .tx_wr_en       (tx_wr_en),
        .tx_wr_data     (tx_wr_data),
        .tx_full        (tx_full),
        .tx_empty       (tx_empty),
        .tx_count       (tx_count),
        .tx_busy        (tx_busy),
        .tx_done        (tx_done)
    );

    uart_command_response_controller #(
        .MAX_LEN(16)
    ) u_uart_command_response_controller (
        .clk           (clk),
        .reset         (reset),

        .rx_data       (rx_data),
        .rx_valid      (rx_valid),
        .rx_ready      (rx_ready),

        .tx_wr_data    (tx_wr_data),
        .tx_wr_en      (tx_wr_en),
        .tx_full       (tx_full),

        .led0_state    (led0_state),
        .response_busy (response_busy),
        .frame_valid   (frame_valid),
        .frame_len     (frame_len),
        .line_overflow (line_overflow)
    );

    // 상태 확인용 단순 연결
    assign led[0]     = led0_state;
    assign led[1]     = response_busy;
    assign led[2]     = line_overflow;
    assign led[3]     = frame_error;
    assign led[4]     = overrun_error;
    assign led[5]     = rx_full;
    assign led[6]     = tx_full;
    assign led[7]     = tx_busy;
    assign led[15:8]  = 8'd0;

endmodule
