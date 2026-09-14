`timescale 1ns / 1ps

// cds_status_encoder.v
//
// 원본 자료에서 Top에 있던
//   cds_is_light ? 4'hA : 4'hB
// 상태 문자 선택을 별도 조합 모듈로 분리한다.
//
// 4'hA -> FND 문자 L
// 4'hB -> FND 문자 d

module cds_status_encoder(
    input  wire       cds_is_light,
    output wire [3:0] status_code
);

    assign status_code = cds_is_light ? 4'hA : 4'hB;

endmodule
