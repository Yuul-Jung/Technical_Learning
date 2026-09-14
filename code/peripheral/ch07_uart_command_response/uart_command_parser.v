`timescale 1ns / 1ps

// uart_command_parser.v
// LF로 완성된 UART Command Frame을 해석하는 재사용 Controller임.
//
// 지원 명령:
//   LED=ON
//   LED=OFF
//   STATUS?
//
// 원본 참고자료의 명령표는 미지원 명령에 "ERR CMD\n" 응답을 정의하지만,
// 예시 코드에서는 기타 명령을 RESP_STATUS로 연결하는 불일치가 있음.
// (변경) 본 구현은 명령표 기준으로 RESP_ERR_CMD를 별도 추가함.

module uart_command_parser #(
    parameter MAX_LEN = 16
)(
    input  wire                  clk,
    input  wire                  reset,

    input  wire                  frame_valid,
    input  wire [7:0]            frame_len,
    input  wire [8*MAX_LEN-1:0]  frame_data,

    output reg                   led0_state,
    output reg                   response_req,
    output reg  [2:0]            response_sel
);

    localparam RESP_NONE       = 3'd0;
    localparam RESP_OK_LED_ON  = 3'd1;
    localparam RESP_OK_LED_OFF = 3'd2;
    localparam RESP_STATUS     = 3'd3;
    localparam RESP_ERR_CMD    = 3'd4;

    wire [7:0] c0 = frame_data[7:0];
    wire [7:0] c1 = frame_data[15:8];
    wire [7:0] c2 = frame_data[23:16];
    wire [7:0] c3 = frame_data[31:24];
    wire [7:0] c4 = frame_data[39:32];
    wire [7:0] c5 = frame_data[47:40];
    wire [7:0] c6 = frame_data[55:48];

    wire cmd_led_on;
    wire cmd_led_off;
    wire cmd_status;

    assign cmd_led_on =
        (frame_len == 8'd6) &&
        (c0 == "L") && (c1 == "E") && (c2 == "D") &&
        (c3 == "=") && (c4 == "O") && (c5 == "N");

    assign cmd_led_off =
        (frame_len == 8'd7) &&
        (c0 == "L") && (c1 == "E") && (c2 == "D") &&
        (c3 == "=") && (c4 == "O") &&
        (c5 == "F") && (c6 == "F");

    assign cmd_status =
        (frame_len == 8'd7) &&
        (c0 == "S") && (c1 == "T") && (c2 == "A") &&
        (c3 == "T") && (c4 == "U") &&
        (c5 == "S") && (c6 == "?");

    always @(posedge clk) begin
        if (reset) begin
            led0_state  <= 1'b0;
            response_req <= 1'b0;
            response_sel <= RESP_NONE;
        end
        else begin
            response_req <= 1'b0;

            if (frame_valid) begin
                if (cmd_led_on) begin
                    led0_state   <= 1'b1;
                    response_sel <= RESP_OK_LED_ON;
                    response_req <= 1'b1;
                end
                else if (cmd_led_off) begin
                    led0_state   <= 1'b0;
                    response_sel <= RESP_OK_LED_OFF;
                    response_req <= 1'b1;
                end
                else if (cmd_status) begin
                    response_sel <= RESP_STATUS;
                    response_req <= 1'b1;
                end
                else begin
                    response_sel <= RESP_ERR_CMD;
                    response_req <= 1'b1;
                end
            end
        end
    end

endmodule
