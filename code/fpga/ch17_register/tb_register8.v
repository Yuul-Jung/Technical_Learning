`timescale 1ns / 1ps

module tb_register8;

// 입력
reg clk;
reg [7:0] d;

// 출력
wire [7:0] q;

// DUT
register8 dut(
    .clk(clk),
    .d(d),
    .q(q)
);

// Clock 생성
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// 입력 변화
initial begin

    d = 8'h00;

    #7;
    d = 8'hAA;

    #10;
    d = 8'h55;

    #10;
    d = 8'hF0;

    #10;
    d = 8'h0F;

    #20;

    $finish;

end

endmodule
