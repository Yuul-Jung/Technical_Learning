`timescale 1ns / 1ps

// uart_response_generator.v
// Command Parser가 선택한 응답 문자열을 표준 Byte Stream으로 출력하는 모듈임.
//
// 출력 인터페이스:
//   out_data / out_valid / out_ready
//
// out_valid=1 상태에서 out_ready=0이면 현재 Byte와 index를 유지함.
// 따라서 뒤쪽 TX FIFO가 Full이어도 응답 Byte를 잃지 않음.

module uart_response_generator (
    input  wire       clk,
    input  wire       reset,

    input  wire       response_req,
    input  wire [2:0] response_sel,
    input  wire       led0_state,

    output wire [7:0] out_data,
    output wire       out_valid,
    input  wire       out_ready,

    output wire       busy
);

    localparam RESP_NONE       = 3'd0;
    localparam RESP_OK_LED_ON  = 3'd1;
    localparam RESP_OK_LED_OFF = 3'd2;
    localparam RESP_STATUS     = 3'd3;
    localparam RESP_ERR_CMD    = 3'd4;

    reg        busy_reg;
    reg [2:0]  active_sel;
    reg [4:0]  index;
    reg        led_state_latched;

    reg [4:0]  resp_len;
    reg [7:0]  resp_byte;

    always @(*) begin
        case (active_sel)
            RESP_OK_LED_ON:  resp_len = 5'd10; // "OK LED ON\n"
            RESP_OK_LED_OFF: resp_len = 5'd11; // "OK LED OFF\n"
            RESP_STATUS:     resp_len = led_state_latched ? 5'd7 : 5'd8;
            RESP_ERR_CMD:    resp_len = 5'd8;  // "ERR CMD\n"
            default:         resp_len = 5'd0;
        endcase
    end

    always @(*) begin
        resp_byte = 8'h00;

        case (active_sel)

            RESP_OK_LED_ON: begin
                case (index)
                    0: resp_byte = "O";
                    1: resp_byte = "K";
                    2: resp_byte = " ";
                    3: resp_byte = "L";
                    4: resp_byte = "E";
                    5: resp_byte = "D";
                    6: resp_byte = " ";
                    7: resp_byte = "O";
                    8: resp_byte = "N";
                    9: resp_byte = 8'h0A;
                    default: resp_byte = 8'h00;
                endcase
            end

            RESP_OK_LED_OFF: begin
                case (index)
                    0:  resp_byte = "O";
                    1:  resp_byte = "K";
                    2:  resp_byte = " ";
                    3:  resp_byte = "L";
                    4:  resp_byte = "E";
                    5:  resp_byte = "D";
                    6:  resp_byte = " ";
                    7:  resp_byte = "O";
                    8:  resp_byte = "F";
                    9:  resp_byte = "F";
                    10: resp_byte = 8'h0A;
                    default: resp_byte = 8'h00;
                endcase
            end

            RESP_STATUS: begin
                if (led_state_latched) begin
                    case (index)
                        0: resp_byte = "L";
                        1: resp_byte = "E";
                        2: resp_byte = "D";
                        3: resp_byte = "=";
                        4: resp_byte = "O";
                        5: resp_byte = "N";
                        6: resp_byte = 8'h0A;
                        default: resp_byte = 8'h00;
                    endcase
                end
                else begin
                    case (index)
                        0: resp_byte = "L";
                        1: resp_byte = "E";
                        2: resp_byte = "D";
                        3: resp_byte = "=";
                        4: resp_byte = "O";
                        5: resp_byte = "F";
                        6: resp_byte = "F";
                        7: resp_byte = 8'h0A;
                        default: resp_byte = 8'h00;
                    endcase
                end
            end

            RESP_ERR_CMD: begin
                case (index)
                    0: resp_byte = "E";
                    1: resp_byte = "R";
                    2: resp_byte = "R";
                    3: resp_byte = " ";
                    4: resp_byte = "C";
                    5: resp_byte = "M";
                    6: resp_byte = "D";
                    7: resp_byte = 8'h0A;
                    default: resp_byte = 8'h00;
                endcase
            end

            default: begin
                resp_byte = 8'h00;
            end
        endcase
    end

    always @(posedge clk) begin
        if (reset) begin
            busy_reg           <= 1'b0;
            active_sel         <= RESP_NONE;
            index              <= 5'd0;
            led_state_latched  <= 1'b0;
        end
        else begin

            // 새 응답 요청은 현재 응답이 없을 때만 수락.
            if (response_req && !busy_reg) begin
                busy_reg          <= 1'b1;
                active_sel        <= response_sel;
                index             <= 5'd0;
                led_state_latched <= led0_state;
            end

            // valid/ready Handshake가 성립할 때만 다음 Byte로 이동.
            else if (busy_reg && out_ready) begin
                if (index == resp_len - 1'b1) begin
                    busy_reg   <= 1'b0;
                    active_sel <= RESP_NONE;
                    index      <= 5'd0;
                end
                else begin
                    index <= index + 1'b1;
                end
            end
        end
    end

    assign out_data  = resp_byte;
    assign out_valid = busy_reg;
    assign busy      = busy_reg;

endmodule
