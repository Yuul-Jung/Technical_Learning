`timescale 1ns / 1ps

// tb_uart_echo_controller.v
// UART 직렬 파형 전체가 아니라 Echo Controller의 Byte 이동 조건을 검증함.

module tb_uart_echo_controller;

    reg        rx_valid;
    reg [7:0]  rx_data;
    reg        tx_full;

    wire       rx_ready;
    wire       tx_wr_en;
    wire [7:0] tx_wr_data;

    uart_echo_controller dut (
        .rx_valid   (rx_valid),
        .rx_data    (rx_data),
        .rx_ready   (rx_ready),
        .tx_full    (tx_full),
        .tx_wr_en   (tx_wr_en),
        .tx_wr_data (tx_wr_data)
    );

    initial begin
        rx_valid = 1'b0;
        rx_data  = 8'h00;
        tx_full  = 1'b0;
        #10;

        // Test 1: 'A' 수신, TX FIFO 공간 있음
        rx_data  = 8'h41;
        rx_valid = 1'b1;
        #1;

        if (rx_ready && tx_wr_en && tx_wr_data == 8'h41)
            $display("PASS: 0x41 Echo transfer enabled");
        else
            $display("FAIL: 0x41 Echo transfer");

        #9;

        // Test 2: TX FIFO Full이면 RX를 소비하지 않음
        rx_data  = 8'h61;
        tx_full  = 1'b1;
        #1;

        if (!rx_ready && !tx_wr_en)
            $display("PASS: Backpressure while TX FIFO full");
        else
            $display("FAIL: Backpressure");

        #9;

        // Test 3: Full 해제 후 같은 Byte 전송 가능
        tx_full = 1'b0;
        #1;

        if (rx_ready && tx_wr_en && tx_wr_data == 8'h61)
            $display("PASS: 0x61 transfer after TX FIFO available");
        else
            $display("FAIL: Transfer after backpressure");

        #9;
        rx_valid = 1'b0;

        $display("Simulation finished.");
        $finish;
    end

endmodule
