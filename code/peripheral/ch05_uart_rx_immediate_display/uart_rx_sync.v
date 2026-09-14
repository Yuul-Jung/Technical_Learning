module uart_rx_sync(
    input  clk,        // 시스템 Clock. Basys3에서는 100 MHz Clock 사용
    input  reset,      // 동기 Reset. 1이면 내부 FF를 초기화함
    input  rx_async,   // FPGA 핀으로 들어오는 비동기 UART RX 입력
    output rx_sync     // clk 기준으로 동기화된 UART RX 신호
);

    // 첫 번째 FF: 외부 비동기 입력을 먼저 받아들이는 단계
    reg rx_meta_reg;

    // 두 번째 FF: UART RX FSM이 사용하는 동기화된 RX 신호
    reg rx_sync_reg;

    always @(posedge clk) begin
        if (reset) begin
            // UART Idle 상태는 1
            rx_meta_reg <= 1'b1;
            rx_sync_reg <= 1'b1;
        end
        else begin
            rx_meta_reg <= rx_async;
            rx_sync_reg <= rx_meta_reg;
        end
    end

    assign rx_sync = rx_sync_reg;

endmodule
