`timescale 1ns / 1ps
module tb_basys3_uart_led_pwm_min_top;
    parameter CLK_FREQ = 100_000_000;
    parameter BAUD_RATE = 1_000_000;
    parameter CLK_PERIOD_NS = 10;
    parameter PWM_PRESCALE = 4;
    parameter UART_BIT_NS = 1_000_000_000 / BAUD_RATE;

    reg clk, btnU, RsRx;
    wire RsTx;
    wire [15:0] led;

    basys3_uart_led_pwm_min_top #(
        .CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE), .PWM_PRESCALE(PWM_PRESCALE)
    ) dut (
        .clk(clk), .btnU(btnU), .RsRx(RsRx), .RsTx(RsTx), .led(led)
    );

    initial begin clk = 1'b0; forever #(CLK_PERIOD_NS/2) clk = ~clk; end

    task send_uart_byte;
        input [7:0] data;
        integer i;
        begin
            RsRx = 1'b0; #(UART_BIT_NS);
            for (i=0; i<8; i=i+1) begin RsRx = data[i]; #(UART_BIT_NS); end
            RsRx = 1'b1; #(UART_BIT_NS);
        end
    endtask

    task send_packet;
        input [7:0] cmd, addr, data;
        begin
            send_uart_byte(cmd); send_uart_byte(addr); send_uart_byte(data);
            #(UART_BIT_NS*2);
        end
    endtask

    initial begin
        btnU = 1'b1; RsRx = 1'b1;
        #(CLK_PERIOD_NS*10); btnU = 1'b0;
        #(UART_BIT_NS*2);

        send_packet(8'h01,8'h00,8'h01);
        if (dut.ctrl_reg == 8'h01) $display("PASS: CTRL=01");
        else $display("FAIL: CTRL=%02h", dut.ctrl_reg);

        send_packet(8'h01,8'h01,8'h80);
        if (dut.pwm_value_reg == 8'h80) $display("PASS: PWM=80");
        else $display("FAIL: PWM=%02h", dut.pwm_value_reg);

        send_packet(8'h01,8'h00,8'h00);
        if (dut.ctrl_reg == 8'h00) $display("PASS: CTRL=00");
        else $display("FAIL: CTRL=%02h", dut.ctrl_reg);

        #(UART_BIT_NS*4);
        $finish;
    end
endmodule
