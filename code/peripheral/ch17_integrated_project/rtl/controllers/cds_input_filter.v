`timescale 1ns / 1ps

// cds_input_filter.v
//
// 외부 CdS 디지털 출력은 FPGA Clock과 비동기이므로
// 2-FF Synchronizer를 거쳐 내부 동기 신호로 사용한다.
//
// 외부 회로 기준:
//   밝음 / 낮   -> 1
//   어두움 / 밤 -> 0
//
// FPGA 내부에서 입력 반전은 수행하지 않는다.

module cds_input_filter(
    input  wire clk,
    input  wire reset,

    input  wire cds_sw_raw,

    output wire cds_sw_sync,
    output wire cds_is_light
);

    reg cds_meta;
    reg cds_sync_reg;

    always @(posedge clk) begin
        if (reset) begin
            cds_meta     <= 1'b0;
            cds_sync_reg <= 1'b0;
        end
        else begin
            cds_meta     <= cds_sw_raw;
            cds_sync_reg <= cds_meta;
        end
    end

    assign cds_sw_sync  = cds_sync_reg;
    assign cds_is_light = cds_sync_reg;

endmodule
