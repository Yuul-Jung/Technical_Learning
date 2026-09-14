`timescale 1ns / 1ps
module basys3_uart_led_pwm_min_top #(
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD_RATE = 9600,
    parameter PWM_PRESCALE = 390
)(
    input wire clk, input wire btnU, input wire RsRx,
    output wire RsTx, output wire [15:0] led
);
    wire reset = btnU;
    wire [7:0] rx_stream_data;
    wire rx_stream_valid, rx_stream_ready;
    wire rx_empty, rx_full, frame_error, overrun_error;
    wire tx_full, tx_empty, tx_busy, tx_done;
    wire [4:0] tx_count;
    wire reg_wr_en, cmd_error, reg_error;
    wire [7:0] reg_wr_addr, reg_wr_data, ctrl_reg, pwm_value_reg, last_cmd;
    wire [1:0] byte_index;

    uart_core #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) u_uart_core (
        .clk(clk), .reset(reset), .rx_serial(RsRx), .tx_serial(RsTx),
        .rx_data(rx_stream_data), .rx_valid(rx_stream_valid), .rx_ready(rx_stream_ready),
        .rx_empty(rx_empty), .rx_full(rx_full), .rx_fifo_clear(1'b0),
        .frame_error(frame_error), .overrun_error(overrun_error),
        .tx_wr_en(1'b0), .tx_wr_data(8'h00),
        .tx_full(tx_full), .tx_empty(tx_empty), .tx_count(tx_count),
        .tx_busy(tx_busy), .tx_done(tx_done)
    );

    uart_reg_write_controller #(.CMD_WRITE(8'h01)) u_uart_reg_write_controller (
        .clk(clk), .reset(reset),
        .in_data(rx_stream_data), .in_valid(rx_stream_valid), .in_ready(rx_stream_ready),
        .reg_wr_en(reg_wr_en), .reg_wr_addr(reg_wr_addr), .reg_wr_data(reg_wr_data),
        .byte_index(byte_index), .last_cmd(last_cmd), .cmd_error(cmd_error)
    );

    simple_register_map u_simple_register_map (
        .clk(clk), .reset(reset),
        .reg_wr_en(reg_wr_en), .reg_wr_addr(reg_wr_addr), .reg_wr_data(reg_wr_data),
        .ctrl_reg(ctrl_reg), .pwm_value_reg(pwm_value_reg), .reg_error(reg_error)
    );

    led_pwm_controller #(.PWM_PRESCALE(PWM_PRESCALE)) u_led_pwm_controller (
        .clk(clk), .reset(reset),
        .ctrl_reg(ctrl_reg), .pwm_value(pwm_value_reg), .led(led)
    );
endmodule
