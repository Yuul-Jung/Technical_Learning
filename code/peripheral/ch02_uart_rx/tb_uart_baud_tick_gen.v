`timescale 1ns / 1ps

module tb_uart_baud_tick_gen;

reg clk;
reg reset;
wire tick;

uart_baud_tick_gen #(
    // Simulation 시간을 줄이기 위한 검증용 값
    .CLKS_PER_SAMPLE(8)
) dut (
    .clk(clk),
    .reset(reset),
    .tick(tick)
);

always #5 clk = ~clk;

initial begin
    clk = 1'b0;
    reset = 1'b1;
    #20;

    reset = 1'b0;
    #500;

    $finish;
end

endmodule
