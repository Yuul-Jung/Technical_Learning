`timescale 1ns / 1ps

module tb_uart_rx_fsm;

reg clk;
reg reset;
reg tick;
reg rx_sync;

wire [7:0] rx_data;
wire rx_done;
wire frame_error;

uart_rx_fsm dut (
    .clk(clk),
    .reset(reset),
    .tick(tick),
    .rx_sync(rx_sync),
    .rx_data(rx_data),
    .rx_done(rx_done),
    .frame_error(frame_error)
);

always #5 clk = ~clk;

// 16x sample tick을 한 번 발생
task sample_tick;
begin
    tick = 1'b1; #10;
    tick = 1'b0; #10;
end
endtask

task wait_samples;
    input integer n;
    integer i;
begin
    for (i = 0; i < n; i = i + 1)
        sample_tick;
end
endtask

task send_uart_byte;
    input [7:0] data;
    integer b;
begin
    rx_sync = 1'b0;          // Start bit
    wait_samples(16);

    for (b = 0; b < 8; b = b + 1) begin
        rx_sync = data[b];    // LSB First
        wait_samples(16);
    end

    rx_sync = 1'b1;          // Stop bit
    wait_samples(16);
end
endtask

task send_uart_byte_with_frame_error;
    input [7:0] data;
    integer b;
begin
    rx_sync = 1'b0;
    wait_samples(16);

    for (b = 0; b < 8; b = b + 1) begin
        rx_sync = data[b];
        wait_samples(16);
    end

    rx_sync = 1'b0;          // 잘못된 Stop bit
    wait_samples(16);

    rx_sync = 1'b1;
end
endtask

initial begin
    clk = 1'b0;
    reset = 1'b1;
    tick = 1'b0;
    rx_sync = 1'b1;
    #20;

    reset = 1'b0;

    send_uart_byte(8'h41);                 // 'A'
    wait_samples(16);

    send_uart_byte_with_frame_error(8'h55);
    wait_samples(16);

    $finish;
end

endmodule
