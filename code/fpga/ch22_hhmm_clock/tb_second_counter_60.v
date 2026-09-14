`timescale 1ns / 1ps

module tb_second_counter_60;

reg clk;
reg reset;
reg tick_1s;
wire tick_1min;
wire [5:0] sec_count;

second_counter_60 dut(
    .clk(clk),
    .reset(reset),
    .tick_1s(tick_1s),
    .tick_1min(tick_1min),
    .sec_count(sec_count)
);

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

task make_tick_1s;
begin
    tick_1s = 1'b1;
    #10;
    tick_1s = 1'b0;
    #20;
end
endtask

initial begin
    reset = 1'b1;
    tick_1s = 1'b0;
    #20;

    reset = 1'b0;

    repeat (65) begin
        make_tick_1s;
    end

    $finish;
end

endmodule
