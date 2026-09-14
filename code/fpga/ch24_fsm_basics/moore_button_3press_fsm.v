`timescale 1ns / 1ps

module moore_button_3press_fsm(
    input  wire       clk,
    input  wire       reset,
    input  wire       x,
    output reg        z,

    // 시뮬레이션 확인용 출력
    output wire [1:0] state_dbg,
    output wire [1:0] next_state_dbg
);

    // 상태 정의
    localparam S0 = 2'd0;   // 버튼 0회 입력
    localparam S1 = 2'd1;   // 버튼 1회 입력
    localparam S2 = 2'd2;   // 버튼 2회 입력
    localparam S3 = 2'd3;   // 버튼 3회 입력 완료

    reg [1:0] current_state;
    reg [1:0] next_state;

    assign state_dbg      = current_state;
    assign next_state_dbg = next_state;

    // State Register
    // 클럭 상승 에지에서 NS가 PS로 저장된다.
    always @(posedge clk) begin
        if (reset) begin
            current_state <= S0;
        end
        else begin
            current_state <= next_state;
        end
    end

    // Next State Logic
    // 현재 상태 PS와 입력 x를 보고 다음 상태 NS를 결정한다.
    always @(*) begin
        next_state = current_state;

        case (current_state)
            S0: begin
                if (x == 1'b1)
                    next_state = S1;
                else
                    next_state = S0;
            end

            S1: begin
                if (x == 1'b1)
                    next_state = S2;
                else
                    next_state = S1;
            end

            S2: begin
                if (x == 1'b1)
                    next_state = S3;
                else
                    next_state = S2;
            end

            S3: begin
                // 출력 후 초기 상태 복귀
                next_state = S0;
            end

            default: begin
                next_state = S0;
            end
        endcase
    end

    // Moore Output Logic
    // 출력 z는 현재 상태 PS만 보고 결정된다.
    always @(*) begin
        case (current_state)
            S0: z = 1'b0;
            S1: z = 1'b0;
            S2: z = 1'b0;
            S3: z = 1'b1;
            default: z = 1'b0;
        endcase
    end

endmodule
