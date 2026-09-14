`timescale 1ns / 1ps

module tb_d_ff;

reg clk;
reg d;
wire q;

d_ff dut(
    .clk(clk),
    .d(d),
    .q(q)
);

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;  // 10ns Clock
end

initial begin
    d = 1'b0;
    #7;

    d = 1'b1; #3;
    d = 1'b0; #4;
    d = 1'b1; #6;

    d = 1'b0; #10;
    d = 1'b1; #10;
    d = 1'b0; #10;

    $finish;
end

endmodule
