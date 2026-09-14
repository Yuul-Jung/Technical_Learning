module basys3_uart_rx_top(
    input        clk,        // Basys3 100 MHz Clock
    input        btnU,       // Reset 버튼
    input        RsRx,       // Basys3 USB-UART RX 입력
    output       RsTx,       // Basys3 USB-UART TX 출력
    output [15:0] led        // 수신 데이터 및 상태 표시
);

    wire reset;
    wire [7:0] rx_data;
    wire rx_valid;
    wire rx_ready;
    wire rx_empty;
    wire rx_full;
    wire frame_error;
    wire overrun_error;

    reg [7:0] last_rx_data;
    reg frame_error_latched;

    assign reset = btnU;

    // FIFO에 데이터가 있으면 즉시 1 Byte 읽음
    assign rx_ready = rx_valid;

    uart_rx_core u_uart_rx_core (
        .clk(clk),
        .reset(reset),
        .rx(RsRx),
        .fifo_clear(1'b0),
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .rx_ready(rx_ready),
        .rx_empty(rx_empty),
        .rx_full(rx_full),
        .frame_error(frame_error),
        .overrun_error(overrun_error)
    );

    always @(posedge clk) begin
        if (reset) begin
            last_rx_data        <= 8'd0;
            frame_error_latched <= 1'b0;
        end
        else begin
            if (rx_valid)
                last_rx_data <= rx_data;

            if (frame_error)
                frame_error_latched <= 1'b1;
        end
    end

    assign led[7:0]   = last_rx_data;
    assign led[8]     = rx_valid;
    assign led[9]     = rx_empty;
    assign led[10]    = rx_full;
    assign led[11]    = frame_error_latched;
    assign led[12]    = overrun_error;
    assign led[15:13] = 3'b000;

    // RX 전용 실습이므로 TX는 Idle=1 고정
    assign RsTx = 1'b1;

endmodule
