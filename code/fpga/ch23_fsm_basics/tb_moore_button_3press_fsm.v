`timescale 1ns / 1ps

module tb_moore_button_3press_fsm;

reg clk;
reg reset;
reg x;

wire z;
wire [1:0] state_dbg;
wire [1:0] next_state_dbg;

moore_button_3press_fsm dut (
    .clk(clk),
    .reset(reset),
    .x(x),
    .z(z),
    .state_dbg(state_dbg),
    .next_state_dbg(next_state_dbg)
);

// 100MHz Clock 생성 : 10ns 주기
always #5 clk = ~clk;

initial begin
    clk = 1'b0;
    reset = 1'b1;
    x = 1'b0;
    #20;

    reset = 1'b0;

    // 버튼 입력 1회
    x = 1'b1; #10;
    x = 1'b0; #20;

    // 버튼 입력 2회
    x = 1'b1; #10;
    x = 1'b0; #20;

    // 버튼 입력 3회 → S3에서 z=1 확인
    x = 1'b1; #10;
    x = 1'b0; #20;

    $finish;
end

endmodule
