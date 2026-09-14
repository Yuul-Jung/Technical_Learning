module shift_register_sipo(
    input clk,            // 기준 Clock
    input din,            // 직렬 입력
    output reg [3:0] q    // 병렬 출력
);

always @(posedge clk) begin
    q <= {q[2:0], din};   // 직렬 입력을 병렬로 누적
end

endmodule
