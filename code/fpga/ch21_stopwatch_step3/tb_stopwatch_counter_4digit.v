`timescale 1ns / 1ps

module tb_stopwatch_counter_4digit;

reg clk;
reg reset;
reg tick;
wire [3:0] digit0;
wire [3:0] digit1;
wire [3:0] digit2;
wire [3:0] digit3;

stopwatch_counter_4digit dut(
    .clk(clk),
    .reset(reset),
    .enable(tick),
    .digit0(digit0),
    .digit1(digit1),
    .digit2(digit2),
    .digit3(digit3)
);

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

task make_tick;
begin
    tick = 1'b1;
    #10;
    tick = 1'b0;
    #20;
end
endtask

initial begin
    reset = 1'b1;
    tick = 1'b0;
    #20;

    reset = 1'b0;

    repeat (120) begin
        make_tick;
    end

    $finish;
end

endmodule
