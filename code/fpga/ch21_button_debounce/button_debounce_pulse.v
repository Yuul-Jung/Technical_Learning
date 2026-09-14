`timescale 1ns / 1ps

module button_debounce_pulse #(
    parameter CLK_HZ      = 100_000_000,  // Basys3 기본 클럭 100MHz
    parameter DEBOUNCE_MS = 20            // 버튼 입력 안정 확인 시간 20ms
)(
    input  wire clk,        // 시스템 클럭
    input  wire reset,      // 동기 리셋
    input  wire btn_in,     // 버튼 원시 입력
    output wire pulse_out   // 버튼 1회 입력 시 1클럭 펄스 출력
);

    localparam integer DEBOUNCE_COUNT = (CLK_HZ / 1000) * DEBOUNCE_MS;

    reg btn_sync_0;         // 1단 동기화 플립플롭
    reg btn_sync_1;         // 2단 동기화 플립플롭

    reg btn_stable;         // 디바운싱 후 안정된 버튼 상태
    reg btn_stable_d;       // 이전 클럭의 안정된 버튼 상태

    reg [31:0] count;       // 버튼 상태가 바뀐 뒤 안정 시간 측정용 카운터

    // ------------------------------------------------------------
    // 1단계: 비동기 버튼 입력을 FPGA 내부 클럭에 동기화
    // ------------------------------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            btn_sync_0 <= 1'b0;
            btn_sync_1 <= 1'b0;
        end
        else begin
            btn_sync_0 <= btn_in;
            btn_sync_1 <= btn_sync_0;
        end
    end

    // ------------------------------------------------------------
    // 2단계: 디바운싱 처리
    // 버튼 상태가 DEBOUNCE_MS 동안 계속 유지될 때만 안정 상태로 인정
    // ------------------------------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            btn_stable <= 1'b0;
            count      <= 32'd0;
        end
        else begin
            if (btn_sync_1 == btn_stable) begin
                count <= 32'd0;
            end
            else begin
                if (count >= DEBOUNCE_COUNT - 1) begin
                    btn_stable <= btn_sync_1;
                    count      <= 32'd0;
                end
                else begin
                    count <= count + 1'b1;
                end
            end
        end
    end

    // ------------------------------------------------------------
    // 3단계: 이전 안정 상태 저장
    // 상승 에지 검출을 위해 직전 클럭의 btn_stable 값을 기억
    // ------------------------------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            btn_stable_d <= 1'b0;
        end
        else begin
            btn_stable_d <= btn_stable;
        end
    end

    // ------------------------------------------------------------
    // 4단계: 상승 에지 검출
    // btn_stable이 0에서 1로 바뀌는 순간에만 1클럭 펄스 출력
    // ------------------------------------------------------------
    assign pulse_out = btn_stable & ~btn_stable_d;

endmodule
