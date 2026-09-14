`timescale 1ns / 1ps

module tb_dp_blink_1hz;

reg clk;
reg reset;
reg enable;
wire dp_state;

dp_blink_1hz dut(
    .clk(clk),
    .reset(reset),
    .enable(enable),
    .dp_state(dp_state)
);

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

initial begin
    reset = 1'b1;
    enable = 1'b0;
    #100;

    reset = 1'b0;
    enable = 1'b1;

    #2_100_000_000;

    enable = 1'b0;
    #100;

    $finish;
end

endmodule
