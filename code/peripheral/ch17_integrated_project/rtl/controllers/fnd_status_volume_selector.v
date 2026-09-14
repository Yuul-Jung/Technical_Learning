`timescale 1ns / 1ps

// fnd_status_volume_selector.v
//
// XADC Volume 추가 후 FND 최상위 자리의 표시 소스를 선택한다.
//
// 우선순위:
// 1. CdS
// 2. XADC Volume
// 3. 초음파 거리 상태(n / - / F)는 FND 모듈 내부에서 처리
//
// 이 모듈을 별도로 두는 이유:
// Top Module을 보드 Pin/모듈 연결 중심의 Shell로 유지하기 위함이다.

module fnd_status_volume_selector (
    input  wire        cds_en,
    input  wire        dist_en,
    input  wire        volume_mode_en,

    input  wire        cds_is_light,
    input  wire [3:0]  volume_digit,

    input  wire [11:0] distance_bcd,
    input  wire        distance_valid,

    output wire        volume_effective,
    output wire        status_valid,
    output wire [3:0]  status_code,
    output wire [11:0] value_bcd,
    output wire        value_valid
);

    localparam CHAR_L    = 4'hA;
    localparam CHAR_d    = 4'hB;
    localparam CHAR_DASH = 4'hC;

    assign volume_effective =
        volume_mode_en && !cds_en;

    assign status_valid =
        cds_en || volume_effective || dist_en;

    assign status_code =
        cds_en ?
        (cds_is_light ? CHAR_L : CHAR_d) :
        volume_effective ?
        volume_digit :
        CHAR_DASH;

    assign value_bcd =
        dist_en ? distance_bcd : 12'h000;

    assign value_valid =
        dist_en && distance_valid;

endmodule
