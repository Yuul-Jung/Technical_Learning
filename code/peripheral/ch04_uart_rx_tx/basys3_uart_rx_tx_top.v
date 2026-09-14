`timescale 1ns / 1ps

// basys3_uart_rx_tx_top.v
// Basys3 보드용 RX + TX 결합 Top임.
// uart_core.v를 사용하여 RX Core와 TX Core를 하나의 UART Core로 묶음.
// rx_bram_line_buffer.v는 uart_core 밖에 둠.
// button_debounce_pulse.v도 uart_core 밖에 둠.
// Echo는 아직 수행하지 않음.

module basys3_uart_rx_tx_top #(
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD_RATE = 9600
)(
    input  wire        clk,
    input  wire        btnC,
    input  wire        btnU,
    input  wire        RsRx,
    output wire        RsTx,
    output wire [15:0] led
);

    wire reset;
    assign reset = btnU;

    // ------------------------------------------------------------
    // RX Core / Line Buffer 연결 신호
    // ------------------------------------------------------------
    wire [7:0] rx_data;
    wire       rx_valid;
    wire       rx_ready;
    wire       rx_empty;
    wire       rx_full;
    wire       frame_error;
    wire       overrun_error;

    wire [7:0] line_last_data;
    wire       line_frame_valid;
    wire [6:0] line_frame_length;
    wire       line_receiving;
    wire       line_overflow;
    wire       line_discarding;

    // LED 표시 시간을 만들기 위한 분주 Counter
    reg [25:0] display_div;

    // LED0~LED7에 표시할 마지막 수신 문자
    reg [7:0] display_last_data;

    // frame_valid는 1클럭 Pulse이므로 LED 확인용 Latch
    reg frame_valid_latched;

    // ------------------------------------------------------------
    // TX 버튼 / FIFO 연결 신호
    // ------------------------------------------------------------
    wire btn_pulse;

    reg        tx_wr_en;
    reg [7:0]  tx_wr_data;
    reg [7:0]  ascii_reg;

    wire       tx_full;
    wire       tx_empty;
    wire [4:0] tx_count;
    wire       tx_busy;
    wire       tx_done;

    // ------------------------------------------------------------
    // UART RX + TX Core
    // ------------------------------------------------------------
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

    // ------------------------------------------------------------
    // RX BRAM Line Buffer
    // LF를 기준으로 문자열 Frame을 구분함.
    // 현재 단계에서는 RX 데이터를 TX로 되돌려 보내지 않음.
    // ------------------------------------------------------------
    rx_bram_line_buffer u_rx_bram_line_buffer (
        .clk          (clk),
        .reset        (reset),

        .rx_data      (rx_data),
        .rx_valid     (rx_valid),
        .rx_ready     (rx_ready),

        .last_data    (line_last_data),
        .frame_valid  (line_frame_valid),
        .frame_length (line_frame_length),
        .receiving    (line_receiving),
        .overflow     (line_overflow),
        .discarding   (line_discarding)
    );

    // ------------------------------------------------------------
    // TX 버튼 입력
    // ------------------------------------------------------------
    button_debounce_pulse u_button_debounce_pulse (
        .clk       (clk),
        .rst       (reset),
        .btn_in    (btnC),
        .btn_pulse (btn_pulse)
    );

    // ------------------------------------------------------------
    // RX Frame 완료 표시
    // ------------------------------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            display_div         <= 26'd0;
            display_last_data   <= 8'd0;
            frame_valid_latched <= 1'b0;
        end
        else begin
            display_div <= display_div + 1'b1;

            if (line_frame_valid) begin
                display_last_data   <= line_last_data;
                frame_valid_latched <= 1'b1;
                display_div         <= 26'd0;
            end
            else if (display_div[25]) begin
                frame_valid_latched <= 1'b0;
            end
            else begin
                display_last_data   <= display_last_data;
                frame_valid_latched <= frame_valid_latched;
            end
        end
    end

    // ------------------------------------------------------------
    // TX 문자 생성
    // btnC 1회: a, 2회: b, ... z 다음 다시 a
    // ------------------------------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            ascii_reg  <= 8'h61;
            tx_wr_en   <= 1'b0;
            tx_wr_data <= 8'd0;
        end
        else begin
            tx_wr_en <= 1'b0;

            if (btn_pulse && !tx_full) begin
                tx_wr_data <= ascii_reg;
                tx_wr_en   <= 1'b1;

                if (ascii_reg == 8'h7A)
                    ascii_reg <= 8'h61;
                else
                    ascii_reg <= ascii_reg + 1'b1;
            end
            else begin
                ascii_reg <= ascii_reg;
            end
        end
    end

    // ------------------------------------------------------------
    // LED 상태 표시
    // ------------------------------------------------------------
    assign led[7:0] = display_last_data;
    assign led[8]   = frame_valid_latched;
    assign led[9]   = line_receiving;
    assign led[10]  = line_overflow | line_discarding;
    assign led[11]  = tx_empty;
    assign led[12]  = tx_full;
    assign led[13]  = tx_busy;
    assign led[14]  = tx_done;
    assign led[15]  = frame_error | overrun_error;

endmodule
