`timescale 1ns / 1ps

module tb_mealy_serial_frame_fsm;

reg clk;
reg reset;
reg w;

wire [1:0] y;
wire [2:0] state_dbg;
wire [2:0] next_state_dbg;

mealy_serial_frame_fsm dut (
    .clk(clk),
    .reset(reset),
    .w(w),
    .y(y),
    .state_dbg(state_dbg),
    .next_state_dbg(next_state_dbg)
);

always #5 clk = ~clk;

task send_bit;
    input bit_value;
begin
    w = bit_value;
    #10;
end
endtask

initial begin
    clk = 1'b0;
    reset = 1'b1;
    w = 1'b0;
    #20;

    reset = 1'b0;

    // 짧은 정상 프레임 11
    send_bit(1'b1);
    send_bit(1'b1);
    send_bit(1'b0);

    // 긴 정상 프레임 101
    send_bit(1'b1);
    send_bit(1'b0);
    send_bit(1'b1);
    send_bit(1'b0);

    // 오류 프레임 100
    send_bit(1'b1);
    send_bit(1'b0);
    send_bit(1'b0);
    send_bit(1'b0);

    $finish;
end

endmodule
