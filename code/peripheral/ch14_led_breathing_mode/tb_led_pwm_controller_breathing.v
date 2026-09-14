`timescale 1ns / 1ps

// tb_led_pwm_controller_breathing.v
// ------------------------------------------------------------
// LED 숨쉬기 모드 하위 모듈 단독 테스트벤치이다.
// DUT는 led_pwm_controller.v이다.
//
// 시뮬레이션 시간을 줄이기 위해
// PWM_PRESCALE과 BREATH_PRESCALE을 작게 설정한다.
// ------------------------------------------------------------

module tb_led_pwm_controller_breathing;

    reg clk;
    reg reset;
    reg [7:0] ctrl_reg;
    reg [7:0] pwm_value;

    wire [15:0] led;

    reg [15:0] last_led;
    integer change_count;
    integer nonzero_count;

    led_pwm_controller #(
        .PWM_PRESCALE(4),
        .BREATH_PRESCALE(4)
    ) dut (
        .clk       (clk),
        .reset     (reset),
        .ctrl_reg  (ctrl_reg),
        .pwm_value (pwm_value),
        .led       (led)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    always @(posedge clk) begin
        if (reset) begin
            last_led      <= 16'h0000;
            change_count  <= 0;
            nonzero_count <= 0;
        end
        else begin
            if (led != last_led) begin
                change_count <= change_count + 1;
                last_led     <= led;
            end

            if (led != 16'h0000) begin
                nonzero_count <= nonzero_count + 1;
            end
        end
    end

    initial begin
        reset         = 1'b1;
        ctrl_reg      = 8'h00;
        pwm_value     = 8'h00;
        last_led      = 16'h0000;
        change_count  = 0;
        nonzero_count = 0;

        repeat (10) @(posedge clk);

        reset    = 1'b0;
        ctrl_reg = 8'h01;

        // 일반 LED Bar 모드 확인이다.
        pwm_value = 8'h80;
        repeat (300) @(posedge clk);

        // 숨쉬기 모드 확인이다.
        pwm_value = 8'hFE;
        repeat (3000) @(posedge clk);

        if (change_count < 5) begin
            $display(
                "FAIL: LED output did not change enough. change_count=%0d",
                change_count
            );
        end
        else if (nonzero_count < 5) begin
            $display(
                "FAIL: LED output was rarely nonzero. nonzero_count=%0d",
                nonzero_count
            );
        end
        else begin
            $display(
                "PASS: LED breathing mode produced changing LED patterns."
            );
            $display(
                "change_count=%0d nonzero_count=%0d",
                change_count,
                nonzero_count
            );
        end

        $finish;
    end

endmodule
