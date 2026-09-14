`timescale 1ns / 1ps

module tb_bcd_2digit_counter;

reg clk;
reg reset;
reg enable;
reg tick;
wire [3:0] digit0;
wire [3:0] digit1;

bcd_2digit_counter dut(
    .clk(clk),
    .reset(reset),
    .enable(enable),
    .tick(tick),
    .digit0(digit0),
    .digit1(digit1)
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
    enable = 1'b0;
    tick = 1'b0;
    #20;

    reset = 1'b0;
    enable = 1'b1;

    repeat (105) begin
        make_tick;
    end

    enable = 1'b0;
    make_tick;
    make_tick;

    $finish;
end

endmodule
