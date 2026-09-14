`timescale 1ns / 1ps

// basys3_uart_echo_top.v
// Basys3 UART Echo 통합 Top임.
//
// Top은 보드 핀 연결과 모듈 연결만 담당함.
// Echo 기능은 uart_echo_controller에 분리함.

module basys3_uart_echo_top #(
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

    wire       tx_wr_en;
    wire [7:0] tx_wr_data;
    wire       tx_full;
    wire       tx_empty;
    wire [4:0] tx_count;
    wire       tx_busy;
    wire       tx_done;

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

    uart_echo_controller u_uart_echo_controller (
        .rx_valid   (rx_valid),
        .rx_data    (rx_data),
        .rx_ready   (rx_ready),

        .tx_full    (tx_full),
        .tx_wr_en   (tx_wr_en),
        .tx_wr_data (tx_wr_data)
    );

    // 단순 상태 관찰용 LED
    assign led[7:0]   = rx_data;
    assign led[8]     = rx_valid;
    assign led[9]     = rx_ready;
    assign led[10]    = tx_full;
    assign led[11]    = tx_empty;
    assign led[12]    = tx_busy;
    assign led[13]    = tx_done;
    assign led[14]    = frame_error;
    assign led[15]    = overrun_error;

endmodule
