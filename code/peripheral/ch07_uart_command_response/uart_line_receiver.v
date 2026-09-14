`timescale 1ns / 1ps

// uart_line_receiver.v
// UART Byte Stream을 LF(0x0A) 기준 Line Frame으로 변환하는 재사용 모듈임.
//
// 입력 인터페이스:
//   in_data / in_valid / in_ready
//
// 출력:
//   frame_data / frame_len / frame_valid
//
// MAX_LEN을 초과한 Frame은 LF가 나올 때까지 버리고 overflow_error Pulse를 발생시킴.

module uart_line_receiver #(
    parameter MAX_LEN = 16
)(
    input  wire                   clk,
    input  wire                   reset,

    input  wire [7:0]             in_data,
    input  wire                   in_valid,
    output wire                   in_ready,

    output reg                    frame_valid,
    output reg  [7:0]             frame_len,
    output reg  [8*MAX_LEN-1:0]   frame_data,
    output reg                    overflow_error
);

    localparam LF = 8'h0A;

    reg [7:0] wr_index;
    reg       discarding;

    // 현재 모듈은 내부 처리 지연 없이 항상 1Byte를 받을 수 있음.
    assign in_ready = 1'b1;

    always @(posedge clk) begin
        if (reset) begin
            wr_index       <= 8'd0;
            discarding     <= 1'b0;
            frame_valid    <= 1'b0;
            frame_len      <= 8'd0;
            frame_data     <= {8*MAX_LEN{1'b0}};
            overflow_error <= 1'b0;
        end
        else begin
            // Event 출력은 1Clock Pulse
            frame_valid    <= 1'b0;
            overflow_error <= 1'b0;

            if (in_valid && in_ready) begin

                // Overflow 이후에는 LF까지 버림.
                if (discarding) begin
                    if (in_data == LF) begin
                        discarding <= 1'b0;
                        wr_index    <= 8'd0;
                    end
                end

                // 정상 수신 중 LF가 들어오면 Frame 완료.
                else if (in_data == LF) begin
                    frame_valid <= 1'b1;
                    frame_len   <= wr_index;
                    wr_index    <= 8'd0;
                end

                // LF가 아니면 Frame Data에 저장.
                else if (wr_index < MAX_LEN) begin
                    frame_data[8*wr_index +: 8] <= in_data;
                    wr_index <= wr_index + 1'b1;
                end

                // MAX_LEN 초과: 현재 Frame 폐기 시작.
                else begin
                    overflow_error <= 1'b1;
                    discarding     <= 1'b1;
                    wr_index        <= 8'd0;
                end
            end
        end
    end

endmodule
