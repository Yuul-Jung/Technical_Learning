`timescale 1ns / 1ps

// uart_echo_controller.v
// UART RX로 수신한 Byte를 UART TX FIFO에 그대로 전달하는 Echo Controller임.
//
// 현재 프로젝트의 표준 UART Core 인터페이스에 맞춘 구조임.
// RX : rx_data / rx_valid / rx_ready
// TX : tx_wr_data / tx_wr_en / tx_full
//
// TX FIFO가 Full이면 RX FIFO를 읽지 않으므로 수신 Byte를 버리지 않고 대기함.

module uart_echo_controller (
    input  wire       rx_valid,
    input  wire [7:0] rx_data,
    output wire       rx_ready,

    input  wire       tx_full,
    output wire       tx_wr_en,
    output wire [7:0] tx_wr_data
);

    // RX 데이터가 있고 TX FIFO에 공간이 있을 때만 1Byte를 이동함.
    wire transfer;

    assign transfer = rx_valid && !tx_full;

    // RX FIFO Read와 TX FIFO Write가 같은 Clock Edge에서 수행되도록 함.
    assign rx_ready   = transfer;
    assign tx_wr_en   = transfer;
    assign tx_wr_data = rx_data;

endmodule
