`timescale 1ns / 1ps

// uart_rx_core.v
// UART RX 상위 Core임.
// 내부에 uart_rx_sync, uart_baud_tick_gen, uart_rx_fsm, uart_rx_fifo를 포함함.
// CLKS_PER_SAMPLE을 외부 parameter로 받아 Baud Rate 변경과 시뮬레이션 단축에 대응함.

module uart_rx_core #(
    // uart_core 또는 Top에서 넘겨받는 16x Oversampling Tick 생성용 Clock 수임.
    // 100 MHz / (9600 bps x 16) 기준 약 651임.
    parameter CLKS_PER_SAMPLE = 651
)(
    input        clk,
    input        reset,
    input        rx,

    input        fifo_clear,

    output [7:0] rx_data,
    output       rx_valid,
    input        rx_ready,

    output       rx_empty,
    output       rx_full,

    output       frame_error,
    output       overrun_error
);

    wire rx_sync;
    wire sample_tick;

    wire [7:0] fsm_rx_data;
    wire fsm_rx_done;
    wire fsm_frame_error;

    uart_rx_sync u_uart_rx_sync (
        .clk      (clk),
        .reset    (reset),
        .rx_async (rx),
        .rx_sync  (rx_sync)
    );

    uart_baud_tick_gen #(
        .CLKS_PER_SAMPLE(CLKS_PER_SAMPLE)
    ) u_uart_baud_tick_gen (
        .clk   (clk),
        .reset (reset),
        .tick  (sample_tick)
    );

    uart_rx_fsm u_uart_rx_fsm (
        .clk         (clk),
        .reset       (reset),
        .tick        (sample_tick),
        .rx_sync     (rx_sync),
        .rx_data     (fsm_rx_data),
        .rx_done     (fsm_rx_done),
        .frame_error (fsm_frame_error)
    );

    uart_rx_fifo u_uart_rx_fifo (
        .clk           (clk),
        .reset         (reset),
        .clear         (fifo_clear),
        .wr_en         (fsm_rx_done),
        .wr_data       (fsm_rx_data),
        .rd_en         (rx_ready),
        .rd_data       (rx_data),
        .empty         (rx_empty),
        .full          (rx_full),
        .valid         (rx_valid),
        .overrun_error (overrun_error)
    );

    assign frame_error = fsm_frame_error;

endmodule
