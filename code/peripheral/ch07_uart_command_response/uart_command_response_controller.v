`timescale 1ns / 1ps

// uart_command_response_controller.v
// UART Command/Response 기능을 하나로 묶은 보드 독립 Controller임.
//
// RX 쪽:
//   rx_data / rx_valid / rx_ready
//
// TX 쪽:
//   tx_wr_data / tx_wr_en / tx_full
//
// 내부:
//   uart_line_receiver
//   → uart_command_parser
//   → uart_response_generator
//
// Top Module에는 명령 해석이나 응답 문자열 생성 기능을 넣지 않음.

module uart_command_response_controller #(
    parameter MAX_LEN = 16
)(
    input  wire       clk,
    input  wire       reset,

    input  wire [7:0] rx_data,
    input  wire       rx_valid,
    output wire       rx_ready,

    output wire [7:0] tx_wr_data,
    output wire       tx_wr_en,
    input  wire       tx_full,

    output wire       led0_state,
    output wire       response_busy,
    output wire       frame_valid,
    output wire [7:0] frame_len,
    output wire       line_overflow
);

    wire [8*MAX_LEN-1:0] frame_data;

    wire [2:0] response_sel;
    wire       response_req;

    wire [7:0] response_data;
    wire       response_valid;
    wire       response_ready;

    wire line_ready;

    // 응답을 송신하는 동안 새 명령을 추가로 소비하지 않음.
    // RX FIFO가 Backpressure Buffer 역할을 수행함.
    assign rx_ready = line_ready && !response_busy;

    uart_line_receiver #(
        .MAX_LEN(MAX_LEN)
    ) u_uart_line_receiver (
        .clk            (clk),
        .reset          (reset),

        .in_data        (rx_data),
        .in_valid       (rx_valid && !response_busy),
        .in_ready       (line_ready),

        .frame_valid    (frame_valid),
        .frame_len      (frame_len),
        .frame_data     (frame_data),
        .overflow_error (line_overflow)
    );

    uart_command_parser #(
        .MAX_LEN(MAX_LEN)
    ) u_uart_command_parser (
        .clk          (clk),
        .reset        (reset),

        .frame_valid  (frame_valid),
        .frame_len    (frame_len),
        .frame_data   (frame_data),

        .led0_state   (led0_state),
        .response_req (response_req),
        .response_sel (response_sel)
    );

    // TX FIFO가 Full이 아니면 1Byte를 받을 준비가 된 상태.
    assign response_ready = !tx_full;

    uart_response_generator u_uart_response_generator (
        .clk          (clk),
        .reset        (reset),

        .response_req (response_req),
        .response_sel (response_sel),
        .led0_state   (led0_state),

        .out_data     (response_data),
        .out_valid    (response_valid),
        .out_ready    (response_ready),

        .busy         (response_busy)
    );

    // Response Byte Stream을 현재 uart_core TX FIFO 입력으로 변환.
    assign tx_wr_data = response_data;
    assign tx_wr_en   = response_valid && response_ready;

endmodule
