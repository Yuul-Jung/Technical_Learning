module basys3_uart_bram_line_rx_top(
    input         clk,
    input         btnU,
    input         RsRx,
    output        RsTx,
    output [15:0] led
);

    wire reset;

    // 기존 UART RX Core 연결
    wire [7:0] rx_data;
    wire rx_valid;
    wire rx_ready;
    wire rx_empty;
    wire rx_full;
    wire frame_error;
    wire overrun_error;

    // BRAM Line Buffer 상태
    wire [7:0] line_last_data;
    wire line_frame_valid;
    wire [6:0] line_frame_length;
    wire line_receiving;
    wire line_overflow;
    wire line_discarding;
    wire line_rx_ready;

    // LED 표시 유지용 Register
    reg [25:0] display_div;
    reg [7:0] display_last_data;
    reg [6:0] display_frame_length;
    reg frame_valid_latched;

    assign reset = btnU;

    // 단계01의 rx_ready = rx_valid 방식에서 변경:
    // FIFO 읽기 제어권을 BRAM Line Buffer가 가짐
    assign rx_ready = line_rx_ready;

    // 기존 UART RX Core 재사용
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

    // 새 BRAM Line Buffer
    rx_bram_line_buffer u_rx_bram_line_buffer (
        .clk(clk),
        .reset(reset),
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .rx_ready(line_rx_ready),
        .last_data(line_last_data),
        .frame_valid(line_frame_valid),
        .frame_length(line_frame_length),
        .receiving(line_receiving),
        .overflow(line_overflow),
        .discarding(line_discarding)
    );

    always @(posedge clk) begin
        if (reset) begin
            display_div          <= 26'd0;
            display_last_data    <= 8'd0;
            display_frame_length <= 7'd0;
            frame_valid_latched  <= 1'b0;
        end
        else begin
            display_div <= display_div + 1'b1;

            // LF를 만나 Frame이 완료되면 표시할 값을 저장함
            if (line_frame_valid) begin
                display_last_data    <= line_last_data;
                display_frame_length <= line_frame_length;
                frame_valid_latched  <= 1'b1;
                display_div          <= 26'd0;
            end

            // 표시용 분주 Counter의 상위 비트가 1이 되면 Frame 표시를 해제함
            else if (display_div[25]) begin
                frame_valid_latched <= 1'b0;
            end

            else begin
                display_last_data    <= display_last_data;
                display_frame_length <= display_frame_length;
                frame_valid_latched  <= frame_valid_latched;
            end
        end
    end

    assign led[7:0]   = display_last_data;
    assign led[8]     = frame_valid_latched;
    assign led[9]     = line_receiving;
    assign led[10]    = line_overflow;
    assign led[11]    = line_discarding;
    assign led[12]    = overrun_error;
    assign led[15:13] = display_frame_length[2:0];

    // RX 전용 단계이므로 TX는 UART Idle 상태인 1로 고정
    assign RsTx = 1'b1;

endmodule
