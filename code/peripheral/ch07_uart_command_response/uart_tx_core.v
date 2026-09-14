`timescale 1ns / 1ps

// uart_tx_core.v
// UART TX 상위 Core임.
// 내부에 uart_tx_fifo, uart_tx_sender, uart_tx_fsm을 포함함.

module uart_tx_core #(
    parameter CLKS_PER_BIT = 10417
)(
    input  wire       clk,
    input  wire       reset,
    input  wire       tx_wr_en,
    input  wire [7:0] tx_wr_data,
    output wire       tx_full,
    output wire       tx_empty,
    output wire [4:0] tx_count,
    output wire       tx_busy,
    output wire       tx_done,
    output wire       tx_serial
);

    wire [7:0] fifo_rd_data;
    wire       fifo_empty;
    wire       fifo_rd_en;
    wire [7:0] tx_data;
    wire       tx_start;

    uart_tx_fifo u_uart_tx_fifo (
        .clk     (clk),
        .reset   (reset),
        .wr_en   (tx_wr_en),
        .wr_data (tx_wr_data),
        .rd_en   (fifo_rd_en),
        .rd_data (fifo_rd_data),
        .full    (tx_full),
        .empty   (fifo_empty),
        .count   (tx_count)
    );

    assign tx_empty = fifo_empty;

    uart_tx_sender u_uart_tx_sender (
        .clk          (clk),
        .reset        (reset),
        .fifo_rd_data (fifo_rd_data),
        .fifo_empty   (fifo_empty),
        .fifo_rd_en   (fifo_rd_en),
        .tx_data      (tx_data),
        .tx_start     (tx_start),
        .tx_busy      (tx_busy)
    );

    uart_tx_fsm #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) u_uart_tx_fsm (
        .clk       (clk),
        .reset     (reset),
        .tx_start  (tx_start),
        .tx_data   (tx_data),
        .tx_serial (tx_serial),
        .tx_busy   (tx_busy),
        .tx_done   (tx_done)
    );

endmodule
