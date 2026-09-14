`timescale 1ns / 1ps

module tb_compare_latch_ff;

reg en;
reg clk;
reg d;
wire q_latch;
wire q_ff;

compare_latch_ff dut(
    .en(en),
    .clk(clk),
    .d(d),
    .q_latch(q_latch),
    .q_ff(q_ff)
);

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;  // 10ns Clock
end

initial begin
    en = 1'b0;
    d = 1'b0;
    #10;

    en = 1'b1;
    d = 1'b1; #3;
    d = 1'b0; #4;
    d = 1'b1; #6;
    d = 1'b0; #7;

    en = 1'b0;
    d = 1'b1; #10;
    d = 1'b0; #10;
    d = 1'b1; #10;

    $finish;
end

endmodule
