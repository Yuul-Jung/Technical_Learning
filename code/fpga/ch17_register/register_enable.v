module register_enable(
    input clk,           // Clock 입력
    input en,            // Enable 입력
    input [7:0] d,       // 데이터 입력

    output reg [7:0] q   // 데이터 출력
);

// Enable이 1일 때만 저장
always @(posedge clk) begin

    if (en)
        q <= d;

end

endmodule
