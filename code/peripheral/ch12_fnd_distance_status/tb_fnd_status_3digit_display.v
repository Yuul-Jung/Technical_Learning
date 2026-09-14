`timescale 1ns / 1ps

module tb_fnd_status_3digit_display;

    reg clk;
    reg reset;

    reg        status_valid;
    reg [3:0]  status_code;
    reg [11:0] value_bcd;
    reg        value_valid;

    wire [6:0] seg;
    wire [3:0] an;
    wire       dp;

    integer error_count;
    integer guard_count;

    localparam CHAR_L    = 4'hA;
    localparam CHAR_d    = 4'hB;
    localparam CHAR_DASH = 4'hC;

    localparam SEG_L     = 7'b1000111;
    localparam SEG_d     = 7'b0100001;
    localparam SEG_DASH  = 7'b0111111;
    localparam SEG_n     = 7'b0101011;
    localparam SEG_F     = 7'b0001110;

    fnd_status_3digit_display #(
        .CLK_FREQ_HZ(1000),
        .SCAN_HZ(100)
    ) dut (
        .clk          (clk),
        .reset        (reset),
        .status_valid (status_valid),
        .status_code  (status_code),
        .value_bcd    (value_bcd),
        .value_valid  (value_valid),
        .seg          (seg),
        .an           (an),
        .dp           (dp)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task wait_status_digit;
        begin
            guard_count = 0;

            while ((an != 4'b0111) &&
                   (guard_count < 1000)) begin
                @(posedge clk);
                guard_count = guard_count + 1;
            end

            #1;
        end
    endtask

    task check_status_seg;
        input [3:0]  in_status_code;
        input [11:0] in_value_bcd;
        input        in_value_valid;
        input [6:0]  expected_seg;

        begin
            status_valid = 1'b1;
            status_code  = in_status_code;
            value_bcd    = in_value_bcd;
            value_valid  = in_value_valid;

            wait_status_digit();

            if (seg !== expected_seg) begin
                $display(
                    "FAIL: status_code=%h value_bcd=%h expected_seg=%b actual_seg=%b",
                    in_status_code,
                    in_value_bcd,
                    expected_seg,
                    seg
                );
                error_count = error_count + 1;
            end
            else begin
                $display(
                    "PASS: status_code=%h value_bcd=%h seg=%b",
                    in_status_code,
                    in_value_bcd,
                    seg
                );
            end
        end
    endtask

    initial begin
        error_count = 0;

        status_valid = 1'b0;
        status_code  = CHAR_DASH;
        value_bcd    = 12'h000;
        value_valid  = 1'b0;

        reset = 1'b1;
        repeat (5) @(posedge clk);

        reset = 1'b0;
        repeat (5) @(posedge clk);

        // 23cm -> n023
        check_status_seg(
            CHAR_DASH,
            12'h023,
            1'b1,
            SEG_n
        );

        // 50cm -> -050
        check_status_seg(
            CHAR_DASH,
            12'h050,
            1'b1,
            SEG_DASH
        );

        // 120cm -> F120
        check_status_seg(
            CHAR_DASH,
            12'h120,
            1'b1,
            SEG_F
        );

        // CdS 밝음 L 우선
        check_status_seg(
            CHAR_L,
            12'h023,
            1'b1,
            SEG_L
        );

        // CdS 어두움 d 우선
        check_status_seg(
            CHAR_d,
            12'h120,
            1'b1,
            SEG_d
        );

        if (error_count == 0) begin
            $display(
                "ALL TESTS PASSED: tb_fnd_status_3digit_display"
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
