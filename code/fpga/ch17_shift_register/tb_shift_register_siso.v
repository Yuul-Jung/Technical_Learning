`timescale 1ns / 1ps

module tb_shift_register_siso;

reg clk;
reg din;
wire serial_out;
wire [3:0] q;

shift_register_siso dut(
    .clk(clk),
    .din(din),
    .serial_out(serial_out),
    .q(q)
);

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;  // 10ns Clock
end

initial begin
    din = 1'b0;

    #10;
    din = 1'b1;

    #10;
    din = 1'b0;

    #10;
    din = 1'b1;

    #10;
    din = 1'b1;

    #20;

    $finish;
end

endmodule
