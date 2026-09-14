`timescale 1ns / 1ps

// tb_basys3_uart_led_pwm_cds_ultra_fnd_top.v
//
// 실제 HC-SR04 대신 us_echo Pulse를 Testbench에서 생성한다.
//
// 검증 흐름:
// 1. CTRL = 0x04 -> 초음파만 ON
// 2. Echo HIGH 5800us -> 약 100cm
// 3. CTRL = 0x06 -> CdS + 초음파 ON
// 4. CdS 밝음 / 어두움
// 5. CTRL = 0x00 -> 전체 OFF

module tb_basys3_uart_led_pwm_cds_ultra_fnd_top;

    parameter CLK_FREQ      = 100_000_000;
    parameter BAUD_RATE     = 1_000_000;
    parameter CLK_PERIOD_NS = 10;
    parameter BIT_PERIOD_NS =
        1_000_000_000 / BAUD_RATE;

    reg clk;
    reg btnU;
    reg RsRx;
    reg cds_in;
    reg us_echo;

    wire us_trig;
    wire RsTx;
    wire [15:0] led;
    wire [6:0] seg;
    wire [3:0] an;
    wire dp;

    basys3_uart_led_pwm_cds_ultra_fnd_top #(
        .CLK_FREQ  (CLK_FREQ),
        .BAUD_RATE (BAUD_RATE)
    ) dut (
        .clk     (clk),
        .btnU    (btnU),
        .RsRx    (RsRx),

        .cds_in  (cds_in),
        .us_echo (us_echo),
        .us_trig (us_trig),

        .RsTx    (RsTx),
        .led     (led),
        .seg     (seg),
        .an      (an),
        .dp      (dp)
    );

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD_NS / 2) clk = ~clk;
    end

    task uart_send_byte;
        input [7:0] data;
        integer i;
        begin
            RsRx = 1'b1;
            #(BIT_PERIOD_NS);

            RsRx = 1'b0;
            #(BIT_PERIOD_NS);

            for (i = 0; i < 8; i = i + 1) begin
                RsRx = data[i];
                #(BIT_PERIOD_NS);
            end

            RsRx = 1'b1;
            #(BIT_PERIOD_NS);
        end
    endtask

    task uart_send_write_packet;
        input [7:0] addr;
        input [7:0] data;
        begin
            uart_send_byte(8'h01);
            uart_send_byte(addr);
            uart_send_byte(data);
        end
    endtask

    task send_echo_after_trig;
        input integer echo_high_us;
        begin
            wait (us_trig == 1'b1);
            wait (us_trig == 1'b0);

            #(2_000);

            us_echo = 1'b1;
            #(echo_high_us * 1000);
            us_echo = 1'b0;
        end
    endtask

    task check_distance_range;
        input [9:0] min_cm;
        input [9:0] max_cm;
        begin
            if (dut.distance_cm < min_cm ||
                dut.distance_cm > max_cm) begin

                $display(
                    "ERROR: distance_cm=%0d",
                    dut.distance_cm
                );
                $finish;
            end
        end
    endtask

    initial begin
        RsRx    = 1'b1;
        cds_in  = 1'b0;
        us_echo = 1'b0;
        btnU    = 1'b1;

        #(CLK_PERIOD_NS * 20);
        btnU = 1'b0;

        #(BIT_PERIOD_NS * 5);

        // CTRL = 0x04 : Ultrasonic only
        uart_send_write_packet(8'h00, 8'h04);
        #(BIT_PERIOD_NS * 5);

        // Echo 5800us ~= 100cm
        send_echo_after_trig(5800);
        #(20_000);

        if (dut.distance_valid !== 1'b1) begin
            $display("ERROR: distance_valid=0");
            $finish;
        end

        check_distance_range(
            10'd95,
            10'd105
        );

        // CTRL = 0x06 : CdS + Ultrasonic
        uart_send_write_packet(8'h00, 8'h06);
        #(BIT_PERIOD_NS * 5);

        cds_in = 1'b1;
        #(CLK_PERIOD_NS * 5);

        cds_in = 1'b0;
        #(CLK_PERIOD_NS * 5);

        // All OFF
        uart_send_write_packet(8'h00, 8'h00);
        #(BIT_PERIOD_NS * 5);

        $display("PASS: ultrasonic integration flow");
        $finish;
    end

endmodule
