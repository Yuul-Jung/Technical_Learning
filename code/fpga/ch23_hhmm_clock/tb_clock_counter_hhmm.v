`timescale 1ns / 1ps

module tb_clock_counter_hhmm;

reg clk;
reg reset;
reg tick_1min;
wire [3:0] min_ones;
wire [3:0] min_tens;
wire [3:0] hour_ones;
wire [3:0] hour_tens;

clock_counter_hhmm dut(
    .clk(clk),
    .reset(reset),
    .tick_1min(tick_1min),
    .min_ones(min_ones),
    .min_tens(min_tens),
    .hour_ones(hour_ones),
    .hour_tens(hour_tens)
);

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

task make_tick_1min;
begin
    tick_1min = 1'b1;
    #10;
    tick_1min = 1'b0;
    #20;
end
endtask

initial begin
    reset = 1'b1;
    tick_1min = 1'b0;
    #20;

    reset = 1'b0;

    repeat (1445) begin
        make_tick_1min;
    end

    $finish;
end

endmodule
