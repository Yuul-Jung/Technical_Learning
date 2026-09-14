`timescale 1ns / 1ps

module tb_clock_divider_tick;

reg clk;
reg reset;
wire tick;

clock_divider_tick dut(
    .clk(clk),
    .reset(reset),
    .tick(tick)
);

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;      // 10ns 주기 Clock
end

initial begin
    reset = 1'b1;
    #20;

    reset = 1'b0;
    #200;

    $finish;
end

endmodule
