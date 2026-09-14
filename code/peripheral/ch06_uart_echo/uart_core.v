`timescale 1ns / 1ps

// uart_core.v
// UART RX Core와 UART TX Core를 하나로 묶는 순수 UART 송수신 Core임.
// AXI4-Lite 확장을 고려하여 보드 버튼, LED, BRAM Line Buffer는 포함하지 않음.
// CLK_FREQ와 BAUD_RATE를 parameter로 두어 내부 Clock Count 하드코딩을 줄임.

module uart_core #(
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD_RATE = 9600,
    parameter RX_OVERSAMPLE = 16,

    parameter CLKS_PER_SAMPLE = CLK_FREQ / (BAUD_RATE * RX_OVERSAMPLE),
    parameter CLKS_PER_BIT = CLK_FREQ / BAUD_RATE
)(
    input  wire       clk,
    input  wire       reset,

    input  wire       rx_serial,
    output wire       tx_serial,

    output wire [7:0] rx_data,
    output wire       rx_valid,
    input  wire       rx_ready,

    output wire       rx_empty,
    output wire       rx_full,
    input  wire       rx_fifo_clear,

    output wire       frame_error,
    output wire       overrun_error,

    input  wire       tx_wr_en,
    input  wire [7:0] tx_wr_data,

    output wire       tx_full,
    output wire       tx_empty,
    output wire [4:0] tx_count,

    output wire       tx_busy,
    output wire       tx_done
);

    uart_rx_core #(
        .CLKS_PER_SAMPLE(CLKS_PER_SAMPLE)
    ) u_uart_rx_core (
        .clk           (clk),
        .reset         (reset),
        .rx            (rx_serial),

        .fifo_clear    (rx_fifo_clear),

        .rx_data       (rx_data),
        .rx_valid      (rx_valid),
        .rx_ready      (rx_ready),

        .rx_empty      (rx_empty),
        .rx_full       (rx_full),

        .frame_error   (frame_error),
        .overrun_error (overrun_error)
    );

    uart_tx_core #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) u_uart_tx_core (
        .clk        (clk),
        .reset      (reset),

        .tx_wr_en   (tx_wr_en),
        .tx_wr_data (tx_wr_data),

        .tx_full    (tx_full),
        .tx_empty   (tx_empty),
        .tx_count   (tx_count),

        .tx_busy    (tx_busy),
        .tx_done    (tx_done),

        .tx_serial  (tx_serial)
    );

endmodule
