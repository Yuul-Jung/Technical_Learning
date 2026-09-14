module register8(
    input clk,           // Clock 입력
    input [7:0] d,       // 데이터 입력

    output reg [7:0] q   // 데이터 출력
);

// Clock 상승 에지에서 데이터 저장
always @(posedge clk) begin
    q <= d;
end

endmodule
