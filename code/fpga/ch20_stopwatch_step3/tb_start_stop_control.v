`timescale 1ns / 1ps

module tb_start_stop_control;

reg clk;
reg reset;
reg start;
reg stop;
wire running;

start_stop_control dut(
    .clk(clk),
    .reset(reset),
    .start(start),
    .stop(stop),
    .running(running)
);

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

initial begin
    reset = 1'b1;
    start = 1'b0;
    stop = 1'b0;
    #20;

    reset = 1'b0;

    start = 1'b1;
    #10;
    start = 1'b0;
    #100;

    stop = 1'b1;
    #10;
    stop = 1'b0;
    #100;

    start = 1'b1;
    #10;
    start = 1'b0;
    #50;

    reset = 1'b1;
    #20;

    $finish;
end

endmodule
