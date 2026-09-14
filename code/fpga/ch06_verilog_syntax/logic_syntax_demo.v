// 보완 예제: Verilog 기본 문법과 로직게이트 연산 확인용
module logic_syntax_demo(
    input  wire [1:0] sw,
    output wire [5:0] led
);

assign led[0] = ~sw[0];
assign led[1] =  sw[0] & sw[1];
assign led[2] =  sw[0] | sw[1];
assign led[3] = ~(sw[0] & sw[1]);
assign led[4] = ~(sw[0] | sw[1]);
assign led[5] =  sw[0] ^ sw[1];

endmodule
