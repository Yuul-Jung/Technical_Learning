`timescale 1ns / 1ps

// tb_basys3_uart_led_pwm_cds_fnd_top.v
//
// Source verification flow:
// 1. Reset
// 2. CTRL = 0x02 : CdS only ON
// 3. CdS light/dark
// 4. PWM_VALUE = 0x80
// 5. CTRL = 0x03 : LED PWM + CdS ON
// 6. CTRL = 0x00 : all OFF
//
// RsRx에 실제 UART 8N1 serial waveform을 넣는다.

module tb_basys3_uart_led_pwm_cds_fnd_top;

    parameter CLK_FREQ      = 100_000_000;
    parameter BAUD_RATE     = 1_000_000;
    parameter CLK_PERIOD_NS = 10;
    parameter BIT_PERIOD_NS = 1_000_000_000 / BAUD_RATE;

    reg clk;
    reg btnU;
    reg RsRx;
    reg [0:0] JA;

    wire RsTx;
    wire [15:0] led;
    wire [6:0] seg;
    wire [3:0] an;
    wire dp;

    basys3_uart_led_pwm_cds_fnd_top #(
        .CLK_FREQ     (CLK_FREQ),
        .BAUD_RATE    (BAUD_RATE),
        .PWM_PRESCALE (4)
    ) dut (
        .clk  (clk),
        .btnU (btnU),
        .RsRx (RsRx),
        .JA   (JA),

        .RsTx (RsTx),
        .led  (led),
        .seg  (seg),
        .an   (an),
        .dp   (dp)
    );

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD_NS/2) clk = ~clk;
    end

    task uart_send_byte;
        input [7:0] data;
        integer i;
        begin
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
            #(BIT_PERIOD_NS * 3);
        end
    endtask

    initial begin
        btnU = 1'b1;
        RsRx = 1'b1;
        JA[0] = 1'b0;

        #(CLK_PERIOD_NS * 10);
        btnU = 1'b0;
        #(BIT_PERIOD_NS * 5);

        // 1. CTRL = 0x02: CdS only
        uart_send_write_packet(8'h00, 8'h02);

        if (dut.ctrl_reg !== 8'h02) begin
            $display("ERROR: CTRL 0x02 failed");
            $finish;
        end

        // 2. Bright
        JA[0] = 1'b1;
        #(CLK_PERIOD_NS * 5);

        if (dut.cds_is_light !== 1'b1 ||
            dut.fnd_status_code !== 4'hA) begin
            $display("ERROR: CdS light/L failed");
            $finish;
        end

        // 3. Dark
        JA[0] = 1'b0;
        #(CLK_PERIOD_NS * 5);

        if (dut.cds_is_light !== 1'b0 ||
            dut.fnd_status_code !== 4'hB) begin
            $display("ERROR: CdS dark/d failed");
            $finish;
        end

        // 4. PWM = 0x80
        uart_send_write_packet(8'h01, 8'h80);

        if (dut.pwm_value_reg !== 8'h80) begin
            $display("ERROR: PWM_VALUE 0x80 failed");
            $finish;
        end

        // 5. CTRL = 0x03: PWM + CdS
        uart_send_write_packet(8'h00, 8'h03);

        if (dut.ctrl_reg !== 8'h03) begin
            $display("ERROR: CTRL 0x03 failed");
            $finish;
        end

        // 6. All OFF
        uart_send_write_packet(8'h00, 8'h00);

        if (dut.ctrl_reg !== 8'h00) begin
            $display("ERROR: CTRL 0x00 failed");
            $finish;
        end

        $display("PASS: UART + CdS + FND control flow");
        $finish;
    end

endmodule
