`timescale 1ns / 1ps

module mealy_serial_frame_fsm(
    input  wire       clk,
    input  wire       reset,
    input  wire       w,
    output reg  [1:0] y,

    // 시뮬레이션 확인용 출력
    output wire [2:0] state_dbg,
    output wire [2:0] next_state_dbg
);

    // 상태 정의
    localparam S0 = 3'd0;   // 수신 대기 상태
    localparam S1 = 3'd1;   // 첫 번째 1 수신
    localparam S2 = 3'd2;   // 정상 프레임 완료 직전
    localparam S3 = 3'd3;   // 10까지 수신
    localparam S4 = 3'd4;   // 오류 프레임 확인 후 복귀 직전

    reg [2:0] current_state;
    reg [2:0] next_state;

    assign state_dbg      = current_state;
    assign next_state_dbg = next_state;

    // State Register
    always @(posedge clk) begin
        if (reset)
            current_state <= S0;
        else
            current_state <= next_state;
    end

    // Next State Logic + Mealy Output Logic
    // Mealy 출력 y는 현재 상태 PS와 입력 w를 함께 보고 결정된다.
    always @(*) begin
        next_state = current_state;
        y = 2'b00;

        case (current_state)

            S0: begin
                if (w == 1'b0) begin
                    // 유효 프레임 시작 아님
                    next_state = S0;
                    y = 2'b00;
                end
                else begin
                    // 첫 번째 1 수신
                    next_state = S1;
                    y = 2'b10;
                end
            end

            S1: begin
                if (w == 1'b1) begin
                    // 11 정상 프레임 확인
                    next_state = S2;
                    y = 2'b10;
                end
                else begin
                    // 10까지 수신
                    next_state = S3;
                    y = 2'b00;
                end
            end

            S2: begin
                // 정상 완료 후 대기 복귀
                next_state = S0;
                y = 2'b11;
            end

            S3: begin
                if (w == 1'b1) begin
                    // 101 정상 프레임 확인
                    next_state = S2;
                    y = 2'b01;
                end
                else begin
                    // 100 오류 프레임 확인
                    next_state = S4;
                    y = 2'b00;
                end
            end

            S4: begin
                // 오류 처리 후 대기 복귀
                next_state = S0;
                y = 2'b01;
            end

            default: begin
                next_state = S0;
                y = 2'b00;
            end

        endcase
    end

endmodule
