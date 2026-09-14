`timescale 1ns / 1ps

// tb_xadc_volume_level_controller.v
//
// XADC Raw 값의 0~9 구간 변환만 독립 검증한다.
// 실제 xadc_wiz_0 IP는 이 Testbench에 필요하지 않는다.

module tb_xadc_volume_level_controller;

    reg  [11:0] xadc_raw;
    wire [3:0]  volume_digit;

    integer error_count;

    xadc_volume_level_controller dut (
        .xadc_raw     (xadc_raw),
        .volume_digit (volume_digit)
    );

    task check_level;
        input [11:0] raw_value;
        input [3:0]  expected_digit;
        begin
            xadc_raw = raw_value;
            #1;

            if (volume_digit !== expected_digit) begin
                $display(
                    "FAIL: raw=%0d expected=%0d actual=%0d",
                    raw_value,
                    expected_digit,
                    volume_digit
                );
                error_count = error_count + 1;
            end
            else begin
                $display(
                    "PASS: raw=%0d digit=%0d",
                    raw_value,
                    volume_digit
                );
            end
        end
    endtask

    initial begin
        error_count = 0;
        xadc_raw = 12'd0;

        check_level(12'd0,    4'd0);
        check_level(12'd409,  4'd0);
        check_level(12'd410,  4'd1);
        check_level(12'd819,  4'd1);
        check_level(12'd820,  4'd2);
        check_level(12'd2048, 4'd5);
        check_level(12'd2866, 4'd6);
        check_level(12'd2867, 4'd7);
        check_level(12'd3686, 4'd9);
        check_level(12'd4095, 4'd9);

        if (error_count == 0) begin
            $display(
                "ALL TESTS PASSED: tb_xadc_volume_level_controller"
            );
        end
        else begin
            $display(
                "TEST FAILED: error_count=%0d",
                error_count
            );
        end

        $finish;
    end

endmodule
