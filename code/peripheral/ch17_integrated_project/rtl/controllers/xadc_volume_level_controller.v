`timescale 1ns / 1ps

// xadc_volume_level_controller.v
//
// XADC 12-bit Raw 값을 0~9 구간값으로 변환한다.
//
// xadc_raw 범위:
// 0~4095
//
// volume_digit 의미:
// 0V~0.1V   -> 0
// 0.1V~0.2V -> 1
// ...
// 0.9V~1.0V -> 9
//
// 타이밍을 안정시키기 위해 곱셈 없이 구간 비교 방식으로 작성한다.

module xadc_volume_level_controller (
    input  wire [11:0] xadc_raw,
    output reg  [3:0]  volume_digit
);

    always @(*) begin
        if (xadc_raw < 12'd410) begin
            volume_digit = 4'd0;
        end
        else if (xadc_raw < 12'd820) begin
            volume_digit = 4'd1;
        end
        else if (xadc_raw < 12'd1229) begin
            volume_digit = 4'd2;
        end
        else if (xadc_raw < 12'd1639) begin
            volume_digit = 4'd3;
        end
        else if (xadc_raw < 12'd2048) begin
            volume_digit = 4'd4;
        end
        else if (xadc_raw < 12'd2458) begin
            volume_digit = 4'd5;
        end
        else if (xadc_raw < 12'd2867) begin
            volume_digit = 4'd6;
        end
        else if (xadc_raw < 12'd3277) begin
            volume_digit = 4'd7;
        end
        else if (xadc_raw < 12'd3686) begin
            volume_digit = 4'd8;
        end
        else begin
            volume_digit = 4'd9;
        end
    end

endmodule
