`timescale 1ns / 1ps

module tb_d_ff_reset;

reg clk;
reg rst;
reg d;
wire q;

d_ff_reset dut(
    .clk(clk),
    .rst(rst),
    .d(d),
    .q(q)
);

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;  // 10ns Clock
end

initial begin
    rst = 1'b1;
    d = 1'b0;
    #12;

    rst = 1'b0;
    #10;

    d = 1'b1; #10;
    d = 1'b0; #10;
    d = 1'b1; #10;

    rst = 1'b1;
    #10;

    rst = 1'b0;
    d = 1'b1;
    #10;

    $finish;
end

endmodule
